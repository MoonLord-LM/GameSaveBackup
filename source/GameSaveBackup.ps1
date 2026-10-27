# 游戏存档备份工具
#
# 开源地址: https://github.com/MoonLord-LM/GameSaveBackup
#
# 功能：
#     依据配置文件，将游戏的本地存档目录，与备份目录进行双向同步
#     本地存档较新时，备份到备份目录；本地存档较旧时，先从备份目录恢复，再重新同步
#     每个游戏的备份目录，通过 Git 进行版本管理，保留历史存档记录
#
# 目录说明：
#     配置文件：\Backup\配置.json，首次运行自动创建内嵌默认配置，英文环境使用 \Backup\config.json
#     备份目录：\Backup\[游戏名称]，游戏子目录下自动生成 [存档位置.bat]，用于快速打开本地存档目录
#
# 配置文件说明：
#     name 游戏名称（唯一，作为备份子目录的名称）
#     save 本地存档路径，支持 %USERPROFILE% %PROGRAMDATA% %PUBLIC% 这类环境变量，运行时自动展开
#     ignore 可选，备份时忽略的文件或目录，同样支持环境变量
#
# 运行方式：
#     powershell -NoProfile -ExecutionPolicy Bypass -File "GameSaveBackup.ps1"
#
# 代码结构：
#     1: 通用基础设置
#     2: 程序设置
#     3: 主窗体界面绘制
#     4: 配置初始化和启动过程
#     5: 主界面功能实现
#     6: 程序启动



# ———————————————————————————————— 1: 通用基础设置 ————————————————————————————————

# 异常处理
function Handle-Exception {
    param([Parameter(Mandatory=$true)][System.Management.Automation.ErrorRecord]$ErrorRecord)
    ''
    "[ Error ] Message: $($ErrorRecord.Exception.Message)"
    if ($ErrorRecord.InvocationInfo) {
        "[ Error ] Line: $($ErrorRecord.InvocationInfo.ScriptLineNumber)"
        if ($ErrorRecord.InvocationInfo.Line) {
            "[ Error ] Code: $($ErrorRecord.InvocationInfo.Line.Trim())"
        }
    }
    ''
}

