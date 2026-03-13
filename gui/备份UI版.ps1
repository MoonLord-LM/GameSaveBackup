# 设置字符编码 UTF-8
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 加载 Windows Forms 程序集
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 根据系统语言自动选择界面语言
try {
    $systemLang = [System.Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName
    if ($systemLang -eq 'zh') {
        $script:uiLang = 'zh'
    } else {
        $script:uiLang = 'en'
    }

    # DEBUG 测试国际化使用，勿删
    $script:uiLang = 'en'
} catch {
    $script:uiLang = 'en'
}

# 定义多语言资源
$script:resources = @{
    'zh' = @{
        FormTitle = "游戏存档备份工具"
        ConfigLabel = "配置文件:"
        BrowseButton = "选择配置"
        StartButton = "开始备份"
        CopyLogButton = "复制日志"
        LogTabPage = "运行日志"
        GameListTabPage = "游戏列表"
        MachineInfo = "机器名：{0}  用户名：{1}"
        ScanningConfig = "正在扫描配置文件..."
        ConfigLoaded = "成功加载配置文件，共 {0} 个游戏"
        GameListUpdated = "游戏列表已更新"
        ConfigNotFound = "警告：当前目录下未找到 [.json] 配置文件"
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
        # 备份任务日志
        ERROR_GitMissing = "错误：缺少 git.exe 组件"
        ERROR_GitDownload = "请从 https://git-scm.com/install/windows 下载"
        ERROR_ConfigNotFound = "错误：选定的配置文件不存在"
        INFO_UsingConfig = "使用配置文件"
        INFO_GamesFound = "找到游戏配置数量"
        PROGRESS_Processing = "处理"
        INFO_IgnoreItem = "忽略项"
        INFO_CurrentWorkingDir = "当前工作目录"
        INFO_EnteringBackupDir = "进入备份目录"
        ERROR_ConfigReadFailed = "读取配置文件失败"
        INFO_FileTimeComparison = "本地文件修改时间:[{0}] 备份文件修改时间:[{1}]"
        WARNING_BothMissing = "本地存档文件与备份文件都不存在，跳过操作"
        WARNING_LocalMissing = "本地存档文件缺失，使用备份文件恢复"
        INFO_BackupMissing = "备份文件缺失，进行备份"
        WARNING_LocalOlder = "本地存档文件修改时间较旧，删除到回收站，并使用备份文件更新"
        INFO_LocalNewer = "本地存档文件修改时间较新，进行备份"
        INFO_SameTime = "本地存档文件与备份文件修改时间相同，跳过操作"
        INFO_RobocopyReturn = "Robocopy 返回信息"
        SUCCESS_GitCommit = "Git 提交完成"
        SUCCESS_FinalCommit = "最终 Git 提交完成"
        SUCCESS_BackupComplete = "备份完成"
    }
    'en' = @{
        FormTitle = "Game Save Backup Tool"
        ConfigLabel = "Config File:"
        BrowseButton = "Browse Config"
        StartButton = "Start Backup"
        CopyLogButton = "Copy Log"
        LogTabPage = "Run Log"
        GameListTabPage = "Game List"
        MachineInfo = "Machine: {0}  User: {1}"
        ScanningConfig = "Scanning config file..."
        ConfigLoaded = "Config file loaded successfully, {0} game(s) found"
        GameListUpdated = "Game list updated"
        ConfigNotFound = "Warning: No [.json] config file found in current directory"
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
        # Backup Task Logs
        ERROR_GitMissing = "Error: git.exe component is missing"
        ERROR_GitDownload = "Please download from https://git-scm.com/install/windows"
        ERROR_ConfigNotFound = "Error: Selected config file does not exist"
        INFO_UsingConfig = "Using config file"
        INFO_GamesFound = "game(s) found in configuration"
        PROGRESS_Processing = "Processing"
        INFO_IgnoreItem = "Ignore item"
        INFO_CurrentWorkingDir = "Current working directory"
        INFO_EnteringBackupDir = "Entering backup directory"
        ERROR_ConfigReadFailed = "Failed to read config file"
        INFO_FileTimeComparison = "Local file time:[{0}] Backup file time:[{1}]"
        WARNING_BothMissing = "Both local save and backup files are missing, skipping"
        WARNING_LocalMissing = "Local save file is missing, restoring from backup"
        INFO_BackupMissing = "Backup file is missing, performing backup"
        WARNING_LocalOlder = "Local save file is older, deleting to recycle bin and updating from backup"
        INFO_LocalNewer = "Local save file is newer, performing backup"
        INFO_SameTime = "Local and backup files have the same modification time, skipping"
        INFO_RobocopyReturn = "Robocopy return info"
        SUCCESS_GitCommit = "Git commit completed"
        SUCCESS_FinalCommit = "Final Git commit completed"
        SUCCESS_BackupComplete = "Backup completed successfully"
    }
}

# 获取当前语言的 UI 文本
$script:ui = $script:resources[$script:uiLang]

# 创建主窗口
$form = New-Object System.Windows.Forms.Form
$form.Text = $script:ui.FormTitle
$form.Size = New-Object System.Drawing.Size(1280, 720)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Microsoft YaHei", 10)

# 创建顶部面板（操作区）
$topPanel = New-Object System.Windows.Forms.Panel
$topPanel.Dock = "Top"
$topPanel.Size = New-Object System.Drawing.Size(1280, 60)
$topPanel.Padding = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

# 创建中部面板（内容区）
$centerPanel = New-Object System.Windows.Forms.Panel
$centerPanel.Dock = "Fill"
$centerPanel.Padding = New-Object System.Windows.Forms.Padding(10, 0, 10, 0)

# 创建底部面板（提示区）
$bottomPanel = New-Object System.Windows.Forms.Panel
$bottomPanel.Dock = "Bottom"
$bottomPanel.Size = New-Object System.Drawing.Size(1280, 40)
$bottomPanel.Padding = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

# DEBUG 调试布局使用，勿删
# $topPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
# $centerPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
# $bottomPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

# 将三个面板添加到主窗口（注意顺序：先添加 Fill，再添加 Top/Bottom）
$form.Controls.Add($centerPanel)
$form.Controls.Add($topPanel)
$form.Controls.Add($bottomPanel)

# 配置文件标签和文本框
$configLabel = New-Object System.Windows.Forms.Label
$configLabel.Text = $script:ui.ConfigLabel
$configLabel.Location = New-Object System.Drawing.Point(15, 20)
$configLabel.AutoSize = $true
$topPanel.Controls.Add($configLabel)

# 配置文件文本框 - 使用 Anchor 实现自适应
$configTextBox = New-Object System.Windows.Forms.TextBox
$configTextBox.Location = New-Object System.Drawing.Point(95, 18)
$configTextBox.Size = New-Object System.Drawing.Size(800, 50)
$configTextBox.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$configTextBox.ReadOnly = $true
$topPanel.Controls.Add($configTextBox)

# 选择配置按钮 - 固定在右侧最左边
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = $script:ui.BrowseButton
$browseButton.Location = New-Object System.Drawing.Point(900, 15)
$browseButton.Size = New-Object System.Drawing.Size(110, 30)
$browseButton.Anchor = [System.Windows.Forms.AnchorStyles]::Right
$browseButton.BackColor = [System.Drawing.Color]::LightBlue
$topPanel.Controls.Add($browseButton)

# 开始备份按钮 - 在选择配置按钮右边
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = $script:ui.StartButton
$startButton.Location = New-Object System.Drawing.Point(1020, 15)
$startButton.Size = New-Object System.Drawing.Size(110, 30)
$startButton.Anchor = [System.Windows.Forms.AnchorStyles]::Right
$startButton.BackColor = [System.Drawing.Color]::LightBlue
$startButton.Enabled = $false
$topPanel.Controls.Add($startButton)

# 复制日志按钮 - 在最右边
$copyLogButton = New-Object System.Windows.Forms.Button
$copyLogButton.Text = $script:ui.CopyLogButton
$copyLogButton.Location = New-Object System.Drawing.Point(1140, 15)
$copyLogButton.Size = New-Object System.Drawing.Size(110, 30)
$copyLogButton.Anchor = [System.Windows.Forms.AnchorStyles]::Right
$topPanel.Controls.Add($copyLogButton)

# 创建中部 TabControl（标签页容器）
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(0, 0)
$tabControl.Size = New-Object System.Drawing.Size(1260, 550)
$tabControl.Dock = "Fill"
$centerPanel.Controls.Add($tabControl)

# 创建日志标签页
$logTabPage = New-Object System.Windows.Forms.TabPage
$logTabPage.Text = $script:ui.LogTabPage
$tabControl.Controls.Add($logTabPage)

# 创建游戏列表标签页
$gameListTabPage = New-Object System.Windows.Forms.TabPage
$gameListTabPage.Text = $script:ui.GameListTabPage
# 注意：游戏列表标签页在初始化时不添加到 tabControl，仅在加载配置后动态添加

# 日志显示区域
$logTextBox = New-Object System.Windows.Forms.RichTextBox
$logTextBox.ReadOnly = $true
$logTextBox.ScrollBars = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
$logTextBox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$logTextBox.BackColor = [System.Drawing.Color]::White
$logTextBox.Location = New-Object System.Drawing.Point(0, 0)
$logTextBox.Size = New-Object System.Drawing.Size(1260, 560)
$logTextBox.Dock = "Fill"
$logTabPage.Controls.Add($logTextBox)

# 游戏信息显示表格
$gameDataGridView = New-Object System.Windows.Forms.DataGridView
$gameDataGridView.ReadOnly = $true
$gameDataGridView.AllowUserToAddRows = $false
$gameDataGridView.AllowUserToDeleteRows = $false
$gameDataGridView.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
$gameDataGridView.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$gameDataGridView.BackgroundColor = [System.Drawing.Color]::White
$gameDataGridView.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::LightGray
$gameDataGridView.ColumnHeadersHeight = 40
$gameDataGridView.RowTemplate.Height = 30
$gameDataGridView.Location = New-Object System.Drawing.Point(0, 0)
$gameDataGridView.Size = New-Object System.Drawing.Size(1260, 560)
$gameDataGridView.Dock = "Fill"
$gameDataGridView.ColumnCount = 3
$gameDataGridView.Columns[0].Name = $script:ui.ColumnIndex
$gameDataGridView.Columns[0].Width = 60
$gameDataGridView.Columns[1].Name = $script:ui.ColumnGameName
$gameDataGridView.Columns[1].Width = 320
$gameDataGridView.Columns[2].Name = $script:ui.ColumnSavePath
$gameDataGridView.Columns[2].Width = 780
$gameListTabPage.Controls.Add($gameDataGridView)

# 底部进度条
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Dock = "Fill"
$progressBar.Visible = $false
$progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
$bottomPanel.Controls.Add($progressBar)

# 全局变量
$global:configPath = ""
$global:isRunning = $false
$global:configArray = $null
$global:job = $null
$global:timer = $null
$global:asyncResult = $null
$global:psInstance = $null
$global:runspacePool = $null
# 使用同步集合来存储实时日志
$global:logQueue = [System.Collections.Concurrent.ConcurrentBag[string]]::new()
# 使用 hostname 命令获取完整机器名（与备份.bat 保持一致）
try {
    $hostnameOutput = & cmd /c hostname
    if ($hostnameOutput) {
        $script:machineName = $hostnameOutput.ToString().Trim()
    }
    else {
        $script:machineName = $env:COMPUTERNAME
    }
}
catch {
    $script:machineName = $env:COMPUTERNAME
}
$script:userName = [Environment]::UserName

# 日志输出函数
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[" + $timestamp + "] " + $Message + "`r`n"

    $logTextBox.SelectionStart = $logTextBox.TextLength

    switch ($Level) {
        "Info" { $logTextBox.SelectionColor = [System.Drawing.Color]::Black }
        "Success" { $logTextBox.SelectionColor = [System.Drawing.Color]::Green }
        "Warning" { $logTextBox.SelectionColor = [System.Drawing.Color]::Orange }
        "Error" { $logTextBox.SelectionColor = [System.Drawing.Color]::Red }
        "Progress" { $logTextBox.SelectionColor = [System.Drawing.Color]::Blue }
    }

    $logTextBox.AppendText($logLine)
    $logTextBox.ScrollToCaret()
}

