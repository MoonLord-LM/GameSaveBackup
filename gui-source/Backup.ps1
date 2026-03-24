# 游戏存档备份工具
# 开源地址：https://github.com/MoonLord-LM/GameSaveBackup



# ———————————————————————————————— 1：基础设置和常量定义部分 ————————————————————————————————

# 加载窗体程序集
using assembly System.Windows.Forms
using assembly System.Drawing

# 使用命名空间简化代码
using namespace System.Windows.Forms
using namespace System.Drawing

# 设置字符编码 UTF-8
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 设置更现代的窗口样式
[Application]::EnableVisualStyles()
[Application]::SetCompatibleTextRenderingDefault($false)

# 界面支持中英文，定义多语言文本资源
$script:textResources = @{
    'zh-CN' = @{
        # 界面元素使用
        FormTitle = "游戏存档备份工具"
        ConfigLabel = "配置文件:"
        BrowseButton = "选择配置"
        StartButton = "开始备份"
        CopyLogButton = "复制日志"
        LogTabPage = "运行日志"
        GameListTabPage = "游戏列表"
        MachineInfo = "机器名：[ {0} ]  用户名：[ {1} ]"
        CheckingConfig = "正在检查配置文件..."
        ConfigLoaded = "成功加载配置文件，共 {0} 个游戏"
        GameListUpdated = "游戏列表已更新"
        ConfigNotFound = "当前目录下未找到 JSON 配置文件，将使用内嵌默认配置"
        ConfigSelected = "已选择配置文件："
        BackupStarted = "开始备份任务"
        RunspaceStarted = "Runspace 已启动，开始监控备份任务"
        LogCopied = "日志已复制到剪贴板"
        NoLog = "当前没有日志内容"
        ColumnIndex = "序号"
        ColumnGameName = "游戏名称"
        ColumnSavePath = "存档路径"
        FileFilter = "JSON 文件 (*.json)|*.json|所有文件 (*.*)|*.*"
        FileDialogTitle = "选择配置文件"
        DefaultConfigLoaded = "已加载内嵌默认配置文件，共 {0} 个游戏"
        OpenSaveLocation = "打开存档路径"
        BuiltInConfigDisplay = "内置配置 ({0} 个游戏)"
        OpeningSaveLocation = "正在打开存档位置：{0} - {1}"
        SaveLocationNotFound = "存档路径不存在，打开父目录：{0} - {1}"
        SaveLocationNotExist = "存档路径不存在：{0} - {1}"
        DirectoryCreated = "目录已创建：{0} - {1}"
        FailedToCreateDirectory = "创建目录失败：{0} - {1}"
        # 运行日志使用
        ERROR_GitMissing = "错误：缺少 git.exe 组件"
        ERROR_GitDownload = "请从 https://git-scm.com/install/windows 下载"
        ERROR_ConfigNotFound = "错误：选定的配置文件不存在"
        ERROR_ConfigInvalid = "配置文件格式错误"
        ERROR_ConfigMissingProperty = "配置文件缺少必需字段"
        ERROR_ConfigNotArray = "配置文件必须是 JSON 数组"
        ERROR_ConfigEmptyArray = "配置文件数组为空"
        ERROR_ConfigInvalidObject = "配置项不是有效对象"
        ERROR_ConfigEmptyName = "配置项名称为空"
        ERROR_ConfigEmptyPath = "配置项路径为空"
        INFO_UsingConfig = "使用配置文件"
        INFO_GitCommand = "Git 命令"
        INFO_RobocopyCommand = "Robocopy 命令"
        INFO_GamesFound = "找到游戏配置数量"
        INFO_MultipleConfigFound = "当前目录下找到 {0} 个 JSON 配置文件，请删除多余的，只保留一个"
        ERROR_DefaultConfigFailed = "内嵌默认配置加载失败"
        ERROR_ConfigLoadFailed = "JSON 配置文件加载失败"
        PROGRESS_Processing = "处理"
        INFO_IgnoreItem = "忽略项"
        INFO_CurrentWorkingDir = "当前工作目录"
        INFO_EnteringBackupDir = "进入备份目录"
        INFO_BackupRootDir = "备份根目录"
        ERROR_ConfigReadFailed = "读取配置文件失败"
        INFO_FileTimeComparison = "本地文件修改时间:[{0}] 备份文件修改时间:[{1}]"
        WARNING_BothMissing = "本地存档文件与备份文件都不存在，跳过操作"
        WARNING_LocalMissing = "本地存档文件缺失，使用备份文件恢复"
        INFO_BackupMissing = "备份文件缺失，进行备份"
        WARNING_LocalOlder = "本地存档文件修改时间较旧，删除到回收站，并使用备份文件更新"
        INFO_LocalNewer = "本地存档文件修改时间较新，进行备份"
        INFO_SameTime = "本地存档文件与备份文件修改时间相同，跳过操作"
        INFO_RobocopyReturn = "详细信息"
        INFO_RobocopySuccess = "Robocopy 执行成功（返回码 {0}）"
        INFO_RobocopyFailed = "Robocopy 执行失败（返回码 {0}）"
        INFO_GitExecuting = "正在执行 Git 命令"
        INFO_GitOutput = "Git 输出信息"
        SUCCESS_GitCommit = "Git 提交完成"
        SUCCESS_FinalCommit = "最终 Git 提交完成"
        SUCCESS_BackupComplete = "备份完成"
        SUCCESS_GitInitialized = "Git 仓库已初始化并配置"
        INFO_SystemInfo = "系统版本：[ {0} ]  PowerShell 版本：[ {1} ]"
    }
    'en-US' = @{
        # 界面元素使用
        FormTitle = "Game Save Backup Tool"
        ConfigLabel = "Config File:"
        BrowseButton = "Browse Config"
        StartButton = "Start Backup"
        CopyLogButton = "Copy Log"
        LogTabPage = "Run Log"
        GameListTabPage = "Game List"
        MachineInfo = "Machine: [ {0} ]  User: [ {1} ]"
        CheckingConfig = "Checking config file..."
        ConfigLoaded = "Config file loaded successfully, {0} game(s) found"
        GameListUpdated = "Game list updated"
        ConfigNotFound = "No JSON config file found in current directory, will use embedded default config"
        ConfigSelected = "Config file selected: "
        BackupStarted = "Starting backup task"
        RunspaceStarted = "Runspace started, monitoring backup task"
        LogCopied = "Log copied to clipboard"
        NoLog = "No log content"
        ColumnIndex = "#"
        ColumnGameName = "Game Name"
        ColumnSavePath = "Save Path"
        FileFilter = "JSON Files (*.json)|*.json|All Files (*.*)|*.*"
        FileDialogTitle = "Select Config File"
        DefaultConfigLoaded = "Embedded default config loaded, {0} game(s) found"
        OpenSaveLocation = "Open Save Path"
        BuiltInConfigDisplay = "Built-in Config ({0} games)"
        OpeningSaveLocation = "Opening save location: {0} - {1}"
        SaveLocationNotFound = "Save path not found, opening parent directory: {0} - {1}"
        SaveLocationNotExist = "Save location does not exist: {0} - {1}"
        DirectoryCreated = "Directory created: {0} - {1}"
        FailedToCreateDirectory = "Failed to create directory: {0} - {1}"
        # 运行日志使用
        ERROR_GitMissing = "Error: git.exe component is missing"
        ERROR_GitDownload = "Please download from https://git-scm.com/install/windows"
        ERROR_ConfigNotFound = "Error: Selected config file does not exist"
        ERROR_ConfigInvalid = "Invalid configuration file format"
        ERROR_ConfigMissingProperty = "Configuration missing required field"
        ERROR_ConfigNotArray = "Configuration must be a JSON array"
        ERROR_ConfigEmptyArray = "Configuration array is empty"
        ERROR_ConfigInvalidObject = "Configuration entry is not a valid object"
        ERROR_ConfigEmptyName = "Configuration entry name is empty"
        ERROR_ConfigEmptyPath = "Configuration entry path is empty"
        INFO_UsingConfig = "Using config file"
        INFO_GitCommand = "Git command"
        INFO_RobocopyCommand = "Robocopy command"
        INFO_GamesFound = "game(s) found in configuration"
        INFO_MultipleConfigFound = "Found {0} JSON config files in current directory. Please remove extra files and keep only one"
        ERROR_DefaultConfigFailed = "Failed to load embedded default config"
        ERROR_ConfigLoadFailed = "Failed to load JSON config file"
        PROGRESS_Processing = "Processing"
        INFO_IgnoreItem = "Ignore item"
        INFO_CurrentWorkingDir = "Current working directory"
        INFO_EnteringBackupDir = "Entering backup directory"
        INFO_BackupRootDir = "Backup root directory"
        ERROR_ConfigReadFailed = "Failed to read config file"
        INFO_FileTimeComparison = "Local file time:[{0}] Backup file time:[{1}]"
        WARNING_BothMissing = "Both local save and backup files are missing, skipping"
        WARNING_LocalMissing = "Local save file is missing, restoring from backup"
        INFO_BackupMissing = "Backup file is missing, performing backup"
        WARNING_LocalOlder = "Local save file is older, deleting to recycle bin and updating from backup"
        INFO_LocalNewer = "Local save file is newer, performing backup"
        INFO_SameTime = "Local and backup files have the same modification time, skipping"
        INFO_RobocopyReturn = "Details"
        INFO_RobocopySuccess = "Robocopy executed successfully (exit code {0})"
        INFO_RobocopyFailed = "Robocopy execution failed (exit code {0})"
        INFO_GitExecuting = "Executing Git command"
        INFO_GitOutput = "Git output"
        SUCCESS_GitCommit = "Git commit completed"
        SUCCESS_FinalCommit = "Final Git commit completed"
        SUCCESS_BackupComplete = "Backup completed successfully"
        SUCCESS_GitInitialized = "Git repository initialized and configured"
        INFO_SystemInfo = "System Version: [ {0} ]  PowerShell Version: [ {1} ]"
    }
}