try {
    # 设置更现代的窗口样式
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()
    [System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

    # 设置字符编码 UTF-8
    Get-Culture > $null
    Get-UICulture > $null
    $defaultOutputEncoding = [System.Console]::OutputEncoding.EncodingName
    [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $currentOutputEncoding = [System.Console]::OutputEncoding.EncodingName
    $workingEncoding = [System.Text.UTF8Encoding]::new($false)
    "[ Debug ] defaultOutputEncoding = $defaultOutputEncoding"
    "[ Debug ] currentOutputEncoding = $currentOutputEncoding"
    "[ Debug ] workingEncoding = $workingEncoding"

    # 获取环境信息，使用单独进程隔离 Get-CimInstance 和 Get-ItemProperty 对语言的影响
    $windowsVersion = powershell -NoProfile -Command {
        $windowsOSInfo = Get-CimInstance Win32_OperatingSystem
        $windowsCurrentVersion = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
        $windowsVersion = "$($windowsOSInfo.Caption) $($windowsCurrentVersion.DisplayVersion)"
        return $windowsVersion
    }
    $powerShellVersion = "$($PSVersionTable.PSVersion.ToString()) $($PSVersionTable.PSEdition)"
    $dotnetClrVersion = [System.Environment]::Version.ToString()
    $threadState = [System.Threading.Thread]::CurrentThread.GetApartmentState()
    $machineName = [System.Net.Dns]::GetHostName()
    $userName = [System.Environment]::UserName
    "[ Debug ] windowsVersion = $windowsVersion"
    "[ Debug ] powerShellVersion = $powerShellVersion"
    "[ Debug ] dotnetClrVersion = $dotnetClrVersion"
    try {
        $dotnetFrameworkDescription = [System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription
        "[ Debug ] dotnetFrameworkDescription = $dotnetFrameworkDescription"
    } catch { }
    "[ Debug ] threadState = $threadState"
    "[ Debug ] machineName = $machineName"
    "[ Debug ] userName = $userName"

    # 加载 Win32 API 函数
    $win32ApiCode =
@'
    using System;
    using System.Runtime.InteropServices;
    public static class DpiContext {
        public static readonly IntPtr UNAWARE = (IntPtr)(-1);
        public static readonly IntPtr SYSTEM_AWARE = (IntPtr)(-2);
        public static readonly IntPtr PER_MONITOR_AWARE = (IntPtr)(-3);
        public static readonly IntPtr PER_MONITOR_AWARE_V2 = (IntPtr)(-4);
    }
    public static class Win32Scroll {
        public const int EM_GETSCROLLPOS = 0x04DD;
        public const int EM_SETSCROLLPOS = 0x04DE;
        [StructLayout(LayoutKind.Sequential)]
        public struct POINT { public int X; public int Y; }
    }
    public static class Win32API {
        [DllImport("user32.dll")]
        public static extern bool SetProcessDPIAware();
        [DllImport("user32.dll")]
        public static extern bool SetProcessDpiAwarenessContext(IntPtr value);
        [DllImport("user32.dll")]
        public static extern IntPtr SendMessage(IntPtr hWnd, int Msg, IntPtr wParam, ref Win32Scroll.POINT lParam);
    }
'@
    Add-Type -TypeDefinition $win32ApiCode

    # 禁用自动缩放
    $dpiResult = $false
    try {
        $dpiResult = [Win32API]::SetProcessDpiAwarenessContext([DpiContext]::PER_MONITOR_AWARE_V2)
    } catch { }
    if (-not $dpiResult) {
        $dpiResult = [Win32API]::SetProcessDPIAware()
    }

    # 查看加载的 WinForms 程序集信息
    $winFormsAssembly = [System.Reflection.Assembly]::GetAssembly([System.Windows.Forms.Form])
    "[ Debug ] winFormsAssemblyRuntime = $($winFormsAssembly.ImageRuntimeVersion)"
    "[ Debug ] winFormsAssembly = $($winFormsAssembly.FullName)"
    "[ Debug ] winFormsAssemblyLocation = $($winFormsAssembly.Location)"

    # 对指定的控件启用双缓冲，减少界面闪烁
    function Enable-Double-Buffered {
        param([Parameter(Mandatory=$true)][System.Windows.Forms.Control]$Control)

        $flags = [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance
        $doubleBufferedProperty = [System.Windows.Forms.Control].GetProperty('DoubleBuffered', $flags)
        $doubleBufferedProperty.SetValue($Control, $true)
        return $doubleBufferedProperty.GetValue($Control)
    }

    # 对指定的控件启用用户绘制，减少界面闪烁
    function Enable-User-Paint {
        param([Parameter(Mandatory=$true)][System.Windows.Forms.Control]$Control)

        $flags = [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance
        $setStyleMethod = [System.Windows.Forms.Control].GetMethod('SetStyle', $flags)
        $setStyleMethod.Invoke($Control, @([System.Windows.Forms.ControlStyles]::UserPaint, $true))
        $setStyleMethod.Invoke($Control, @([System.Windows.Forms.ControlStyles]::AllPaintingInWmPaint, $true))
    }

    # 分析合适的显示语言
    $currentCulture = [System.Globalization.CultureInfo]::CurrentCulture.Name
    $currentUICulture = [System.Globalization.CultureInfo]::CurrentUICulture.Name
    $installedUICulture = [System.Globalization.CultureInfo]::InstalledUICulture.Name
    $currentThreadCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture.Name
    $currentThreadUICulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture.Name
    $workingLanguage = 'en-US'
    $zhCNCount = 0
    $enUSCount = 0
    if ($currentCulture -eq 'zh-CN') { $zhCNCount += 1 } else { $enUSCount += 1 }
    if ($currentUICulture -eq 'zh-CN') { $zhCNCount += 1 } else { $enUSCount += 1 }
    if ($installedUICulture -eq 'zh-CN') { $zhCNCount += 1 } else { $enUSCount += 1 }
    if ($currentThreadCulture -eq 'zh-CN') { $zhCNCount += 1 } else { $enUSCount += 1 }
    if ($currentThreadUICulture -eq 'zh-CN') { $zhCNCount += 1 } else { $enUSCount += 1 }
    if ($zhCNCount -ge $enUSCount) {
        $workingLanguage = 'zh-CN'
    } else {
        $workingLanguage = 'en-US'
    }
    "[ Debug ] currentCulture = $currentCulture"
    "[ Debug ] currentUICulture = $currentUICulture"
    "[ Debug ] installedUICulture = $installedUICulture"
    "[ Debug ] currentThreadCulture = $currentThreadCulture"
    "[ Debug ] currentThreadUICulture = $currentThreadUICulture"
    "[ Debug ] workingLanguage = $workingLanguage"

    # 分析合适的工作目录
    $currentDirectory = [System.IO.Directory]::GetCurrentDirectory()
    $callDirectory = powershell -NoProfile -Command '(Get-Location).Path'
    $scriptDirectory = $PSScriptRoot
    $systemDirectory = [System.Environment]::SystemDirectory
    $userDirectory = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
    $tempDirectory = [System.IO.Path]::GetTempPath()
    $workingDirectory = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
    foreach ($dir in @($currentDirectory, $callDirectory, $scriptDirectory)) {
        if ($dir) {
            if ($dir -ine $systemDirectory) {
                if ($dir -ine $userDirectory) {
                    if ($dir -ine $tempDirectory) {
                        $workingDirectory = $dir
                        break
                    }
                }
            }
        }
    }
    "[ Debug ] currentDirectory = $currentDirectory"
    "[ Debug ] callDirectory = $callDirectory"
    "[ Debug ] scriptDirectory = $scriptDirectory"
    "[ Debug ] systemDirectory = $systemDirectory"
    "[ Debug ] userDirectory = $userDirectory"
    "[ Debug ] tempDirectory = $tempDirectory"
    "[ Debug ] workingDirectory = $workingDirectory"
} catch {
    Handle-Exception $_
    pause
    exit 1
}



# ———————————————————————————————— 2: 程序设置 ————————————————————————————————

try {
    # 界面支持中英文，定义多语言文本资源
    $uiTextResources = @{
        'zh-CN' = @{
            FormTitle = '游戏存档备份工具'
            ConfigLabel = '配置文件:'
            BrowseButton = '选择配置'
            StartButton = '开始备份'
            CopyLogMenu = '复制日志'
            ClearLogMenu = '清空日志'
            LogTabPage = '运行日志'
            GameListTabPage = '游戏列表'
            MachineInfo = '机器名: [ {0} ]  用户名: [ {1} ]'
            ConfigLoaded = '成功加载配置文件，共 {0} 个游戏'
            GameListUpdated = '游戏列表已更新'
            ConfigSelected = '已选择配置文件: {0}'
            BackupStarted = '开始备份任务'
            RunspaceStarted = 'Runspace 已启动，开始监控备份任务'
            LogCopied = '日志已复制到剪贴板'
            NoLog = '当前没有日志内容'
            ColumnIndex = '序号'
            ColumnGameName = '游戏名称'
            ColumnSavePath = '存档路径'
            FileFilter = 'JSON 文件 (*.json)|*.json|所有文件 (*.*)|*.*'
            FileDialogTitle = '选择配置文件'
            OpenSaveLocation = '打开存档位置'
            OpenSaveLocationNotExist = '打开存档位置（文件不存在）'
            OpeningSaveLocation = '打开存档位置: {0} - {1}'
            SaveLocationNotExist = '存档路径不存在: {0} - {1}'
            ConfirmButton = '确认'
            SaveLocationBatName = '存档位置.bat'
            CreateBackupDir = '创建备份目录: {0}'
            ERROR_OpenSaveLocationFailed = '打开存档位置失败: {0}'
            ERROR_GitMissing = '错误：缺少 Git 组件'
            ERROR_GitDownload = '请从 https://git-scm.com/install/windows 下载，并完成安装'
            ERROR_ConfigNotFound = '错误：选定的配置文件不存在'
            ERROR_ConfigNotSelected = '未选择配置文件'
            INFO_GitCommand = 'Git 命令'
            INFO_RobocopyCommand = 'Robocopy 命令'
            ERROR_GitCommandFailed = 'Git 命令执行失败，错误码：{0}，输出信息：{1}'
            ERROR_RobocopyTaskFailed = 'Robocopy 执行失败，错误码：{0}，终止备份任务'
            INFO_GamesFound = '找到游戏配置数量'
            INFO_MultipleConfigSelect = '当前位置存在 {0} 个配置文件，请选择'
            ERROR_ConfigLoadFailed = '配置文件加载失败: {0}'
            PROGRESS_Processing = '处理'
            INFO_IgnoreItem = '忽略项'
            INFO_EnteringBackupDir = '进入备份目录: {0}'
            INFO_BackupRootDir = '备份根目录: {0}'
            ERROR_ConfigNotArrayFormat = '配置内容必须是数组格式'
            ERROR_ConfigEmptyCount = '配置内容的配置项个数为零'
            ERROR_ConfigItemNotObject = '第 {0} 个配置项不是 JSON 对象'
            ERROR_ConfigItemMissingName = "第 {0} 个配置项缺少 'name' 属性"
            ERROR_ConfigItemMissingSave = "第 {0} 个配置项缺少 'save' 属性"
            ERROR_ConfigItemNameEmpty = "第 {0} 个配置项的 'name' 属性为空"
            ERROR_ConfigItemSaveEmpty = "第 {0} 个配置项的 'save' 属性为空"
            ERROR_ConfigItemNameIllegalChars = "第 {0} 个配置项的 'name' 属性包含 Windows 文件名非法字符（< > : '' / \ | ? *）"
            ERROR_ConfigItemInvalidIgnore = "第 {0} 个配置项的 'ignore' 属性必须是数组格式"
            ERROR_ConfigItemInvalidIgnoreElement = "第 {0} 个配置项的 'ignore' 数组中包含空元素或非字符串元素"
            ERROR_CreateBackupDirFailed = '创建备份目录失败: {0}'
            ERROR_GetFileTimeFailed = '获取文件修改时间失败: {0}'
            ERROR_ErrorDetails = '错误详情: {0}'
            INFO_FileTimeComparison = '本地文件修改时间:[{0}] 备份文件修改时间:[{1}]'
            WARNING_BothMissing = '本地存档文件与备份文件都不存在，跳过操作'
            WARNING_LocalMissing = '本地存档文件缺失，使用备份文件恢复'
            INFO_BackupMissing = '备份文件缺失，进行备份'
            WARNING_LocalOlder = '本地存档文件修改时间较旧，删除到回收站，并使用备份文件更新'
            INFO_LocalNewer = '本地存档文件修改时间较新，进行备份'
            INFO_SameTime = '本地存档文件与备份文件修改时间相同，跳过操作'
            INFO_RobocopyReturn = '详细信息'
            INFO_RobocopySuccess = 'Robocopy 执行成功（返回码 {0}）'
            INFO_RobocopyFailed = 'Robocopy 执行失败（返回码 {0}）'
            INFO_GitOutput = 'Git 输出信息'
            SUCCESS_GitCommit = 'Git 提交完成'
            SUCCESS_FinalCommit = '最终 Git 提交完成'
            SUCCESS_BackupComplete = '备份完成'
            ERROR_BackupTaskFailed = '备份任务失败: {0}'
            SUCCESS_GitInitialized = 'Git 仓库已初始化并配置'
            INFO_SystemInfo = '系统版本: [ {0} ]  PowerShell 版本: [ {1} ]'
            ConfigFileName = '配置.json'
            BackupDirName = 'Backup'
        }
        'en-US' = @{
            FormTitle = 'Game Save Backup Tool'
            ConfigLabel = 'Config File:'
            BrowseButton = 'Browse Config'
            StartButton = 'Start Backup'
            CopyLogMenu = 'Copy Log'
            ClearLogMenu = 'Clear Log'
            LogTabPage = 'Run Log'
            GameListTabPage = 'Game List'
            MachineInfo = 'Machine: [ {0} ]  User: [ {1} ]'
            ConfigLoaded = 'Config file loaded successfully, {0} game(s) found'
            GameListUpdated = 'Game list updated'
            ConfigSelected = 'Config file selected: {0}'
            BackupStarted = 'Starting backup task'
            RunspaceStarted = 'Runspace started, monitoring backup task'
            LogCopied = 'Log copied to clipboard'
            NoLog = 'No log content'
            ColumnIndex = '#'
            ColumnGameName = 'Game Name'
            ColumnSavePath = 'Save Path'
            FileFilter = 'JSON Files (*.json)|*.json|All Files (*.*)|*.*'
            FileDialogTitle = 'Select Config File'
            OpenSaveLocation = 'Open Save Path'
            OpenSaveLocationNotExist = 'Open Save Path (Not Exist)'
            OpeningSaveLocation = 'Open save location: {0} - {1}'
            SaveLocationNotExist = 'Save location does not exist: {0} - {1}'
            ConfirmButton = 'Confirm'
            SaveLocationBatName = 'SaveLocation.bat'
            CreateBackupDir = 'Creating backup directory: {0}'
            ERROR_OpenSaveLocationFailed = 'Failed to open save location: {0}'
            ERROR_GitMissing = 'Error: Missing Git component'
            ERROR_GitDownload = 'Please download and install from https://git-scm.com/install/windows'
            ERROR_ConfigNotFound = 'Error: Selected config file does not exist'
            ERROR_ConfigNotSelected = 'Config file not selected'
            INFO_GitCommand = 'Git command'
            INFO_RobocopyCommand = 'Robocopy command'
            ERROR_GitCommandFailed = 'Git command execution failed, error code: {0}, output: {1}'
            ERROR_RobocopyTaskFailed = 'Robocopy execution failed, error code: {0}, backup task aborted'
            INFO_GamesFound = 'game(s) found in configuration'
            INFO_MultipleConfigSelect = 'Location: {0} config files found, please select'
            ERROR_ConfigLoadFailed = 'Config file load failed: {0}'
            PROGRESS_Processing = 'Processing'
            INFO_IgnoreItem = 'Ignore item'
            INFO_EnteringBackupDir = 'Entering backup directory: {0}'
            INFO_BackupRootDir = 'Backup root directory: {0}'
            ERROR_ConfigNotArrayFormat = 'Config content must be an array format'
            ERROR_ConfigEmptyCount = 'Config contains zero items'
            ERROR_ConfigItemNotObject = 'Item {0} is not a JSON object'
            ERROR_ConfigItemMissingName = "Item {0} missing 'name' property"
            ERROR_ConfigItemMissingSave = "Item {0} missing 'save' property"
            ERROR_ConfigItemNameEmpty = "Item {0} has empty 'name' property"
            ERROR_ConfigItemSaveEmpty = "Item {0} has empty 'save' property"
            ERROR_ConfigItemNameIllegalChars = "Item {0} 'name' property contains illegal filename characters (<>:''/\|?*)"
            ERROR_ConfigItemInvalidIgnore = "Item {0} 'ignore' property must be an array format"
            ERROR_ConfigItemInvalidIgnoreElement = "Item {0} 'ignore' array contains empty or non-string elements"
            ERROR_CreateBackupDirFailed = 'Failed to create backup directory: {0}'
            ERROR_GetFileTimeFailed = 'Failed to get file modification time: {0}'
            ERROR_ErrorDetails = 'Error details: {0}'
            INFO_FileTimeComparison = 'Local file time:[{0}] Backup file time:[{1}]'
            WARNING_BothMissing = 'Both local save and backup files are missing, skipping'
            WARNING_LocalMissing = 'Local save file is missing, restoring from backup'
            INFO_BackupMissing = 'Backup file is missing, performing backup'
            WARNING_LocalOlder = 'Local save file is older, deleting to recycle bin and updating from backup'
            INFO_LocalNewer = 'Local save file is newer, performing backup'
            INFO_SameTime = 'Local and backup files have the same modification time, skipping'
            INFO_RobocopyReturn = 'Details'
            INFO_RobocopySuccess = 'Robocopy executed successfully (exit code {0})'
            INFO_RobocopyFailed = 'Robocopy execution failed (exit code {0})'
            INFO_GitOutput = 'Git output'
            SUCCESS_GitCommit = 'Git commit completed'
            SUCCESS_FinalCommit = 'Final Git commit completed'
            SUCCESS_BackupComplete = 'Backup completed successfully'
            ERROR_BackupTaskFailed = 'Backup task failed: {0}'
            SUCCESS_GitInitialized = 'Git repository initialized and configured'
            INFO_SystemInfo = 'System Version: [ {0} ]  PowerShell Version: [ {1} ]'
            ConfigFileName = 'config.json'
            BackupDirName = 'Backup'
        }
    }
    $ui = $uiTextResources[$workingLanguage]

    # 内嵌的中英文的默认 JSON 配置
    $defaultJsonConfigs = @{
        'zh-CN' = @'
[
    {
        "name": "艾尔登法环",
        "save": "%USERPROFILE%\\AppData\\Roaming\\EldenRing"
    },
    {
        "name": "幻兽帕鲁",
        "save": "%USERPROFILE%\\AppData\\Local\\Pal\\Saved\\SaveGames"
    },
    {
        "name": "部落幸存者",
        "save": "%USERPROFILE%\\AppData\\LocalLow\\SZSS INTERACTIVE\\Settlement Survival"
    },
    {
        "name": "最后纪元",
        "save": "%USERPROFILE%\\AppData\\LocalLow\\Eleventh Hour Games\\Last Epoch"
    },
    {
        "name": "虐杀原形",
        "save": "%USERPROFILE%\\Documents\\Prototype"
    },
    {
        "name": "尼尔：机械纪元",
        "save": "%USERPROFILE%\\Documents\\My Games\\NieR_Automata"
    },
    {
        "name": "真三国无双8：帝国",
        "save": "%USERPROFILE%\\Documents\\KoeiTecmo\\Dynasty Warriors 9 Empires"
    },
    {
        "name": "无双大蛇3",
        "save": "%USERPROFILE%\\Documents\\KoeiTecmo\\WARRIORS OROCHI 4"
    },
    {
        "name": "真三国无双5",
        "save": "%USERPROFILE%\\Documents\\KOEI\\Shin Sangokumusou 5"
    },
    {
        "name": "亿万僵尸",
        "save": "%USERPROFILE%\\Documents\\My Games\\They Are Billions"
    },
    {
        "name": "星球基地",
        "save": "%USERPROFILE%\\Documents\\Planetbase"
    },
    {
        "name": "缺氧",
        "save": "%USERPROFILE%\\Documents\\Klei\\OxygenNotIncluded",
        "ignore": [
            "%USERPROFILE%\\Documents\\Klei\\OxygenNotIncluded\\RetiredColonies"
        ]
    },
    {
        "name": "饥荒联机版",
        "save": "%USERPROFILE%\\Documents\\Klei\\DoNotStarveTogether"
    },
    {
        "name": "博德之门3",
        "save": "%USERPROFILE%\\AppData\\Local\\Larian Studios\\Baldur's Gate 3"
    },
    {
        "name": "三国志8：重制版",
        "save": "%USERPROFILE%\\Documents\\KoeiTecmo\\SAN8R"
    },
    {
        "name": "古墓丽影10：崛起",
        "save": "%USERPROFILE%\\Documents\\CPY_SAVES\\CPY\\391220"
    },
    {
        "name": "古墓丽影11：暗影",
        "save": "%USERPROFILE%\\Documents\\Shadow of the Tomb Raider"
    },
    {
        "name": "光与影：33号远征队",
        "save": "%USERPROFILE%\\AppData\\Local\\Sandfall\\Saved"
    },
    {
        "name": "对马岛之魂",
        "save": "%USERPROFILE%\\Documents\\Ghost of Tsushima DIRECTOR'S CUT"
    },
    {
        "name": "纪念碑谷",
        "save": "%USERPROFILE%\\AppData\\LocalLow\\ustwo games\\Monument Valley"
    },
    {
        "name": "虫虫大作战",
        "save": "%PROGRAMDATA%\\AlderGames\\BugBits"
    },
    {
        "name": "棋弈无限：围棋",
        "save": "%USERPROFILE%\\AppData\\LocalLow\\Studio Amateur\\JustGo"
    }
]
'@
        'en-US' = @'
[
    {
        "name": "Elden Ring",
        "save": "%USERPROFILE%\\AppData\\Roaming\\EldenRing"
    },
    {
        "name": "Palworld",
        "save": "%USERPROFILE%\\AppData\\Local\\Pal\\Saved\\SaveGames"
    },
    {
        "name": "Settlement Survival",
        "save": "%USERPROFILE%\\AppData\\LocalLow\\SZSS INTERACTIVE\\Settlement Survival"
    },
    {
        "name": "Last Epoch",
        "save": "%USERPROFILE%\\AppData\\LocalLow\\Eleventh Hour Games\\Last Epoch"
    },
    {
        "name": "Prototype",
        "save": "%USERPROFILE%\\Documents\\Prototype"
    },
    {
        "name": "NieR Automata",
        "save": "%USERPROFILE%\\Documents\\My Games\\NieR_Automata"
    },
    {
        "name": "Dynasty Warriors 9 Empires",
        "save": "%USERPROFILE%\\Documents\\KoeiTecmo\\Dynasty Warriors 9 Empires"
    },
    {
        "name": "Warriors Orochi 4",
        "save": "%USERPROFILE%\\Documents\\KoeiTecmo\\WARRIORS OROCHI 4"
    },
    {
        "name": "Shin Sangokumusou 5",
        "save": "%USERPROFILE%\\Documents\\KOEI\\Shin Sangokumusou 5"
    },
    {
        "name": "They Are Billions",
        "save": "%USERPROFILE%\\Documents\\My Games\\They Are Billions"
    },
    {
        "name": "Planetbase",
        "save": "%USERPROFILE%\\Documents\\Planetbase"
    },
    {
        "name": "Oxygen Not Included",
        "save": "%USERPROFILE%\\Documents\\Klei\\OxygenNotIncluded",
        "ignore": [
            "%USERPROFILE%\\Documents\\Klei\\OxygenNotIncluded\\RetiredColonies"
        ]
    },
    {
        "name": "Don't Starve Together",
        "save": "%USERPROFILE%\\Documents\\Klei\\DoNotStarveTogether"
    },
    {
        "name": "Baldur's Gate 3",
        "save": "%USERPROFILE%\\AppData\\Local\\Larian Studios\\Baldur's Gate 3"
    },
    {
        "name": "Romance Of The Three Kingdoms 8 Remake",
        "save": "%USERPROFILE%\\Documents\\KoeiTecmo\\SAN8R"
    },
    {
        "name": "Rise of the Tomb Raider",
        "save": "%USERPROFILE%\\Documents\\CPY_SAVES\\CPY\\391220"
    },
    {
        "name": "Shadow of the Tomb Raider",
        "save": "%USERPROFILE%\\Documents\\Shadow of the Tomb Raider"
    },
    {
        "name": "Clair Obscur Expedition 33",
        "save": "%USERPROFILE%\\AppData\\Local\\Sandfall\\Saved"
    },
    {
        "name": "Ghost Of Tsushima",
        "save": "%USERPROFILE%\\Documents\\Ghost of Tsushima DIRECTOR'S CUT"
    },
    {
        "name": "Monument Valley",
        "save": "%USERPROFILE%\\AppData\\LocalLow\\ustwo games\\Monument Valley"
    },
    {
        "name": "BugBits",
        "save": "%PROGRAMDATA%\\AlderGames\\BugBits"
    },
    {
        "name": "JustGo",
        "save": "%USERPROFILE%\\AppData\\LocalLow\\Studio Amateur\\JustGo"
    }
]
'@
    }
    $defaultJsonConfig = $defaultJsonConfigs[$workingLanguage]
} catch {
    Handle-Exception $_
    pause
    exit 1
}



# ———————————————————————————————— 3: 主窗体界面绘制 ————————————————————————————————

try {
    # 创建主窗口
    $mainForm = [System.Windows.Forms.Form]::new()
    $mainForm.Text = $ui.FormTitle
    $mainForm.Size = [System.Drawing.Size]::new(1280, 720)
    $mainForm.StartPosition = 'CenterScreen'
    $mainForm.Font = [System.Drawing.Font]::new('Microsoft YaHei', 10)
    $mainForm.MinimumSize = [System.Drawing.Size]::new(1000, 600)

    # 启用双缓冲和用户绘制，减少界面闪烁
    Enable-Double-Buffered $mainForm | Out-Null
    Enable-User-Paint $mainForm | Out-Null

    # 创建顶部面板（操作区）
    $topPanel = [System.Windows.Forms.Panel]::new()
    $topPanel.Dock = 'Top'
    $topPanel.Height = 60
    $topPanel.Padding = [System.Windows.Forms.Padding]::new(10, 10, 10, 10)

    # 创建中部面板（内容区）
    $centerPanel = [System.Windows.Forms.Panel]::new()
    $centerPanel.Dock = 'Fill'
    $centerPanel.Padding = [System.Windows.Forms.Padding]::new(10, 0, 10, 0)

    # 创建底部面板（提示区）
    $bottomPanel = [System.Windows.Forms.Panel]::new()
    $bottomPanel.Dock = 'Bottom'
    $bottomPanel.Height = 40
    $bottomPanel.Padding = [System.Windows.Forms.Padding]::new(10, 10, 10, 10)

    # 将三个面板添加到主窗口（注意顺序: 先添加 Fill，再添加 Top/Bottom）
    $mainForm.Controls.Add($centerPanel)
    $mainForm.Controls.Add($topPanel)
    $mainForm.Controls.Add($bottomPanel)

    # 顶部: 左侧配置文件标签和文本框
    $topInfoPanel = [System.Windows.Forms.Panel]::new()
    $topInfoPanel.Dock = 'Fill'
    $topPanel.Controls.Add($topInfoPanel)

    # 顶部: 配置文件标签
    $configLabel = [System.Windows.Forms.Label]::new()
    $configLabel.Text = $ui.ConfigLabel
    $configLabel.Location = [System.Drawing.Point]::new(10, 8)
    $configLabel.Size = [System.Drawing.Size]::new(100, 40)
    $topInfoPanel.Controls.Add($configLabel)

    # 顶部: 配置文件文本框
    $configTextBox = [System.Windows.Forms.TextBox]::new()
    $configTextBox.Location = [System.Drawing.Point]::new(120, 5)
    $configTextBox.Width = $topInfoPanel.Width - 130
    $configTextBox.ReadOnly = $true
    # 右侧按钮组面板是本行之后才添加的，此处宽度偏大，用 Anchor 让文本框随面板实际宽度自适应
    $configTextBox.Anchor = 'Left, Top, Right'
    $topInfoPanel.Controls.Add($configTextBox)

    # 顶部: 右侧按钮组
    $topButtonGroupPanel = [System.Windows.Forms.Panel]::new()
    $topButtonGroupPanel.Dock = 'Right'
    $topButtonGroupPanel.Width = 280
    $topPanel.Controls.Add($topButtonGroupPanel)

    # 顶部: 选择配置按钮
    $browseButton = [System.Windows.Forms.Button]::new()
    $browseButton.Text = $ui.BrowseButton
    $browseButton.Location = [System.Drawing.Point]::new(5, 0)
    $browseButton.Size = [System.Drawing.Size]::new(130, 36)
    # $browseButton.BackColor = [System.Drawing.Color]::LightGreen
    $topButtonGroupPanel.Controls.Add($browseButton)

    # 顶部: 开始备份按钮
    $startButton = [System.Windows.Forms.Button]::new()
    $startButton.Text = $ui.StartButton
    $startButton.Location = [System.Drawing.Point]::new(140, 0)
    $startButton.Size = [System.Drawing.Size]::new(130, 36)
    # $startButton.BackColor = [System.Drawing.Color]::LightBlue
    $startButton.Enabled = $false
    $topButtonGroupPanel.Controls.Add($startButton)

    # 中部: 标签页容器
    $tabControl = [System.Windows.Forms.TabControl]::new()
    $tabControl.Dock = 'Fill'
    $tabControl.Padding = [System.Drawing.Point]::new(20, 3)
    $centerPanel.Controls.Add($tabControl)

    # 中部: 日志标签页
    $logTabPage = [System.Windows.Forms.TabPage]::new()
    $logTabPage.Text = $ui.LogTabPage
    $tabControl.Controls.Add($logTabPage)

    # 中部: 游戏标签页
    $gameListTabPage = [System.Windows.Forms.TabPage]::new()
    $gameListTabPage.Text = $ui.GameListTabPage

    # 中部: 日志显示区域
    $logTextBox = [System.Windows.Forms.RichTextBox]::new()
    $logTextBox.ReadOnly = $true
    $logTextBox.ScrollBars = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
    $logTextBox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $logTextBox.BackColor = [System.Drawing.Color]::White
    $logTextBox.Dock = 'Fill'
    $logTabPage.Controls.Add($logTextBox)

    # 日志文本框的右键菜单
    $copyLogMenuItem = [System.Windows.Forms.ToolStripMenuItem]::new()
    $copyLogMenuItem.Text = $ui.CopyLogMenu
    $clearLogMenuItem = [System.Windows.Forms.ToolStripMenuItem]::new()
    $clearLogMenuItem.Text = $ui.ClearLogMenu
    $logTextBox.ContextMenuStrip = [System.Windows.Forms.ContextMenuStrip]::new()
    $logTextBox.ContextMenuStrip.Items.Add($copyLogMenuItem) | Out-Null
    $logTextBox.ContextMenuStrip.Items.Add($clearLogMenuItem) | Out-Null

    # 展示日志
    $logColorMap = @{
        Info     = [System.Drawing.Color]::Black
        Success  = [System.Drawing.Color]::Green
        Warning  = [System.Drawing.Color]::DarkOrange
        Error    = [System.Drawing.Color]::Red
        Progress = [System.Drawing.Color]::Blue
        Debug    = [System.Drawing.Color]::Gray
    }
    function Show-Log {
        param([string]$Message = '', [string]$Level = 'Info')

        if ($logTextBox.IsDisposed) { return }
        if ($logTextBox.InvokeRequired) {
            $logTextBox.Invoke([System.Action]{
                Show-Log -Message $Message -Level $Level
            })
            return
        }

        $logColor = if ($logColorMap.ContainsKey($Level)) {
            $logColorMap[$Level]
        } else {
            [System.Drawing.Color]::Black
        }
        $logText = "[{0}] {1}`r`n" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message

        $logTextBox.SuspendLayout()
        try {
            if ($logTextBox.IsDisposed) { return }
            $logTextBox.SelectionStart = $logTextBox.TextLength
            $logTextBox.SelectionLength = 0
            $logTextBox.SelectionColor = $logColor
            $logTextBox.AppendText($logText)
            $logTextBox.ScrollToCaret()
        }
        finally {
            $logTextBox.ResumeLayout()
        }
    }
    function Show-Log-Batch {
        param([System.Collections.Generic.List[hashtable]]$Logs)

        if ($logTextBox.IsDisposed) { return }
        if ($logTextBox.InvokeRequired) {
            $logTextBox.Invoke([System.Action]{
                Show-Log-Batch -Logs $Logs
            })
            return
        }
        if (-not $Logs -or $Logs.Count -eq 0) {
            return
        }

        $logTextBox.SuspendLayout()
        try {
            foreach ($log in $Logs) {
                $logColor = if ($logColorMap.ContainsKey($log.Level)) {
                    $logColorMap[$log.Level]
                } else {
                    [System.Drawing.Color]::Black
                }
                $logText = "[{0}] {1}`r`n" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $log.Message
                if ($logTextBox.IsDisposed) { return }
                $logTextBox.SelectionStart = $logTextBox.TextLength
                $logTextBox.SelectionLength = 0
                $logTextBox.SelectionColor = $logColor
                $logTextBox.AppendText($logText)
            }
            $logTextBox.ScrollToCaret()
        }
        finally {
            $logTextBox.ResumeLayout()
        }
    }

    # 异步展示日志（使用队列和定时任务，实现固定频率刷新界面）
    $asyncShowLogQueue = [System.Collections.Concurrent.ConcurrentQueue[hashtable]]::new()
    function Show-Log-Async {
        param([string]$Message = '', [string]$Level = 'Info')
        $asyncShowLogQueue.Enqueue(@{ Message = $Message; Level = $Level })
    }
    $asyncShowLogTimer = [System.Windows.Forms.Timer]::new()
    $asyncShowLogTimer.Add_Tick({
        $logs = [System.Collections.Generic.List[hashtable]]::new()
        $log = $null
        while ($asyncShowLogQueue.TryDequeue([ref]$log)) {
            $logs.Add($log)
        }
        if ($logs.Count -gt 0) {
            Show-Log-Batch -Logs $logs
        }
    })
    $asyncShowLogTimer.Interval = 100
    $asyncShowLogTimer.Start()

    # 中部: 游戏信息显示表格
    $dataGridView = [System.Windows.Forms.DataGridView]::new()
    $dataGridView.ReadOnly = $true
    $dataGridView.AllowUserToAddRows = $false
    $dataGridView.AllowUserToDeleteRows = $false
    $dataGridView.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
    $dataGridView.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $dataGridView.BackgroundColor = [System.Drawing.Color]::White
    $dataGridView.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::LightGray
    $dataGridView.ColumnHeadersHeight = 40
    $dataGridView.RowTemplate.Height = 30
    $dataGridView.Dock = 'Fill'
    # 启用双缓冲减少闪烁
    Enable-Double-Buffered $dataGridView | Out-Null
    $dataGridView.ColumnCount = 3
    $dataGridView.Columns[0].Name = $ui.ColumnIndex
    $dataGridView.Columns[1].Name = $ui.ColumnGameName
    $dataGridView.Columns[2].Name = $ui.ColumnSavePath
    $dataGridView.Columns[0].Width = 60
    $dataGridView.Columns[0].MinimumWidth = $dataGridView.Columns[0].Width / 2
    $dataGridView.Columns[1].Width = 320
    $dataGridView.Columns[1].MinimumWidth = $dataGridView.Columns[1].Width / 2
    $dataGridView.Columns[2].Width = 780
    $dataGridView.Columns[2].MinimumWidth = $dataGridView.Columns[2].Width / 2
    # 只允许单行选择
    $dataGridView.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
    $dataGridView.MultiSelect = $false
    # 鼠标按下时自动选中一行（包括左键和右键）
    $dataGridView.Add_CellMouseDown({
        param($eventSender, $event)
        if ($event.RowIndex -ge 0) {
            $dataGridView.ClearSelection()
            $dataGridView.Rows[$event.RowIndex].Selected = $true
            $dataGridView.CurrentCell = $dataGridView.Rows[$event.RowIndex].Cells[0]
        }
    })
    $gameListTabPage.Controls.Add($dataGridView)

    # 创建右键菜单（打开存档位置）
    $contextMenu = [System.Windows.Forms.ContextMenuStrip]::new()
    $openLocationMenuItem = [System.Windows.Forms.ToolStripMenuItem]::new()
    $openLocationMenuItem.Text = $ui.OpenSaveLocation
    $contextMenu.Items.Add($openLocationMenuItem) | Out-Null
    $dataGridView.ContextMenuStrip = $contextMenu

    # 底部: 进度条
    $progressBar = [System.Windows.Forms.ProgressBar]::new()
    $progressBar.Dock = 'Fill'
    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $progressBar.Visible = $false
    $bottomPanel.Controls.Add($progressBar)

    # 进度条的异步更新（使用定时任务，实现固定频率刷新界面）
    $asyncProgressState = [System.Collections.Concurrent.ConcurrentDictionary[string, int]]::new()
    $asyncProgressState['Value'] = 0
    $asyncProgressState['LastValue'] = 0
    $asyncProgressTimer = [System.Windows.Forms.Timer]::new()
    $asyncProgressTimer.Add_Tick({
        $value = $asyncProgressState['Value']
        $value = [System.Math]::Max($value, $progressBar.Minimum)
        $value = [System.Math]::Min($value, $progressBar.Maximum)
        if ($value -ne $asyncProgressState['LastValue']) {
            $progressBar.Value = $value
            $asyncProgressState['LastValue'] = $value
        }
    })
    $asyncProgressTimer.Interval = 100
    $asyncProgressTimer.Start()

    # 执行备份的 Runspace 线程池
    $backupRunspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, 1)
    $backupRunspacePool.ApartmentState = [System.Threading.ApartmentState]::STA
    $backupRunspacePool.Open()

    # 窗口关闭时的清理工作
    $mainForm.Add_FormClosing({
        # 先停止备份任务的轮询定时器，再停止可能仍在运行的备份任务，避免定时器访问已释放的控件
        if ($backupResultTimer) {
            $backupResultTimer.Stop()
            $backupResultTimer.Dispose()
            $script:backupResultTimer = $null
        }
        if ($backupPsInstance) {
            try { $backupPsInstance.Stop() } catch { }
            try { $backupPsInstance.Dispose() } catch { }
            $script:backupPsInstance = $null
        }
        $script:backupAsyncResult = $null
        $script:isBackupRunning = $false
        if ($asyncShowLogTimer) {
            $asyncShowLogTimer.Stop()
            $asyncShowLogTimer.Dispose()
        }
        if ($asyncProgressTimer) {
            $asyncProgressTimer.Stop()
            $asyncProgressTimer.Dispose()
        }
        if ($backupRunspacePool) {
            $backupRunspacePool.Close()
            $backupRunspacePool.Dispose()
        }
    })
} catch {
    Handle-Exception $_
    pause
    exit 1
}



# ———————————————————————————————— 4: 配置初始化和启动过程 ————————————————————————————————

try {
    # 配置文件和备份文件，创建单独的目录存放
    $backupDirectory = [System.IO.Path]::Combine($workingDirectory, $ui.BackupDirName)
    "[ Debug ] backupDirectory = $backupDirectory"
    if (-not [System.IO.Directory]::Exists($backupDirectory)) {
        [System.IO.Directory]::CreateDirectory($backupDirectory) | Out-Null
    }

    # 依据当前语言确定首选与兼容的配置文件名
    # 中文版默认使用 配置.json，英文版默认使用 config.json，同时兼容另一种命名
    $configFileName = $ui.ConfigFileName
    $configFileNameAlt = if ($configFileName -eq '配置.json') { 'config.json' } else { '配置.json' }
    $configFilePathPref = [System.IO.Path]::Combine($backupDirectory, $configFileName)
    $configFilePathAlt = [System.IO.Path]::Combine($backupDirectory, $configFileNameAlt)
    "[ Debug ] configFileName = $configFileName"
    "[ Debug ] configFileNameAlt = $configFileNameAlt"

    # 仅在这两个专用文件名中查找配置文件，避免把备份目录里其它 json 文件误当作配置
    $configFileCandidates = [System.Collections.Generic.List[string]]::new()
    if ([System.IO.File]::Exists($configFilePathPref)) {
        $configFileCandidates.Add($configFilePathPref) | Out-Null
    }
    if ([System.IO.File]::Exists($configFilePathAlt)) {
        $configFileCandidates.Add($configFilePathAlt) | Out-Null
    }
    $configFileCandidatesCount = $configFileCandidates.Count
    "[ Debug ] configFileCandidatesCount = $configFileCandidatesCount"

    if ($configFileCandidatesCount -eq 0) {
        # 两个配置文件都不存在，按语言默认创建新的配置文件并写入内嵌默认配置
        $configFilePath = $configFilePathPref
        [System.IO.File]::WriteAllText($configFilePath, $defaultJsonConfig, $workingEncoding)
    }
    elseif ($configFileCandidatesCount -eq 1) {
        # 仅存在一个配置文件，直接使用（兼容另一种命名）
        $configFilePath = $configFileCandidates[0]
    }
    else {
        # 两个配置文件同时存在，提示用户选择
        $selectForm = [System.Windows.Forms.Form]::new()
        $selectForm.Text = $ui.FormTitle
        $selectForm.Size = [System.Drawing.Size]::new(800, 450)
        $selectForm.StartPosition = 'CenterScreen'
        $selectForm.Font = [System.Drawing.Font]::new('Microsoft YaHei', 10)
        $selectForm.FormBorderStyle = 'FixedDialog'
        $selectForm.MaximizeBox = $false
        $selectForm.MinimizeBox = $false
        $selectForm.TopMost = $true

        # 启用双缓冲和用户绘制，减少界面闪烁
        Enable-Double-Buffered $selectForm | Out-Null
        Enable-User-Paint $selectForm | Out-Null

        # 顶部面板（提示区）
        $selectTopPanel = [System.Windows.Forms.Panel]::new()
        $selectTopPanel.Dock = 'Top'
        $selectTopPanel.Height = 80
        $selectTopPanel.Padding = [System.Windows.Forms.Padding]::new(10, 10, 10, 10)

        # 中间面板（内容区）
        $selectCenterPanel = [System.Windows.Forms.Panel]::new()
        $selectCenterPanel.Dock = 'Fill'
        $selectCenterPanel.Padding = [System.Windows.Forms.Padding]::new(10, 0, 10, 0)

        # 底部面板（操作区）
        $selectBottomPanel = [System.Windows.Forms.Panel]::new()
        $selectBottomPanel.Dock = 'Bottom'
        $selectBottomPanel.Height = 60
        $selectBottomPanel.Padding = [System.Windows.Forms.Padding]::new(10, 10, 10, 10)

        # 将三个面板添加到主窗口（注意顺序: 先添加 Fill，再添加 Top/Bottom）
        $selectForm.Controls.Add($selectCenterPanel)
        $selectForm.Controls.Add($selectTopPanel)
        $selectForm.Controls.Add($selectBottomPanel)

        # 提示信息
        $selectInfoLabel1 = [System.Windows.Forms.Label]::new()
        $selectInfoLabel1.Text = ($ui.INFO_MultipleConfigSelect -f $configFileCandidatesCount)
        $selectInfoLabel1.Dock = 'Bottom'
        $selectInfoLabel1.Height = 28
        $selectInfoLabel1.AutoEllipsis = $true
        $selectTopPanel.Controls.Add($selectInfoLabel1)
        $selectInfoLabel2 = [System.Windows.Forms.Label]::new()
        $selectInfoLabel2.Text = $backupDirectory
        $selectInfoLabel2.Dock = 'Bottom'
        $selectInfoLabel2.Height = 28
        $selectInfoLabel2.AutoEllipsis = $true
        $selectTopPanel.Controls.Add($selectInfoLabel2)

        # 列表框填充中间空间
        $selectListBox = [System.Windows.Forms.ListBox]::new()
        $selectListBox.Dock = 'Fill'
        $selectListBox.SelectionMode = 'One'
        $selectListBox.IntegralHeight = $false
        foreach ($file in $configFileCandidates) {
            $selectListBox.Items.Add((Split-Path -Leaf $file)) | Out-Null
        }
        $selectListBox.SelectedIndex = 0
        $selectCenterPanel.Controls.Add($selectListBox)

        # 确认按钮
        $selectOkButton = [System.Windows.Forms.Button]::new()
        $selectOkButton.Text = $ui.ConfirmButton
        $selectOkButton.Location = [System.Drawing.Point]::new(325, 12)
        $selectOkButton.Size = [System.Drawing.Size]::new(130, 36)
        $selectOkButton.DialogResult = 'OK'
        $selectBottomPanel.Controls.Add($selectOkButton)
        $selectForm.AcceptButton = $selectOkButton

        # 双击列表项等同于确认
        $selectListBox.Add_DoubleClick({
            $selectForm.DialogResult = 'OK'
            $selectForm.Close()
            $selectForm.Dispose()
        })

        # 显示对话框
        if ($selectForm.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK -and $selectListBox.SelectedIndex -ge 0) {
            $configFilePath = $configFileCandidates[$selectListBox.SelectedIndex]
        } else {
            ''
            "[ Error ] $($ui.ERROR_ConfigNotSelected)"
            ''
            [System.Windows.Forms.MessageBox]::Show($ui.ERROR_ConfigNotSelected, $ui.FormTitle, 'OK', 'Error')
            exit 1
        }
        $selectForm.Dispose()
    }
    "[ Debug ] configFilePath = $configFilePath"

    # 显示环境信息
    Show-Log ($ui.INFO_SystemInfo -f $windowsVersion, $powerShellVersion) 'Info'
    Show-Log ($ui.MachineInfo -f $machineName, $userName) 'Info'
    Show-Log ($ui.INFO_BackupRootDir -f $backupDirectory) 'Info'
    Show-Log ($ui.ConfigSelected -f "[  $(Split-Path -Leaf $configFilePath)  ]") 'Info'

    # 加载配置文件
    function Load-Config {
        param([string]$FilePath = '')

        try {
            if (-not [System.IO.File]::Exists($FilePath)) {
                throw $ui.ERROR_ConfigNotFound
            }

            # 使用 [System.IO.File]::ReadAllText 以 UTF-8 读取，既显式指定编码，又避免在修改输出编码后于主线程调用 Get-Content 导致系统对话框显示英文界面
            # 注意：ConvertFrom-Json 会把整个数组作为单个对象输出到管道，直接用变量接收即为数组，不要再额外套 @()
            $configText = [System.IO.File]::ReadAllText($FilePath, $workingEncoding)
            $script:config = $configText | ConvertFrom-Json

            if ($config -isnot [System.Array]) {
                throw $ui.ERROR_ConfigNotArrayFormat
            }
            if ($config.Count -eq 0) {
                throw $ui.ERROR_ConfigEmptyCount
            }
            for ($i = 0; $i -lt $config.Count; $i++) {
                $game = $config[$i]
                if ($game -isnot [PSCustomObject]) {
                    throw ($ui.ERROR_ConfigItemNotObject -f ($i + 1))
                }
                if ($game.PSObject.Properties.Match('name').Count -eq 0) {
                    throw ($ui.ERROR_ConfigItemMissingName -f ($i + 1))
                }
                if ($game.PSObject.Properties.Match('save').Count -eq 0) {
                    throw ($ui.ERROR_ConfigItemMissingSave -f ($i + 1))
                }

                # 对 name 和 save 进行前后 trim 处理
                if ($game.name) { $game.name = $game.name.Trim() }
                if ($game.save) { $game.save = $game.save.Trim() }

                if ([string]::IsNullOrEmpty($game.name)) {
                    throw ($ui.ERROR_ConfigItemNameEmpty -f ($i + 1))
                }
                if ([string]::IsNullOrEmpty($game.save)) {
                    throw ($ui.ERROR_ConfigItemSaveEmpty -f ($i + 1))
                }
                if ($game.name.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ge 0) {
                    throw ($ui.ERROR_ConfigItemNameIllegalChars -f ($i + 1))
                }

                # 验证 ignore 必须为非空字符串构成的数组格式
                # JSON 数组只有 1 个元素时，ConvertFrom-Json 会解包为单个字符串，这里用 @() 归一为数组后回写，保证后续遍历正确
                if ($game.PSObject.Properties.Match('ignore').Count -gt 0) {
                    if ($game.ignore -is [PSCustomObject]) {
                        throw ($ui.ERROR_ConfigItemInvalidIgnore -f ($i + 1))
                    }
                    $ignoreList = @($game.ignore)
                    for ($j = 0; $j -lt $ignoreList.Count; $j++) {
                        $ignoreItem = [string]$ignoreList[$j]
                        if ($ignoreItem) { $ignoreItem = $ignoreItem.Trim() }
                        if ([string]::IsNullOrEmpty($ignoreItem)) {
                            throw ($ui.ERROR_ConfigItemInvalidIgnoreElement -f ($i + 1))
                        }
                        $ignoreList[$j] = $ignoreItem
                    }
                    $game.ignore = $ignoreList
                }
            }

            # 更新 UI 界面
            $configTextBox.Text = $FilePath
            Show-Log ($ui.ConfigLoaded -f $config.Count) 'Success'

            $dataGridView.SuspendLayout()
            try {
                $dataGridView.Rows.Clear()
                for ($i = 0; $i -lt $config.Count; $i++) {
                    $game = $config[$i]
                    $gameName = $game.name
                    $savePath = $game.save
                    $dataGridView.Rows.Add(($i + 1), $gameName, $savePath) | Out-Null
                }
            }
            finally {
                $dataGridView.ResumeLayout()
            }
            Show-Log ($ui.GameListUpdated) 'Info'

            if ($tabControl.TabPages.Contains($gameListTabPage) -eq $false) {
                $tabControl.Controls.Add($gameListTabPage)
            }
            $tabControl.SelectedTab = $gameListTabPage

            if ($config.Count -ge 1) {
                $startButton.Enabled = $true
            } else {
                $startButton.Enabled = $false
            }
        } catch {
            Handle-Exception $_
            Show-Log ($ui.ERROR_ConfigLoadFailed -f $_.Exception.Message) 'Error'
            $script:configFilePath = ''
            $script:config = $null
            $configTextBox.Text = ''
            $dataGridView.Rows.Clear()
            $tabControl.Controls.Remove($gameListTabPage)
            $startButton.Enabled = $false
        }
    }
    Load-Config -FilePath $configFilePath
} catch {
    Handle-Exception $_
    pause
    exit 1
}



# ———————————————————————————————— 5: 主界面功能实现 ————————————————————————————————

# 选择配置按钮
$fileDialogInitialDirectory = $backupDirectory
$browseButton.Add_Click({
    $fileDialog = [System.Windows.Forms.OpenFileDialog]::new()
    $fileDialog.Filter = $ui.FileFilter
    $fileDialog.Title = $ui.FileDialogTitle
    $fileDialog.InitialDirectory = $fileDialogInitialDirectory

    if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:configFilePath = $fileDialog.FileName
        $script:fileDialogInitialDirectory = (Split-Path -Parent $fileDialog.FileName)
        Show-Log ($ui.ConfigSelected -f "[  $(Split-Path -Leaf $configFilePath)  ]") 'Info'
        Load-Config -FilePath $configFilePath
    }
})

# 开始备份按钮
$isBackupRunning = $false
$backupPsInstance = $null
$backupAsyncResult = $null
$backupResultTimer = $null
$startButton.Add_Click({
    if ($isBackupRunning) {
        return
    }
    $script:isBackupRunning = $true

    $startButton.Enabled = $false
    $browseButton.Enabled = $false
    $tabControl.SelectedTab = $logTabPage
    $progressBar.Visible = $true
    $progressBar.Value = 0
    $asyncProgressState['Value'] = 0
    Show-Log $ui.BackupStarted 'Progress'

    $backupPs = {
        param($Ui, $Config, $MachineName, $UserName, $BackupDirectory, $WorkingEncoding, $AsyncShowLogQueue, $AsyncProgressState)

        # 外部函数在 Runspace 内不可见
        function Show-Log-Async {
            param([string]$Message = '', [string]$Level = 'Info')
            $AsyncShowLogQueue.Enqueue(@{ Message = $Message; Level = $Level })
        }

        function Run-Git-Command {
            param([string[]]$Arguments)

            $gitCommandLine = 'git ' + ($Arguments -join ' ')
            Show-Log-Async ($Ui.INFO_GitCommand + ": $gitCommandLine") 'Debug'
            $output = & git @Arguments 2>&1
            $exitCode = $LASTEXITCODE
            if ($exitCode -ne 0) {
                throw ($Ui.ERROR_GitCommandFailed -f $exitCode, ($output | Out-String))
            }
            $outputString = $output | Out-String
            if ($outputString.Trim()) {
                Show-Log-Async ($Ui.INFO_GitOutput + ":`r`n" + $outputString) 'Debug'
            }
            return $output
        }

        # 获取指定目录下所有文件的最新修改时间
        function Get-Max-File-Time {
            param([string]$DirectoryPath)

            $maxTicks = $null
            if ([System.IO.Directory]::Exists($DirectoryPath)) {
                foreach ($filePath in [System.IO.Directory]::GetFiles($DirectoryPath, '*', [System.IO.SearchOption]::AllDirectories)) {
                    $fileTicks = [System.IO.File]::GetLastWriteTime($filePath).Ticks
                    if ($null -eq $maxTicks -or $fileTicks -gt $maxTicks) {
                        $maxTicks = $fileTicks
                    }
                }
            }
            elseif ([System.IO.File]::Exists($DirectoryPath)) {
                $maxTicks = [System.IO.File]::GetLastWriteTime($DirectoryPath).Ticks
            }
            return $maxTicks
        }

        # 将文件的修改时间转换为显示字符串
        function Format-File-Time {
            param($FileTime)

            if ($null -eq $FileTime) {
                return ''
            }
            return [System.DateTime]::new($FileTime).ToString('yyyy-MM-dd HH:mm:ss')
        }

        # 执行 Robocopy 双向同步；恢复本地存档时，可先在目标侧移入回收站再写入
        function Run-Robocopy {
            param(
                [string]$Source,
                [string]$Destination,
                [bool]$MoveDestinationToRecycleBin = $false,
                [array]$IgnoreArgs = $null
            )

            if ($MoveDestinationToRecycleBin) {
                $sh = New-Object -ComObject Shell.Application
                try {
                    $sh.Namespace(10).MoveHere($Destination)
                }
                finally {
                    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($sh) | Out-Null
                }
            }

            $robocopyArgs = @('/MIR', '/COPY:DAT', '/DCOPY:T', '/R:10', '/W:3', '/NP', '/NS', '/NC', '/NFL', '/NDL', '/NJH')
            $robocopyCommand = "robocopy `"$Source`" `"$Destination`" " + ($robocopyArgs + $IgnoreArgs -join ' ')
            Show-Log-Async ($Ui.INFO_RobocopyCommand + ": $robocopyCommand") 'Debug'

            $result = & robocopy $Source $Destination @robocopyArgs $IgnoreArgs | Out-String
            $robocopyExitCode = $LASTEXITCODE

            if ($robocopyExitCode -ge 8) {
                Show-Log-Async ($Ui.INFO_RobocopyFailed -f $robocopyExitCode) 'Error'
                Show-Log-Async ($Ui.INFO_RobocopyReturn + ":`r`n" + $result) 'Debug'
                throw ($Ui.ERROR_RobocopyTaskFailed -f $robocopyExitCode)
            }

            Show-Log-Async ($Ui.INFO_RobocopySuccess -f $robocopyExitCode) 'Debug'
            Show-Log-Async ($Ui.INFO_RobocopyReturn + ":`r`n" + $result) 'Debug'
        }

        # 若暂存区存在变更，则提交 Git（按游戏名称生成提交信息）
        function Commit-Git-Changes {
            param([string]$CommitName)

            try {
                $null = Run-Git-Command -Arguments @('add', '.')

                $null = & git diff --cached --quiet 2>&1
                if ($LASTEXITCODE -ne 0) {
                    $commitMsg = 'Update - ' + $CommitName + ' on ' + $MachineName + ' by ' + $UserName
                    $null = Run-Git-Command -Arguments @('commit', '-m', $commitMsg)
                    Show-Log-Async $Ui.SUCCESS_GitCommit 'Success'
                }
            }
            catch {
                Show-Log-Async ("Git operation failed: $_") 'Error'
            }
        }

        # 切换到备份根目录（影响 git/robocopy 等外部程序）
        [System.IO.Directory]::SetCurrentDirectory($BackupDirectory)
        Set-Location -LiteralPath $BackupDirectory
        Show-Log-Async ($Ui.INFO_EnteringBackupDir -f $BackupDirectory) 'Info'

        # 检查 Git 组件
        $gitExe = Get-Command git.exe -ErrorAction SilentlyContinue
        if (-not $gitExe) {
            Show-Log-Async $Ui.ERROR_GitMissing 'Error'
            Show-Log-Async $Ui.ERROR_GitDownload 'Error'
            return
        }

        # 使用已加载的配置数组
        $totalGames = $Config.Count
        Show-Log-Async ($Ui.INFO_GamesFound + ': ' + $totalGames) 'Info'

        # 初始化 Git
        if (-not (Test-Path '.git')) {
            try {
                $null = & git init 2>&1 | Out-String
                $null = & git config --local core.autocrlf false 2>&1 | Out-String
                $null = & git config --local core.safecrlf false 2>&1 | Out-String
                $null = & git config --local core.ignorecase false 2>&1 | Out-String
                $null = & git config --local core.quotepath false 2>&1 | Out-String
                $null = & git config --local i18n.logoutputencoding utf-8 2>&1 | Out-String
                $null = & git config --local i18n.commitencoding utf-8 2>&1 | Out-String

                Show-Log-Async $Ui.SUCCESS_GitInitialized 'Success'
            }
            catch {
                Show-Log-Async ("Failed to initialize Git repository: $_") 'Error'
            }
        }

        $gameIndex = 0
        foreach ($game in $Config) {
            $gameIndex++
            $name = $game.name
            $save = $game.save
            $ignore = $game.ignore

            # 显示当前处理的游戏
            Show-Log-Async ($Ui.PROGRESS_Processing + ': ' + $gameIndex + ' / ' + $totalGames + " - '" + $name + "' @ '" + $save + "'") 'Progress'

            # 替换环境变量
            $saveExpanded = [System.Environment]::ExpandEnvironmentVariables($save)

            # 构建忽略参数
            $ignoreArgs = @()
            $ignoreArgs += '/XF'
            $ignoreArgs += 'SaveLocation.bat'
            $ignoreArgs += '/XF'
            $ignoreArgs += '存档位置.bat'

            # 获取当前语言对应的 bat 文件名（用于创建文件）
            $saveLocationBatName = $Ui.SaveLocationBatName

            if ($ignore) {
                foreach ($item in $ignore) {
                    $itemExpanded = [System.Environment]::ExpandEnvironmentVariables($item)
                    Show-Log-Async ($Ui.INFO_IgnoreItem + ": '" + $itemExpanded + "'") 'Debug'
                    $ignoreArgs += '/XF'
                    $ignoreArgs += $itemExpanded
                    $ignoreArgs += '/XD'
                    $ignoreArgs += $itemExpanded
                }
            }

            # 构建备份目录（在备份根目录下）
            $backupDir = Join-Path $BackupDirectory $name

            # 获取本地文件修改时间
            # 遍历失败时无法判断备份方向，跳过该游戏
            try {
                $maxLocalTime = Get-Max-File-Time -DirectoryPath $saveExpanded
            }
            catch {
                Show-Log-Async ($Ui.ERROR_GetFileTimeFailed -f $saveExpanded) 'Error'
                Show-Log-Async ($Ui.ERROR_ErrorDetails -f $_.Exception.Message) 'Error'
                continue
            }
            $maxLocalTimeString = Format-File-Time -FileTime $maxLocalTime

            # 获取备份文件修改时间
            try {
                $maxBackupTime = Get-Max-File-Time -DirectoryPath $backupDir
            }
            catch {
                Show-Log-Async ($Ui.ERROR_GetFileTimeFailed -f $backupDir) 'Error'
                Show-Log-Async ($Ui.ERROR_ErrorDetails -f $_.Exception.Message) 'Error'
                continue
            }
            $maxBackupTimeString = Format-File-Time -FileTime $maxBackupTime

            Show-Log-Async ($Ui.INFO_FileTimeComparison -f $maxLocalTimeString, $maxBackupTimeString) 'Info'

            # 创建备份目录
            if (-not (Test-Path $backupDir)) {
                try {
                    Show-Log-Async ($Ui.CreateBackupDir -f $backupDir) 'Info'
                    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
                }
                catch {
                    $errorMsg = $_.Exception.Message
                    Show-Log-Async ($Ui.ERROR_CreateBackupDirFailed -f $backupDir) 'Error'
                    Show-Log-Async ($Ui.ERROR_ErrorDetails -f $errorMsg) 'Error'
                    continue
                }
            }

            # 进入备份目录
            Set-Location -LiteralPath $backupDir
            Show-Log-Async ($Ui.INFO_EnteringBackupDir -f $backupDir) 'Info'

            # 判断备份策略
            if ($null -eq $maxLocalTime) {
                if ($null -eq $maxBackupTime) {
                    Show-Log-Async $Ui.WARNING_BothMissing 'Warning'
                }
                else {
                    Show-Log-Async $Ui.WARNING_LocalMissing 'Warning'
                    Run-Robocopy -Source '.' -Destination $saveExpanded -MoveDestinationToRecycleBin $true -IgnoreArgs $ignoreArgs
                }
            }
            else {
                $batContent = "chcp 65001 >nul`r`n"
                $batContent += "if not exist `"" + $saveExpanded + "`" mkdir `"" + $saveExpanded + "`"`r`n"
                $batContent += "`"explorer.exe`" `"" + $saveExpanded + "`""
                # 使用无 BOM 的 UTF-8 写入，避免 cmd 运行 bat 时首行出现乱码
                # 使用绝对路径写入游戏子目录（.NET 当前目录是备份根目录，不会随 Set-Location 改变）
                $saveLocationBatPath = Join-Path $backupDir $saveLocationBatName
                [System.IO.File]::WriteAllText($saveLocationBatPath, $batContent, $WorkingEncoding)
                [System.IO.File]::SetLastWriteTime($saveLocationBatPath, [System.DateTimeOffset]::FromUnixTimeSeconds(0).UtcDateTime)

                if ($null -eq $maxBackupTime) {
                    Show-Log-Async $Ui.INFO_BackupMissing 'Info'
                    Run-Robocopy -Source $saveExpanded -Destination '.' -IgnoreArgs $ignoreArgs
                    Commit-Git-Changes -CommitName $name
                }
                elseif ($maxLocalTime -lt $maxBackupTime) {
                    Show-Log-Async $Ui.WARNING_LocalOlder 'Warning'
                    Run-Robocopy -Source '.' -Destination $saveExpanded -MoveDestinationToRecycleBin $true -IgnoreArgs $ignoreArgs
                }
                elseif ($maxLocalTime -gt $maxBackupTime) {
                    Show-Log-Async $Ui.INFO_LocalNewer 'Info'
                    Run-Robocopy -Source $saveExpanded -Destination '.' -IgnoreArgs $ignoreArgs
                    Commit-Git-Changes -CommitName $name
                }
                else {
                    Show-Log-Async $Ui.INFO_SameTime 'Success'
                }
            }

            $AsyncProgressState['Value'] = [int](($gameIndex / $totalGames) * 90)
        }

        # 恢复工作目录到备份根目录
        Set-Location -LiteralPath $BackupDirectory
        Show-Log-Async ($Ui.INFO_EnteringBackupDir -f $BackupDirectory) 'Info'

        # 最终 Git 提交
        Run-Git-Command -Arguments @('add', '.')
        $null = & git diff --cached --quiet 2>&1
        if ($LASTEXITCODE -ne 0) {
            $commitMsg = 'Update - on ' + $MachineName + ' by ' + $UserName
            Run-Git-Command -Arguments @('commit', '-m', $commitMsg)
            Show-Log-Async $Ui.SUCCESS_FinalCommit 'Success'
        }

        # Git clean 操作
        $cleanOutput = & git clean -df 2>&1 | Out-String
        if ($cleanOutput -and $cleanOutput.Trim()) {
            Show-Log-Async ('Git clean output: ' + $cleanOutput) 'Debug'
        }

        $AsyncProgressState['Value'] = 100
    }

    # 创建执行实例
    $script:backupPsInstance = [System.Management.Automation.PowerShell]::Create()
    $backupPsInstance.RunspacePool = $backupRunspacePool
    $backupPsInstance.AddScript($backupPs)
    $backupPsInstance.AddParameter('Ui', $ui)
    $backupPsInstance.AddParameter('Config', $config)
    $backupPsInstance.AddParameter('MachineName', $machineName)
    $backupPsInstance.AddParameter('UserName', $userName)
    $backupPsInstance.AddParameter('BackupDirectory', $backupDirectory)
    $backupPsInstance.AddParameter('WorkingEncoding', $workingEncoding)
    $backupPsInstance.AddParameter('AsyncShowLogQueue', $asyncShowLogQueue)
    $backupPsInstance.AddParameter('AsyncProgressState', $asyncProgressState)

    # 开始异步执行
    $script:backupAsyncResult = $backupPsInstance.BeginInvoke()
    Show-Log $ui.RunspaceStarted 'Progress'

    # 轮询任务进度
    $script:backupResultTimer = [System.Windows.Forms.Timer]::new()
    $backupResultTimer.Interval = 200
    $backupResultTimer.Add_Tick({
        if ($backupAsyncResult.IsCompleted) {
            $this.Stop()
            try {
                $backupPsInstance.EndInvoke($backupAsyncResult)
                Show-Log $ui.SUCCESS_BackupComplete 'Success'
            }
            catch {
                Show-Log ($ui.ERROR_BackupTaskFailed -f $_) 'Error'
            }
            finally {
                if ($backupPsInstance) { $backupPsInstance.Dispose() }
                $startButton.Enabled = $true
                $browseButton.Enabled = $true
                $progressBar.Visible = $false
                $script:isBackupRunning = $false
                $this.Dispose()
            }
        }
    })
    $backupResultTimer.Start()
})

# 日志右键菜单: 复制日志
$copyLogMenuItem.Add_Click({
    if ($logTextBox.Text.Length -gt 0) {
        [System.Windows.Forms.Clipboard]::SetText($logTextBox.Text)
        Show-Log $ui.LogCopied 'Success'
    } else {
        Show-Log $ui.NoLog 'Warning'
    }
})

# 日志右键菜单: 清空日志
$clearLogMenuItem.Add_Click({
    $logTextBox.Clear()
})

# 列表右键菜单项: 动态启用/禁用及文本切换
$contextMenu.Add_Opening({
    $openLocationMenuItem.Enabled = $false
    $openLocationMenuItem.Text = $ui.OpenSaveLocationNotExist
    try {
        if ($dataGridView.SelectedRows.Count -eq 0) {
            return
        }
        $selectedRow = $dataGridView.SelectedRows[0]
        $savePath = $selectedRow.Cells[2].Value
        $realPath = [System.Environment]::ExpandEnvironmentVariables($savePath)
        if (Test-Path $realPath) {
            $openLocationMenuItem.Enabled = $true
            $openLocationMenuItem.Text = $ui.OpenSaveLocation
        }
    }
    catch {
        Handle-Exception $_
        Show-Log ($ui.ERROR_OpenSaveLocationFailed -f $_.Exception.Message) 'Error'
    }
})

# 列表右键菜单: 打开存档位置
$openLocationMenuItem.Add_Click({
    try {
        if ($dataGridView.SelectedRows.Count -eq 0) {
            return
        }
        $selectedRow = $dataGridView.SelectedRows[0]
        $gameName = $selectedRow.Cells[1].Value
        $savePath = $selectedRow.Cells[2].Value
        $realPath = [System.Environment]::ExpandEnvironmentVariables($savePath)
        if (Test-Path $realPath) {
            Start-Process 'explorer.exe' -ArgumentList $realPath
            Show-Log ($ui.OpeningSaveLocation -f $gameName, $realPath) 'Info'
        } else {
            Show-Log ($ui.SaveLocationNotExist -f $gameName, $realPath) 'Error'
        }
    }
    catch {
        Handle-Exception $_
        Show-Log ($ui.ERROR_OpenSaveLocationFailed -f $_.Exception.Message) 'Error'
    }
})



# ———————————————————————————————— 6: 程序启动 ————————————————————————————————

try {
    [System.Windows.Forms.Application]::Run($mainForm)
} catch {
    Handle-Exception $_
    pause
    exit 1
}