# 加载并显示游戏列表函数
function Load-GameList {
    param([string]$ConfigPath)

    try {
        # 清空现有的游戏数据
        $gameDataGridView.Rows.Clear()

        # 读取 JSON 配置
        $script:configArray = Get-Content -Path $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $totalGames = $script:configArray.Count

        Write-Log ($script:ui.ConfigLoaded -f $totalGames) "Success"

        # 为每个游戏添加表格行
        for ($i = 0; $i -lt $totalGames; $i++) {
            $game = $script:configArray[$i]
            $gameName = $game.name
            $savePath = $game.save

            # 替换环境变量显示
            $displayPath = $savePath -replace "%USERPROFILE%", '$env:USERPROFILE'
            $displayPath = $displayPath -replace "%PROGRAMDATA%", '$env:PROGRAMDATA'

            # 添加行到表格
            $gameDataGridView.Rows.Add(($i + 1), $gameName, $displayPath) | Out-Null
        }

        Write-Log $script:ui.GameListUpdated "Info"

        # 仅在成功加载时才添加游戏列表标签页并切换
        if ($tabControl.TabPages.Contains($gameListTabPage) -eq $false) {
            $tabControl.Controls.Add($gameListTabPage)
        }
        $tabControl.SelectedTab = $gameListTabPage

    } catch {
        Write-Log ($script:ui.GameListUpdated + ": $_") "Error"
        $script:configArray = $null
    }
}