# 内嵌的中英文默认 JSON 配置
$script:defaultJsonConfigs = @{
    'zh-CN' =
@'
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
    "name": "真三国无双 8：帝国",
    "save": "%USERPROFILE%\\Documents\\KoeiTecmo\\Dynasty Warriors 9 Empires"
  },
  {
    "name": "无双大蛇 3",
    "save": "%USERPROFILE%\\Documents\\KoeiTecmo\\WARRIORS OROCHI 4"
  },
  {
    "name": "真三国无双 5",
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
    "name": "博德之门 3",
    "save": "%USERPROFILE%\\AppData\\Local\\Larian Studios\\Baldur's Gate 3"
  },
  {
    "name": "三国志 8：重制版",
    "save": "%USERPROFILE%\\Documents\\KoeiTecmo\\SAN8R"
  },
  {
    "name": "光与影：33 号远征队",
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
    'en-US' =
@'
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

# 根据系统语言，自动选择界面语言的中英文
$script:uiLang = 'en-US'
try {
    $currentCulture = [System.Globalization.CultureInfo]::CurrentCulture.Name
    $currentUICulture = [System.Globalization.CultureInfo]::CurrentUICulture.Name
    $installedUICulture = [System.Globalization.CultureInfo]::InstalledUICulture.Name
    Write-Host "[ Debug ] currentCulture = $currentCulture"
    Write-Host "[ Debug ] currentUICulture = $currentUICulture"
    Write-Host "[ Debug ] installedUICulture = $installedUICulture"

    $zhCNCount = 0;
    $enUSCount = 0;
    if ($currentCulture -eq 'zh-CN') { $zhCNCount += 1 } else { $enUSCount += 1 }
    if ($currentUICulture -eq 'zh-CN') { $zhCNCount += 1 } else { $enUSCount += 1 }
    if ($installedUICulture -eq 'zh-CN') { $zhCNCount += 1 } else { $enUSCount += 1 }

    if ($zhCNCount -ge $enUSCount) {
        $script:uiLang = 'zh-CN'
    } else {
        $script:uiLang = 'en-US'
    }
} catch {
    Write-Host ""
    Write-Host "[ Error ] Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    Write-Host "[ Error ] Code: $($_.InvocationInfo.Line.Trim())" -ForegroundColor Red
    Write-Host "[ Error ] Message: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}
Write-Host "[ Debug ] script:uiLang = $script:uiLang"
$script:ui = $script:textResources[$script:uiLang]



# ———————————————————————————————— 2：界面绘制部分 ————————————————————————————————

# 创建主窗口
$form = [Form]::new()
$form.Text = $script:ui.FormTitle
$form.Size = [Size]::new(1280, 720)
$form.StartPosition = "CenterScreen"
$form.Font = [Font]::new("Microsoft YaHei", 10)
$form.MinimumSize = [Size]::new(1000, 600)

# 启用双缓冲减少闪烁
$flags = [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance
$prop = [Control].GetProperty("DoubleBuffered", $flags)
Write-Host "[ Debug ] DoubleBuffered default value = $($prop.GetValue($form))"
$prop.SetValue($form, $true)
Write-Host "[ Debug ] DoubleBuffered set value = $($prop.GetValue($form))"

# 创建顶部面板（操作区）
$topPanel = [Panel]::new()
$topPanel.Dock = "Top"
$topPanel.Height = 60
$topPanel.Padding = [Padding]::new(10, 10, 10, 10)

# 创建中部面板（内容区）
$centerPanel = [Panel]::new()
$centerPanel.Dock = "Fill"
$centerPanel.Padding = [Padding]::new(10, 0, 10, 0)

# 创建底部面板（提示区）
$bottomPanel = [Panel]::new()
$bottomPanel.Dock = "Bottom"
$bottomPanel.Height = 40
$bottomPanel.Padding = [Padding]::new(10, 10, 10, 10)

# 将三个面板添加到主窗口（注意顺序：先添加 Fill，再添加 Top/Bottom）
$form.Controls.Add($centerPanel)
$form.Controls.Add($topPanel)
$form.Controls.Add($bottomPanel)

# 顶部：左侧配置文件标签和文本框
$topInfoPanel = [Panel]::new()
$topInfoPanel.Dock = "Fill"
$topPanel.Controls.Add($topInfoPanel)

# 顶部：配置文件标签
$configLabel = [Label]::new()
$configLabel.Text = $script:ui.ConfigLabel
$configLabel.Location = [Point]::new(10, 8)
$configLabel.Size = [Size]::new(100, 40)
$topInfoPanel.Controls.Add($configLabel)

# 顶部：配置文件文本框
$configTextBox = [TextBox]::new()
$configTextBox.Anchor = "Left, Right"
$configTextBox.Location = [Point]::new(120, 5)
$configTextBox.Width = $topInfoPanel.Width - 130
$configTextBox.ReadOnly = $true
$topInfoPanel.Controls.Add($configTextBox)

# 顶部：右侧按钮组
$topButtonGroupPanel = [Panel]::new()
$topButtonGroupPanel.Dock = "Right"
$topButtonGroupPanel.Width = 420
$topPanel.Controls.Add($topButtonGroupPanel)

# 顶部：选择配置按钮
$browseButton = [Button]::new()
$browseButton.Text = $script:ui.BrowseButton
$browseButton.Location = [Point]::new(5, 0)
$browseButton.Size = [Size]::new(130, 36)
$browseButton.BackColor = [Color]::LightGreen
$topButtonGroupPanel.Controls.Add($browseButton)

# 顶部：开始备份按钮
$startButton = [Button]::new()
$startButton.Text = $script:ui.StartButton
$startButton.Location = [Point]::new(140, 0)
$startButton.Size = [Size]::new(130, 36)
$startButton.BackColor = [Color]::LightBlue
$startButton.Enabled = $false
$topButtonGroupPanel.Controls.Add($startButton)

# 顶部：复制日志按钮
$copyLogButton = [Button]::new()
$copyLogButton.Text = $script:ui.CopyLogButton
$copyLogButton.Location = [Point]::new(275, 0)
$copyLogButton.Size = [Size]::new(130, 36)
$topButtonGroupPanel.Controls.Add($copyLogButton)

# 中部：标签页容器
$tabControl = [TabControl]::new()
$tabControl.Dock = "Fill"
$tabControl.Padding = [Point]::new(20, 3)
$centerPanel.Controls.Add($tabControl)

# 中部：日志标签页
$logTabPage = [TabPage]::new()
$logTabPage.Text = $script:ui.LogTabPage
$tabControl.Controls.Add($logTabPage)

# 中部：游戏标签页
$gameListTabPage = [TabPage]::new()
$gameListTabPage.Text = $script:ui.GameListTabPage

# 中部：日志显示区域
$logTextBox = [RichTextBox]::new()
$logTextBox.ReadOnly = $true
$logTextBox.ScrollBars = [RichTextBoxScrollBars]::Vertical
$logTextBox.BorderStyle = [BorderStyle]::None
$logTextBox.BackColor = [Color]::White
$logTextBox.Dock = "Fill"
$logTabPage.Controls.Add($logTextBox)

# 中部：游戏信息显示表格
$gameDataGridView = [DataGridView]::new()
$gameDataGridView.ReadOnly = $true
$gameDataGridView.AllowUserToAddRows = $false
$gameDataGridView.AllowUserToDeleteRows = $false
$gameDataGridView.ScrollBars = [ScrollBars]::Both
$gameDataGridView.BorderStyle = [BorderStyle]::None
$gameDataGridView.BackgroundColor = [Color]::White
$gameDataGridView.ColumnHeadersDefaultCellStyle.BackColor = [Color]::LightGray
$gameDataGridView.ColumnHeadersHeight = 40
$gameDataGridView.RowTemplate.Height = 30
$gameDataGridView.Dock = "Fill"
$gameDataGridView.ColumnCount = 3
$gameDataGridView.Columns[0].Name = $script:ui.ColumnIndex
$gameDataGridView.Columns[0].Width = 60
$gameDataGridView.Columns[1].Name = $script:ui.ColumnGameName
$gameDataGridView.Columns[1].Width = 320
$gameDataGridView.Columns[2].Name = $script:ui.ColumnSavePath
$gameDataGridView.Columns[2].Width = 780
# 只允许单行选择
$gameDataGridView.SelectionMode = [DataGridViewSelectionMode]::FullRowSelect
$gameDataGridView.MultiSelect = $false
# 鼠标按下时自动选中一行（包括左键和右键）
$gameDataGridView.Add_CellMouseDown({
    param($sender, $e)
    if ($e.RowIndex -ge 0) {
        $gameDataGridView.ClearSelection()
        $gameDataGridView.Rows[$e.RowIndex].Selected = $true
        $gameDataGridView.CurrentCell = $gameDataGridView.Rows[$e.RowIndex].Cells[0]
    }
})
$gameListTabPage.Controls.Add($gameDataGridView)

# 创建右键菜单（打开存档位置）
$contextMenu = [ContextMenuStrip]::new()
$openLocationMenuItem = [ToolStripMenuItem]::new()
$openLocationMenuItem.Text = $script:ui.OpenSaveLocation
$contextMenu.Items.Add($openLocationMenuItem) | Out-Null
$gameDataGridView.ContextMenuStrip = $contextMenu

# 底部：进度条
$progressBar = [ProgressBar]::new()
$progressBar.Dock = "Fill"
$progressBar.Visible = $false
$progressBar.Style = [ProgressBarStyle]::Continuous
$bottomPanel.Controls.Add($progressBar)



# ———————————————————————————————— 3：功能实现部分 ————————————————————————————————

# 定义变量
$script:configPath = ""
$script:isRunning = $false
$script:configJsonArray = $null
$script:job = $null
$script:timer = $null
$script:asyncResult = $null
$script:psInstance = $null
$script:runspacePool = $null

# 使用同步集合来存储实时日志，可跨线程共享
$script:logQueue = [System.Collections.Concurrent.ConcurrentBag[string]]::new()



# 运行日志展示，根据日志等级设置颜色
$script:LogColorMap = @{
    Info     = [Color]::Black
    Success  = [Color]::Green
    Warning  = [Color]::DarkOrange
    Error    = [Color]::Red
    Progress = [Color]::Blue
    Debug    = [Color]::Gray
}
function Write-Log {
    param(
        [string]$Message = '',
        [string]$Level = 'Info'
    )

    try {
        if ($logTextBox.InvokeRequired) {
            $logTextBox.Invoke([Action]{
                Write-Log -Message $Message -Level $Level
            })
            return
        }

        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $color = if ($script:LogColorMap.ContainsKey($Level)) { 
            $script:LogColorMap[$Level] 
        } else { 
            [Color]::Black 
        }
        $text = "[{0}] {1}`r`n" -f $timestamp, $Message

        $logTextBox.SuspendLayout()
        try {
            $logTextBox.SelectionStart = $logTextBox.TextLength
            $logTextBox.SelectionLength = 0
            $logTextBox.SelectionColor = $color
            $logTextBox.AppendText($text)
            $logTextBox.ScrollToCaret()
        }
        finally {
            $logTextBox.ResumeLayout()
        }
    } catch {
        Write-Host ""
        Write-Host "[ Error ] Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
        Write-Host "[ Error ] Code: $($_.InvocationInfo.Line.Trim())" -ForegroundColor Red
        Write-Host "[ Error ] Message: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

# 展示系统版本和 PowerShell 版本信息
try {
    $script:osInfo = Get-WmiObject Win32_OperatingSystem
    $script:releaseId = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction SilentlyContinue
    $script:windowsVersion = "$($script:osInfo.Caption) $($script:releaseId.DisplayVersion)"
    $script:psVersion = "$($PSVersionTable.PSVersion.ToString()) $($PSVersionTable.PSEdition)"
    Write-Log ($script:ui.INFO_SystemInfo -f $script:windowsVersion, $script:psVersion) "Info"
} catch {
    Write-Host ""
    Write-Host "[ Error ] Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    Write-Host "[ Error ] Code: $($_.InvocationInfo.Line.Trim())" -ForegroundColor Red
    Write-Host "[ Error ] Message: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# 展示机器名和用户名信息
$script:machineName = & cmd /c hostname
$script:userName = [Environment]::UserName
Write-Log ($script:ui.MachineInfo -f $script:machineName, $script:userName) "Info"

# 加载内嵌的默认配置
function Load-DefaultConfig {
    try {
        $script:configPath = ""
        $script:configJsonArray = $script:defaultJsonConfigs[$script:uiLang] | ConvertFrom-Json

        $configTextBox.Text = $script:ui.BuiltInConfigDisplay -f $script:configJsonArray.Count
        Write-Log ($script:ui.DefaultConfigLoaded -f $script:configJsonArray.Count) "Success"

        $gameDataGridView.SuspendLayout()
        try {
            $gameDataGridView.Rows.Clear()
            for ($i = 0; $i -lt $script:configJsonArray.Count; $i++) {
                $game = $script:configJsonArray[$i]
                $gameName = $game.name
                $savePath = $game.save
                $gameDataGridView.Rows.Add(($i + 1), $gameName, $savePath) | Out-Null
            }
        }
        finally {
            $gameDataGridView.ResumeLayout()
        }
        Write-Log $script:ui.GameListUpdated "Info"

        if ($tabControl.TabPages.Contains($gameListTabPage) -eq $false) {
            $tabControl.Controls.Add($gameListTabPage)
        }
        $tabControl.SelectedTab = $gameListTabPage

        if ($script:configJsonArray.Count -ge 1) {
            $startButton.Enabled = $true
        } else {
            $startButton.Enabled = $false
        }
    }
    catch {
        Write-Host ""
        Write-Host "[ Error ] Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
        Write-Host "[ Error ] Code: $($_.InvocationInfo.Line.Trim())" -ForegroundColor Red
        Write-Host "[ Error ] Message: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""

        Write-Log ($script:ui.ERROR_DefaultConfigFailed + ": $($_.Exception.Message)") "Error"
        $script:configPath = ""
        $script:configJsonArray = $null
        $gameDataGridView.Rows.Clear()
        $tabControl.Controls.Remove($gameListTabPage)
        $startButton.Enabled = $false
    }
}

# 加载外部的 JSON 配置
function Load-JsonConfigFile {
    param([string]$ConfigPath)

    try {
        $script:configPath = $ConfigPath
        $script:configJsonArray = Get-Content -Path $script:configPath -Raw -Encoding UTF8 | ConvertFrom-Json

        $configTextBox.Text = $script:configPath
        Write-Log ($script:ui.ConfigLoaded -f $script:configJsonArray.Count) "Success"

        $gameDataGridView.SuspendLayout()
        try {
            $gameDataGridView.Rows.Clear()
            for ($i = 0; $i -lt $script:configJsonArray.Count; $i++) {
                $game = $script:configJsonArray[$i]
                $gameName = $game.name
                $savePath = $game.save
                $gameDataGridView.Rows.Add(($i + 1), $gameName, $savePath) | Out-Null
            }
        }
        finally {
            $gameDataGridView.ResumeLayout()
        }
        Write-Log $script:ui.GameListUpdated "Info"

        if ($tabControl.TabPages.Contains($gameListTabPage) -eq $false) {
            $tabControl.Controls.Add($gameListTabPage)
        }
        $tabControl.SelectedTab = $gameListTabPage

        if ($script:configJsonArray.Count -ge 1) {
            $startButton.Enabled = $true
        } else {
            $startButton.Enabled = $false
        }
    } catch {
        Write-Host ""
        Write-Host "[ Error ] Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
        Write-Host "[ Error ] Code: $($_.InvocationInfo.Line.Trim())" -ForegroundColor Red
        Write-Host "[ Error ] Message: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""

        Write-Log ($script:ui.ERROR_ConfigLoadFailed + ": $($_.Exception.Message)") "Error"
        $script:configPath = ""
        $script:configJsonArray = $null
        $gameDataGridView.Rows.Clear()
        $tabControl.Controls.Remove($gameListTabPage)
        $startButton.Enabled = $false
    }
}

# 自动查找并加载 JSON 配置文件
function Find-AndLoadJsonFile {
    $cd = [System.IO.Directory]::GetCurrentDirectory()
    Write-Host "[ Debug ] current directory = $cd"
    Write-Log ($script:ui.INFO_BackupRootDir + ": " + $cd) "Info"

    # 查找当前目录下的所有 JSON 文件
    $jsonFiles = Get-ChildItem -Path $cd -Filter "*.json" -File -ErrorAction SilentlyContinue

    # 情况 1：没有找到 JSON 文件 → 警告并使用默认配置
    if ($jsonFiles.Count -eq 0) {
        Write-Log $script:ui.ConfigNotFound "Warning"
        Load-DefaultConfig
        return
    }

    # 情况 2：找到多个 JSON 文件 → 告警并使用默认配置
    if ($jsonFiles.Count -gt 1) {
        Write-Log ($script:ui.INFO_MultipleConfigFound -f $jsonFiles.Count) "Warning"
        Load-DefaultConfig
        return
    }

    # 情况 3：找到唯一一个 JSON 文件 → 自动加载
    Write-Log ($script:ui.ConfigSelected + "$(Split-Path -Leaf $jsonFiles.FullName)") "Info"
    Load-JsonConfigFile -ConfigPath $jsonFiles.FullName
}

# 查找并加载 JSON 文件
Write-Log $script:ui.CheckingConfig "Info"
Find-AndLoadJsonFile

# 切换回日志标签页函数
function Show-LogPanel {
    $tabControl.SelectedTab = $logTabPage
}



# ———————————————————————————————— 事件处理和业务逻辑 ————————————————————————————————

# 右键菜单打开前的事件：动态启用/禁用菜单项
$contextMenu.Add_Opening({
    try {
        # 检查是否有选中的行
        if ($gameDataGridView.SelectedRows.Count -eq 0) {
            $openLocationMenuItem.Enabled = $false
            return
        }

        $selectedRow = $gameDataGridView.SelectedRows[0]
        $savePath = $selectedRow.Cells[2].Value

        # 还原环境变量显示
        $realPath = $savePath -replace '\$env:USERPROFILE', $env:USERPROFILE
        $realPath = $realPath -replace '\$env:PROGRAMDATA', $env:PROGRAMDATA

        # 只有当路径存在时才启用菜单项
        if (Test-Path $realPath) {
            $openLocationMenuItem.Enabled = $true
        } else {
            $openLocationMenuItem.Enabled = $false
        }
    }
    catch {
        # 出现错误时禁用菜单项
        $openLocationMenuItem.Enabled = $false
    }
})

# 右键菜单点击事件：打开存档位置
$openLocationMenuItem.Add_Click({
    try {
        # 获取选中的行
        if ($gameDataGridView.SelectedRows.Count -eq 0) {
            return
        }

        $selectedRow = $gameDataGridView.SelectedRows[0]
        $gameName = $selectedRow.Cells[1].Value
        $savePath = $selectedRow.Cells[2].Value

        # 还原环境变量显示
        $realPath = $savePath -replace '\$env:USERPROFILE', $env:USERPROFILE
        $realPath = $realPath -replace '\$env:PROGRAMDATA', $env:PROGRAMDATA

        # 检查路径是否存在
        if (Test-Path $realPath) {
            # 打开文件夹
            Start-Process "explorer.exe" -ArgumentList $realPath
            Write-Log ($script:ui.OpeningSaveLocation -f $gameName, $realPath) "Info"
        } else {
            # 路径不存在，尝试打开父目录
            $parentDir = Split-Path -Parent $realPath
            if (Test-Path $parentDir) {
                Start-Process "explorer.exe" -ArgumentList $parentDir
                Write-Log ($script:ui.SaveLocationNotFound -f $gameName, $parentDir) "Warning"
            } else {
                Write-Log ($script:ui.SaveLocationNotExist -f $gameName, $realPath) "Error"

                # 根据语言设置对话框文本
                $messageText = if ($script:uiLang -eq 'zh-CN') {
                    "存档路径不存在：`n$realPath`n`n是否要创建此目录？"
                } else {
                    "Archive path does not exist:`n$realPath`n`nDo you want to create this directory?"
                }
                $captionText = if ($script:uiLang -eq 'zh-CN') { "提示" } else { "Confirm" }

                $result = [MessageBox]::Show(
                    $messageText,
                    $captionText,
                    [MessageBoxButtons]::YesNo,
                    [MessageBoxIcon]::Question
                )

                if ($result -eq [DialogResult]::Yes) {
                    try {
                        New-Item -ItemType Directory -Path $realPath -Force | Out-Null
                        Start-Process "explorer.exe" -ArgumentList $realPath
                        Write-Log ($script:ui.DirectoryCreated -f $gameName, $realPath) "Success"
                    }
                    catch {
                        Write-Log ($script:ui.FailedToCreateDirectory -f $gameName, $_) "Error"
                    }
                }
            }
        }
    }
    catch {
        Write-Log "Failed to open save location: $_" "Error"
    }
})


# 浏览按钮点击事件
$browseButton.Add_Click({
    Write-Host "DEBUG: Globalization.CurrentCulture = $([System.Globalization.CultureInfo]::CurrentCulture.Name) " -ForegroundColor Cyan
    Write-Host "DEBUG: Globalization.CurrentUICulture = $([System.Globalization.CultureInfo]::CurrentUICulture.Name) " -ForegroundColor Cyan
    Write-Host "DEBUG: Application.CurrentCulture = $([Application]::CurrentCulture.Name) " -ForegroundColor Cyan
    Write-Host "DEBUG: Application.CurrentUICulture = $([Application]::CurrentUICulture.Name) " -ForegroundColor Cyan
    Write-Host "DEBUG: CurrentThread.CurrentCulture = $([System.Threading.Thread]::CurrentThread.CurrentCulture.Name) " -ForegroundColor Cyan
    Write-Host "DEBUG: CurrentThread.CurrentUICulture = $([System.Threading.Thread]::CurrentThread.CurrentUICulture.Name) " -ForegroundColor Cyan

    $fileDialog = [OpenFileDialog]::new()
    $fileDialog.Filter = $script:ui.FileFilter
    $fileDialog.Title = $script:ui.FileDialogTitle

    $fileDialog.InitialDirectory = [System.IO.Directory]::GetCurrentDirectory()

    if ($fileDialog.ShowDialog() -eq [DialogResult]::OK) {
        $script:configPath = $fileDialog.FileName
        $configTextBox.Text = $script:configPath
        Write-Log ($script:ui.ConfigSelected + $script:configPath) "Info"

        # 加载游戏列表（Load-JsonConfigFile 函数内部会在成功后切换到游戏列表标签页）
        Load-JsonConfigFile -ConfigPath $script:configPath

        # 如果加载成功，启用开始按钮
        if ($null -ne $script:configJsonArray) {
            $startButton.Enabled = $true
        }
    }
})

# 复制日志按钮点击事件
$copyLogButton.Add_Click({
    if ($logTextBox.Text.Length -gt 0) {
        [Clipboard]::SetText($logTextBox.Text)
        Write-Log $script:ui.LogCopied "Success"
    } else {
        Write-Log $script:ui.NoLog "Warning"
    }
})


# 开始备份按钮点击事件
$startButton.Add_Click({
    if ($global:isRunning) {
        return
    }

    # 切换回日志面板
    Show-LogPanel

    $global:isRunning = $true
    $startButton.Enabled = $false
    $browseButton.Enabled = $false
    $progressBar.Visible = $true
    $progressBar.Style = [ProgressBarStyle]::Continuous
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $progressBar.Value = 0

    Write-Log $script:ui.BackupStarted "Progress"

    # 创建 Runspace 池来执行备份任务
    $runspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, 1)
    $runspacePool.Open()

    # 创建 PowerShell 实例
    $psInstance = [System.Management.Automation.PowerShell]::Create()
    $psInstance.RunspacePool = $runspacePool

    # 添加要执行的脚本和参数
    $psInstance.AddScript({
        param($configPath, $machineName, $userName, $logQueue, $uiResources)

        function Test-GameConfig {
            param(
                [object]$Config,
                [System.Collections.Concurrent.ConcurrentBag[string]]$LogQueue,
                [hashtable]$UiResources
            )

            try {
                # 验证是否为数组
                if (-not ($Config -is [Array])) {
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [Error] " + $UiResources.ERROR_ConfigNotArray)
                    return $false
                }

                if ($Config.Count -eq 0) {
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [Error] " + $UiResources.ERROR_ConfigEmptyArray)
                    return $false
                }

                # 验证每个游戏配置
                for ($i = 0; $i -lt $Config.Count; $i++) {
                    $game = $Config[$i]

                    # 验证是否为对象
                    if (-not ($game -is [PSCustomObject])) {
                        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        $logQueue.Add("[$timestamp] [Error] " + $UiResources.ERROR_ConfigInvalidObject + " (index: $i)")
                        return $false
                    }

                    # 验证必需字段：name
                    if (-not $game.PSObject.Properties['name']) {
                        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        $logQueue.Add("[$timestamp] [Error] " + $UiResources.ERROR_ConfigMissingProperty + ": name (index: $i)")
                        return $false
                    }

                    if ([string]::IsNullOrWhiteSpace($game.name)) {
                        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        $logQueue.Add("[$timestamp] [Error] " + $UiResources.ERROR_ConfigEmptyName + " (index: $i)")
                        return $false
                    }

                    # 验证必需字段：save
                    if (-not $game.PSObject.Properties['save']) {
                        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        $logQueue.Add("[$timestamp] [Error] " + $UiResources.ERROR_ConfigMissingProperty + ": save (index: $i)")
                        return $false
                    }

                    if ([string]::IsNullOrWhiteSpace($game.save)) {
                        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        $logQueue.Add("[$timestamp] [Error] " + $UiResources.ERROR_ConfigEmptyPath + " (index: $i)")
                        return $false
                    }
                }

                return $true
            }
            catch {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Error] " + $UiResources.ERROR_ConfigInvalid + ": $_")
                return $false
            }
        }

        function Invoke-GitCommand {
            param(
                [string]$Arguments,
                [string]$ErrorMessage,
                [System.Collections.Concurrent.ConcurrentBag[string]]$LogQueue,
                [hashtable]$UiResources
            )

            try {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Debug] " + $UiResources.INFO_GitCommand + ": git $Arguments")

                # 执行 Git 命令并捕获所有输出
                $output = & git $Arguments.Split(' ') 2>&1 | Out-String
                $exitCode = $LASTEXITCODE

                # 记录 Git 输出
                if ($output -and $output.Trim()) {
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [Debug] " + $UiResources.INFO_GitOutput + ":`r`n" + $output)
                }

                if ($exitCode -ne 0) {
                    throw "$ErrorMessage (Exit Code: $exitCode): $output"
                }

                return $output
            }
            catch {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Error] $_")
                throw
            }
        }

        # 获取脚本所在目录作为备份根目录
        $cd = [System.IO.Directory]::GetCurrentDirectory()
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_CurrentWorkingDir + ": " + $cd)
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_BackupRootDir + ": " + $cd)

        # 检查 Git
        $gitExe = Get-Command git -ErrorAction SilentlyContinue
        if (-not $gitExe) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [Error] " + $uiResources.ERROR_GitMissing)
            $logQueue.Add("[$timestamp] [Error] " + $uiResources.ERROR_GitDownload)
            return
        }

        # 验证选定的配置文件是否存在
        if (-not (Test-Path $configPath)) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [Error] " + $uiResources.ERROR_ConfigNotFound + ": " + $configPath)
            return
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_UsingConfig + ": " + (Split-Path -Leaf $configPath))

        # 读取配置文件并验证
        try {
            $configContent = Get-Content -Path $configPath -Raw -Encoding UTF8
            $configArray = $configContent | ConvertFrom-Json

            # 验证配置文件格式
            if (-not (Test-GameConfig -Config $configArray -LogQueue $logQueue -UiResources $uiResources)) {
                return
            }

            $totalGames = $configArray.Count
        }
        catch {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [ERROR] " + $uiResources.ERROR_ConfigReadFailed + ": " + $_)
            return
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_GamesFound + ": " + $totalGames)

        # 初始化 Git
        if (-not (Test-Path ".git")) {
            try {
                $null = & git init 2>&1 | Out-String
                $null = & git config --local core.autocrlf false 2>&1 | Out-String
                $null = & git config --local core.safecrlf false 2>&1 | Out-String
                $null = & git config --local core.ignorecase false 2>&1 | Out-String
                $null = & git config --local core.quotepath false 2>&1 | Out-String
                $null = & git config --local i18n.logoutputencoding utf-8 2>&1 | Out-String
                $null = & git config --local i18n.commitencoding utf-8 2>&1 | Out-String

                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Success] " + $uiResources.SUCCESS_GitInitialized)
            }
            catch {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Error] Failed to initialize Git repository: $_")
            }
        }

        $gameIndex = 0
        foreach ($game in $configArray) {
            $gameIndex++
            $name = $game.name
            $save = $game.save
            $ignore = $game.ignore

            # 显示当前处理的遊戲
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [Progress] " + $uiResources.PROGRESS_Processing + ": " + $gameIndex + " / " + $totalGames + " - '" + $name + "' @ '" + $save + "'")

            # 替换环境变量
            $saveExpanded = $save -replace "%USERPROFILE%", $env:USERPROFILE
            $saveExpanded = $saveExpanded -replace "%PROGRAMDATA%", $env:PROGRAMDATA

            # 构建忽略参数
            $ignoreArgs = @()
            $ignoreArgs += "/XF"
            $ignoreArgs += "SaveLocation.bat"
            $ignoreArgs += "/XF"
            $ignoreArgs += "存档位置.bat"

            if ($ignore) {
                foreach ($item in $ignore) {
                    $itemExpanded = $item -replace "%USERPROFILE%", $env:USERPROFILE
                    $itemExpanded = $itemExpanded -replace "%PROGRAMDATA%", $env:PROGRAMDATA
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_IgnoreItem + ": '" + $itemExpanded + "'")
                    $ignoreArgs += "/XF"
                    $ignoreArgs += $itemExpanded
                    $ignoreArgs += "/XD"
                    $ignoreArgs += $itemExpanded
                }
            }

            # 构建备份目录（在脚本所在目录下）
            $backupDir = Join-Path $scriptDir $name

            # 获取本地文件修改时间
            $maxLocalTime = $null
            $maxLocalTimeString = ""
            if (Test-Path $saveExpanded) {
                try {
                    $files = Get-ChildItem -Recurse -Path $saveExpanded -File -ErrorAction SilentlyContinue
                    if ($files) {
                        $latestFile = $files | Sort-Object LastWriteTime -Descending | Select-Object -First 1
                        $maxLocalTime = $latestFile.LastWriteTime.Ticks
                        $maxLocalTimeString = $latestFile.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss UTC")
                    }
                }
                catch {}
            }

            # 获取备份文件修改时间
            $maxBackupTime = $null
            $maxBackupTimeString = ""
            if (Test-Path $backupDir) {
                try {
                    $files = Get-ChildItem -Recurse -Path $backupDir -File -ErrorAction SilentlyContinue
                    if ($files) {
                        $latestFile = $files | Sort-Object LastWriteTime -Descending | Select-Object -First 1
                        $maxBackupTime = $latestFile.LastWriteTime.Ticks
                        $maxBackupTimeString = $latestFile.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss UTC")
                    }
                }
                catch {}
            }

            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [INFO] " + ($uiResources.INFO_FileTimeComparison -f $maxLocalTimeString, $maxBackupTimeString))

            # 创建备份目录
            if (-not (Test-Path $backupDir)) {
                New-Item -ItemType Directory -Path $backupDir | Out-Null
            }

            # 进入备份目录
            Push-Location $backupDir

            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_EnteringBackupDir + ": " + (Get-Location).Path)

            # 判断备份策略
            if ($null -eq $maxLocalTime) {
                if ($null -eq $maxBackupTime) {
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [Warning] " + $uiResources.WARNING_BothMissing)
                }
                else {
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [Warning] " + $uiResources.WARNING_LocalMissing)
                    $sh = New-Object -ComObject Shell.Application
                    $sh.Namespace(10).MoveHere($saveExpanded)

                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $robocopyCommand = "robocopy . `"$saveExpanded`" /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH"
                    $logQueue.Add("[$timestamp] [Debug] " + $uiResources.INFO_RobocopyCommand + ": $robocopyCommand")

                    $result = & robocopy . $saveExpanded /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs | Out-String
                    $robocopyExitCode = $LASTEXITCODE

                    # 记录 Robocopy 状态（包含返回码）
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    if ($robocopyExitCode -ge 8) {
                        $logQueue.Add("[$timestamp] [Debug] " + ($uiResources.INFO_RobocopyFailed -f $robocopyExitCode))
                    } else {
                        $logQueue.Add("[$timestamp] [Debug] " + ($uiResources.INFO_RobocopySuccess -f $robocopyExitCode))
                    }

                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [Debug] " + $uiResources.INFO_RobocopyReturn + ":`r`n" + $result)
                }
            }
            elseif ($null -eq $maxBackupTime) {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_BackupMissing)
                if (-not (Test-Path "存档位置.bat")) {
                    $batContent = "if not exist `"" + $saveExpanded + "`" mkdir `"" + $saveExpanded + "`"`r`n"
                    $batContent += "`"explorer.exe`" `"" + $saveExpanded + "`""
                    Set-Content -Path "存档位置.bat" -Value $batContent -Encoding UTF8
                    (Get-Item "存档位置.bat").LastWriteTime = [DateTimeOffset]::FromUnixTimeSeconds(0).UtcDateTime
                }

                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $robocopyCommand = "robocopy `"$saveExpanded`" . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH"
                $logQueue.Add("[$timestamp] [Debug] " + $uiResources.INFO_RobocopyCommand + ": $robocopyCommand")

                $result = & robocopy $saveExpanded . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs | Out-String
                $robocopyExitCode = $LASTEXITCODE

                # 记录 Robocopy 状态（包含返回码）
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                if ($robocopyExitCode -ge 8) {
                    $logQueue.Add("[$timestamp] [Debug] " + ($uiResources.INFO_RobocopyFailed -f $robocopyExitCode))
                } else {
                    $logQueue.Add("[$timestamp] [Debug] " + ($uiResources.INFO_RobocopySuccess -f $robocopyExitCode))
                }

                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Debug] " + $uiResources.INFO_RobocopyReturn + ":`r`n" + $result)

                try {
                    $null = Invoke-GitCommand -Arguments "add ." -ErrorMessage "Git add failed" -LogQueue $logQueue -UiResources $uiResources

                    $diffResult = & git diff --cached --quiet 2>&1
                    if ($LASTEXITCODE -ne 0) {
                        $commitMsg = "Update - " + $name + " on " + $machineName + " by " + $userName
                        $null = Invoke-GitCommand -Arguments "commit -m `"$commitMsg`"" -ErrorMessage "Git commit failed" -LogQueue $logQueue -UiResources $uiResources
                        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        $logQueue.Add("[$timestamp] [Success] " + $uiResources.SUCCESS_GitCommit)
                    }
                }
                catch {
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [Error] Git operation failed: $_")
                }
            }
            elseif ($maxLocalTime -lt $maxBackupTime) {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Warning] " + $uiResources.WARNING_LocalOlder)
                $sh = New-Object -ComObject Shell.Application
                $sh.Namespace(10).MoveHere($saveExpanded)

                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $robocopyCommand = "robocopy . `"$saveExpanded`" /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH"
                $logQueue.Add("[$timestamp] [Debug] " + $uiResources.INFO_RobocopyCommand + ": $robocopyCommand")

                $result = & robocopy . $saveExpanded /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs | Out-String
                $robocopyExitCode = $LASTEXITCODE

                # 记录 Robocopy 状态（包含返回码）
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                if ($robocopyExitCode -ge 8) {
                    $logQueue.Add("[$timestamp] [Debug] " + ($uiResources.INFO_RobocopyFailed -f $robocopyExitCode))
                } else {
                    $logQueue.Add("[$timestamp] [Debug] " + ($uiResources.INFO_RobocopySuccess -f $robocopyExitCode))
                }

                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Debug] " + $uiResources.INFO_RobocopyReturn + ":`r`n" + $result)
            }
            elseif ($maxLocalTime -gt $maxBackupTime) {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_LocalNewer)

                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $robocopyCommand = "robocopy `"$saveExpanded`" . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH"
                $logQueue.Add("[$timestamp] [Debug] " + $uiResources.INFO_RobocopyCommand + ": $robocopyCommand")

                $result = & robocopy $saveExpanded . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs | Out-String
                $robocopyExitCode = $LASTEXITCODE

                # 记录 Robocopy 状态（包含返回码）
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                if ($robocopyExitCode -ge 8) {
                    $logQueue.Add("[$timestamp] [Debug] " + ($uiResources.INFO_RobocopyFailed -f $robocopyExitCode))
                } else {
                    $logQueue.Add("[$timestamp] [Debug] " + ($uiResources.INFO_RobocopySuccess -f $robocopyExitCode))
                }

                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Debug] " + $uiResources.INFO_RobocopyReturn + ":`r`n" + $result)

                try {
                    $null = Invoke-GitCommand -Arguments "add ." -ErrorMessage "Git add failed" -LogQueue $logQueue -UiResources $uiResources

                    $diffResult = & git diff --cached --quiet 2>&1
                    if ($LASTEXITCODE -ne 0) {
                        $commitMsg = "Update - " + $name + " on " + $machineName + " by " + $userName
                        $null = Invoke-GitCommand -Arguments "commit -m `"$commitMsg`"" -ErrorMessage "Git commit failed" -LogQueue $logQueue -UiResources $uiResources
                        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        $logQueue.Add("[$timestamp] [Success] " + $uiResources.SUCCESS_GitCommit)
                    }
                }
                catch {
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [Error] Git operation failed: $_")
                }
            }
            else {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Success] " + $uiResources.INFO_SameTime)
            }

            # 恢复工作目录到配置目录（重要！避免目录层级越来越深）
            Pop-Location

            # 游戏处理完成后，发送进度更新信号
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] PROGRESS_SIGNAL: $gameIndex|$totalGames")
        }

        # 最终 Git 提交
        try {
            $null = Invoke-GitCommand -Arguments "add ." -ErrorMessage "Final Git add failed" -LogQueue $logQueue -UiResources $uiResources

            $diffResult = & git diff --cached --quiet 2>&1
            if ($LASTEXITCODE -ne 0) {
                $commitMsg = "Update - on " + $machineName + " by " + $userName
                $null = Invoke-GitCommand -Arguments "commit -m `"$commitMsg`"" -ErrorMessage "Final Git commit failed" -LogQueue $logQueue -UiResources $uiResources
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Success] " + $uiResources.SUCCESS_FinalCommit)
            }
        }
        catch {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [Error] Final Git operation failed: $_")
        }

        # Git clean 操作
        try {
            $cleanOutput = & git clean -df 2>&1 | Out-String
            if ($cleanOutput -and $cleanOutput.Trim()) {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Debug] Git clean output: " + $cleanOutput)
            }
        }
        catch {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [Warning] Git clean failed: $_")
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logQueue.Add("[$timestamp] [Success] " + $uiResources.SUCCESS_BackupComplete)
    })

    $psInstance.AddParameter('configPath', $global:configPath)
    $psInstance.AddParameter('machineName', $script:machineName)
    $psInstance.AddParameter('userName', $script:userName)
    $psInstance.AddParameter('logQueue', $global:logQueue)
    $psInstance.AddParameter('uiResources', $script:ui)

    # 异步执行
    $global:asyncResult = $psInstance.BeginInvoke()
    $global:psInstance = $psInstance
    $global:runspacePool = $runspacePool

    # 创建并启动 Timer
    $global:timer = [Timer]::new()
    $global:timer.Interval = 100  # 缩短轮询间隔到 100ms，更快响应
    $global:timer.Add_Tick({
        # 从同步集合中读取并显示日志
        try {
            if ($null -ne $global:logQueue -and -not $global:logQueue.IsEmpty) {
                $logLine = ""
                while ($global:logQueue.TryTake([ref]$logLine)) {
                    # 直接显示完整日志行
                    # 格式：[timestamp] [Level] Message
                    $firstBracketEnd = $logLine.IndexOf(']', $logLine.IndexOf('['))

                    if ($firstBracketEnd -gt 0) {
                        # 提取完整消息 (包含所有原始内容)
                        $message = $logLine.Substring($firstBracketEnd + 2).Trim()

                        # 处理进度信号
                        if ($message.StartsWith("PROGRESS_SIGNAL:")) {
                            $signalValue = $message.Substring(16).Trim()
                            $signalParts = $signalValue -split '\|'
                            if ($signalParts.Count -eq 2) {
                                $current = [int]$signalParts[0]
                                $total = [int]$signalParts[1]
                                $targetPercentage = [int](($current / $total) * 100)
                                $progressBar.Value = $targetPercentage
                            }
                        }
                        # 显示其他完整日志（带颜色）
                        elseif (-not [string]::IsNullOrWhiteSpace($message)) {
                            # 默认级别为 Info
                            $level = "Info"

                            # 检查是否有级别标记 [Level]
                            if ($message -match "^\[(Error|Warning|Success|Info|Progress|Debug)\] ") {
                                $level = $matches[1]
                                # 移除级别标记，只保留实际消息
                                $message = $message -replace "^\[(Error|Warning|Success|Info|Progress|Debug)\] ", ""
                            }

                            Write-Log $message $level
                        }
                    }
                }
            }
        }
        catch {
            # 忽略读取错误
        }

        # 检查是否完成
        if ($global:asyncResult.IsCompleted) {
            $global:timer.Stop()

            # 清空剩余的日志
            try {
                if ($null -ne $global:logQueue -and -not $global:logQueue.IsEmpty) {
                    $logLine = ""
                    while ($global:logQueue.TryTake([ref]$logLine)) {
                        # 提取完整日志内容
                        $firstBracketEnd = $logLine.IndexOf(']', $logLine.IndexOf('['))

                        if ($firstBracketEnd -gt 0) {
                            $message = $logLine.Substring($firstBracketEnd + 2).Trim()
                            # 跳过进度信号，显示其他日志（带颜色）
                            if (-not $message.StartsWith("PROGRESS_SIGNAL:") -and -not [string]::IsNullOrWhiteSpace($message)) {
                                # 默认级别为 Info
                                $level = "Info"

                                # 检查是否有级别标记 [Level]（不区分大小写）
                                if ($message -match "(?i)^\[(Error|Warning|Success|Info|Progress|Debug)\] ") {
                                    $level = $matches[1]
                                    # 移除级别标记，只保留实际消息
                                    $message = $message -replace "(?i)^\[(Error|Warning|Success|Info|Progress|Debug)\] ", ""
                                }

                                Write-Log $message $level
                            }
                        }
                    }
                }
            }
            catch {}

            $progressBar.Value = 100
            $progressBar.Visible = $false
            $startButton.Enabled = $true
            $browseButton.Enabled = $true
            $global:isRunning = $false

            # 清理资源
            if ($global:timer) { $global:timer.Stop(); $global:timer.Dispose() }
            if ($global:asyncResult) { $global:asyncResult.AsyncWaitHandle.Close() }
            if ($global:job) { Stop-Job -Job $global:job; Remove-Job -Job $global:job -Force }
            if ($global:psInstance) { $global:psInstance.Dispose() }
            if ($global:runspacePool) {
                $global:runspacePool.Close()
                $global:runspacePool.Dispose()
            }
            [GC]::Collect()
        }
    })
    $global:timer.Start()

    Write-Log $script:ui.RunspaceStarted "Progress"
})

# 显示窗口
[Application]::Run($form);