# 自动查找并加载 JSON 配置文件
function Find-AndLoadJsonFile {
    # 获取脚本所在目录
    try {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    } catch {
        $scriptDir = [System.IO.Directory]::GetCurrentDirectory()
    }

    $jsonFiles = Get-ChildItem -Path $scriptDir -Filter "*.json" -File -ErrorAction SilentlyContinue

    if ($jsonFiles.Count -eq 0) {
        Write-Log $script:ui.ConfigNotFound "Warning"
        return $false
    }

    if ($jsonFiles.Count -gt 1) {
        Write-Log ($script:ui.ConfigNotFound + " (" + $jsonFiles.Count + ")") "Warning"
        return $false
    }

    # 只有一个 json 文件，自动加载
    $global:configPath = $jsonFiles.FullName
    $configTextBox.Text = $global:configPath

    Write-Log ($script:ui.ConfigSelected + "$((Split-Path -Leaf $script:configPath))") "Info"

    # 加载游戏列表
    Load-GameList -ConfigPath $script:configPath

    # 如果加载成功，启用开始按钮
    if ($null -ne $script:configArray) {
        $startButton.Enabled = $true
    }

    return $true
}

# 切换回日志标签页函数
function Show-LogPanel {
    $tabControl.SelectedTab = $logTabPage
}

# 浏览按钮点击事件
$browseButton.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = $script:ui.FileFilter
    $fileDialog.Title = $script:ui.FileDialogTitle

    # 获取脚本所在目录
    try {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    } catch {
        $scriptDir = [System.IO.Directory]::GetCurrentDirectory()
    }
    $fileDialog.InitialDirectory = $scriptDir

    if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:configPath = $fileDialog.FileName
        $configTextBox.Text = $global:configPath
        Write-Log ($script:ui.ConfigSelected + $global:configPath) "Info"

        # 加载游戏列表（Load-GameList 函数内部会在成功后切换到游戏列表标签页）
        Load-GameList -ConfigPath $global:configPath

        # 如果加载成功，启用开始按钮
        if ($null -ne $script:configArray) {
            $startButton.Enabled = $true
        }
    }
})

# 获取机器名和用户名并显示日志
Write-Log ($script:ui.MachineInfo -f $script:machineName, $script:userName) "Info"

# 复制日志按钮点击事件
$copyLogButton.Add_Click({
    if ($logTextBox.Text.Length -gt 0) {
        [System.Windows.Forms.Clipboard]::SetText($logTextBox.Text)
        Write-Log $script:ui.LogCopied "Success"
    } else {
        Write-Log $script:ui.NoLog "Warning"
    }
})

# 窗口加载时自动查找并加载 JSON 文件
Write-Log $script:ui.ScanningConfig "Info"
Find-AndLoadJsonFile | Out-Null

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
    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
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

        # 切换到配置目录
        $configDir = Split-Path -Parent $configPath
        Push-Location $configDir

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_CurrentWorkingDir + ": " + (Get-Location).Path)

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

        # 读取配置文件
        try {
            $configContent = Get-Content -Path $configPath -Raw -Encoding UTF8
            $configArray = $configContent | ConvertFrom-Json
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
            & git init
            & git config --local core.autocrlf false
            & git config --local core.safecrlf false
            & git config --local core.ignorecase false
            & git config --local core.quotepath false
            & git config --local i18n.logoutputencoding utf-8
            & git config --local i18n.commitencoding utf-8
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
            $backupDir = $name
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
                New-Item -ItemType Directory -Path $backupDir
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
                    $result = & robocopy . $saveExpanded /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_RobocopyReturn + ": " + $result)
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
                $result = & robocopy $saveExpanded . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_RobocopyReturn + ": " + $result)
                & git add .
                if (-not (& git diff --cached --quiet)) {
                    & git commit -m ("Update - " + $name + " on " + $machineName + " by " + $userName)
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [Success] " + $uiResources.SUCCESS_GitCommit)
                }
            }
            elseif ($maxLocalTime -lt $maxBackupTime) {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Warning] " + $uiResources.WARNING_LocalOlder)
                $sh = New-Object -ComObject Shell.Application
                $sh.Namespace(10).MoveHere($saveExpanded)
                $result = & robocopy . $saveExpanded /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_RobocopyReturn + ": " + $result)
            }
            elseif ($maxLocalTime -gt $maxBackupTime) {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_LocalNewer)
                $result = & robocopy $saveExpanded . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [Info] " + $uiResources.INFO_RobocopyReturn + ": " + $result)
                & git add .
                if (-not (& git diff --cached --quiet)) {
                    & git commit -m ("Update - " + $name + " on " + $machineName + " by " + $userName)
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [Success] " + $uiResources.SUCCESS_GitCommit)
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
        & git add .
        if (-not (& git diff --cached --quiet)) {
            & git commit -m ("Update - on " + $machineName + " by " + $userName)
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [Success] " + $uiResources.SUCCESS_FinalCommit)
        }

        & git clean -df *>$null

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logQueue.Add("[$timestamp] [Success] " + $uiResources.SUCCESS_BackupComplete)

        # 恢复至脚本启动时的工作目录
        Pop-Location
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
    $global:timer = New-Object System.Windows.Forms.Timer
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

                                # 平滑过渡到目标百分比
                                $step = 3
                                $currentValue = $progressBar.Value
                                if ($currentValue -lt $targetPercentage) {
                                    for ($i = $currentValue; $i -le $targetPercentage; $i += $step) {
                                        $progressBar.Value = $i
                                        Start-Sleep -Milliseconds 20
                                    }
                                }
                                $progressBar.Value = $targetPercentage
                            }
                        }
                        # 显示其他完整日志（带颜色）
                        elseif (-not [string]::IsNullOrWhiteSpace($message)) {
                            # 默认级别为 Info
                            $level = "Info"

                            # 检查是否有级别标记 [Level]
                            if ($message -match "^\[(Info|Error|Warning|Success|Progress)\] ") {
                                $level = $matches[1]
                                # 移除级别标记，只保留实际消息
                                $message = $message -replace "^\[(Info|Error|Warning|Success|Progress)\] ", ""
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

            # 等待一小段时间确保所有日志都被读取
            Start-Sleep -Milliseconds 200

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

                                # 检查是否有级别标记 [Level]
                                if ($message -match "^\[(Info|Error|Warning|Success|Progress)\] ") {
                                    $level = $matches[1]
                                    # 移除级别标记，只保留实际消息
                                    $message = $message -replace "^\[(Info|Error|Warning|Success|Progress)\] ", ""
                                }

                                Write-Log $message $level
                            }
                        }
                    }
                }
            }
            catch {}

            $progressBar.Value = 100
            Start-Sleep -Milliseconds 500
            $progressBar.Visible = $false
            $startButton.Enabled = $true
            $browseButton.Enabled = $true
            $global:isRunning = $false

            # 清理资源
            $global:psInstance.Dispose()
            $global:runspacePool.Close()
            $global:runspacePool.Dispose()
        }
    })
    $global:timer.Start()

    Write-Log $script:ui.RunspaceStarted "Progress"
})

# 显示窗口
$form.ShowDialog()
