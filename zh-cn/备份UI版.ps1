# 设置字符编码
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 加载 Windows Forms 程序集
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 创建主窗口
$form = New-Object System.Windows.Forms.Form
$form.Text = "游戏存档备份工具"
$form.Size = New-Object System.Drawing.Size(1100, 800)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)

# 创建顶部面板
$topPanel = New-Object System.Windows.Forms.Panel
$topPanel.Height = 60
$topPanel.Dock = "Top"

# 配置文件标签和文本框
$configLabel = New-Object System.Windows.Forms.Label
$configLabel.Text = "配置文件:"
$configLabel.Location = New-Object System.Drawing.Point(20, 20)
$configLabel.AutoSize = $true

$configTextBox = New-Object System.Windows.Forms.TextBox
$configTextBox.Location = New-Object System.Drawing.Point(100, 17)
$configTextBox.Size = New-Object System.Drawing.Size(500, 23)
$configTextBox.ReadOnly = $true

# 浏览按钮
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "浏览..."
$browseButton.Location = New-Object System.Drawing.Point(610, 15)
$browseButton.Size = New-Object System.Drawing.Size(80, 27)

# 开始备份按钮
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "开始备份"
$startButton.Location = New-Object System.Drawing.Point(710, 15)
$startButton.Size = New-Object System.Drawing.Size(100, 27)
$startButton.BackColor = [System.Drawing.Color]::LightGreen
$startButton.Enabled = $false

# 复制日志按钮
$copyLogButton = New-Object System.Windows.Forms.Button
$copyLogButton.Text = "复制日志"
$copyLogButton.Location = New-Object System.Drawing.Point(820, 15)
$copyLogButton.Size = New-Object System.Drawing.Size(100, 27)
$copyLogButton.BackColor = [System.Drawing.Color]::LightBlue

# 创建中部 TabControl（标签页容器）
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(20, 80)
$tabControl.Size = New-Object System.Drawing.Size(1040, 600)
$tabControl.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom
$tabControl.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)

# 创建日志标签页
$logTabPage = New-Object System.Windows.Forms.TabPage
$logTabPage.Text = "运行日志"
$logTabPage.Padding = New-Object System.Windows.Forms.Padding(0)

# 创建游戏列表标签页
$gameListTabPage = New-Object System.Windows.Forms.TabPage
$gameListTabPage.Text = "游戏列表"
$gameListTabPage.Padding = New-Object System.Windows.Forms.Padding(5)

# 创建日志区域
$logTextBox = New-Object System.Windows.Forms.RichTextBox
$logTextBox.Location = New-Object System.Drawing.Point(0, 0)
$logTextBox.Size = New-Object System.Drawing.Size(1040, 600)
$logTextBox.Dock = "Fill"
$logTextBox.ReadOnly = $true
$logTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$logTextBox.BackColor = [System.Drawing.Color]::White

# 游戏列表标题
$gameListLabel = New-Object System.Windows.Forms.Label
$gameListLabel.Text = "已配置的游戏"
$gameListLabel.Location = New-Object System.Drawing.Point(10, 10)
$gameListLabel.AutoSize = $true
$gameListLabel.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 12, [System.Drawing.FontStyle]::Bold)
$gameListLabel.ForeColor = [System.Drawing.Color]::DarkBlue

# 游戏信息表格（DataGridView）
$gameDataGridView = New-Object System.Windows.Forms.DataGridView
$gameDataGridView.Location = New-Object System.Drawing.Point(10, 40)
$gameDataGridView.Size = New-Object System.Drawing.Size(1020, 550)
$gameDataGridView.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom
$gameDataGridView.AllowUserToAddRows = $false
$gameDataGridView.AllowUserToDeleteRows = $false
$gameDataGridView.ReadOnly = $true
$gameDataGridView.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
$gameDataGridView.MultiSelect = $false
$gameDataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
$gameDataGridView.BackgroundColor = [System.Drawing.Color]::White
$gameDataGridView.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$gameDataGridView.RowHeadersVisible = $false
$gameDataGridView.EnableHeadersVisualStyles = $false
$gameDataGridView.ColumnHeadersDefaultCellStyle.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
$gameDataGridView.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::LightGray
$gameDataGridView.ColumnHeadersHeight = 30
$gameDataGridView.DefaultCellStyle.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$gameDataGridView.DefaultCellStyle.Padding = New-Object System.Windows.Forms.Padding(5)
$gameDataGridView.RowTemplate.Height = 40
$gameDataGridView.ColumnCount = 3
$gameDataGridView.Columns[0].Name = "序号"
$gameDataGridView.Columns[0].Width = 60
$gameDataGridView.Columns[1].Name = "游戏名称"
$gameDataGridView.Columns[1].Width = 200
$gameDataGridView.Columns[2].Name = "存档路径"
$gameDataGridView.Columns[2].Width = 740
# 启用滚动条
$gameDataGridView.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

# 创建底部状态栏（静默，不显示文字）
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = ""
$statusLabel.Location = New-Object System.Drawing.Point(20, 690)
$statusLabel.AutoSize = $true
$statusLabel.Visible = $false

# 进度条（居中并铺满）
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 690)
$progressBar.Size = New-Object System.Drawing.Size(1040, 23)
$progressBar.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$progressBar.Visible = $false

# 将日志文本框添加到日志标签页
$logTabPage.Controls.Add($logTextBox)

# 将控件添加到游戏列表标签页
$gameListTabPage.Controls.Add($gameListLabel)
$gameListTabPage.Controls.Add($gameDataGridView)

# 将标签页添加到 TabControl
$tabControl.Controls.Add($logTabPage)
$tabControl.Controls.Add($gameListTabPage)

# 将顶部面板添加到底部
$topPanel.Controls.Add($configLabel)
$topPanel.Controls.Add($configTextBox)
$topPanel.Controls.Add($browseButton)
$topPanel.Controls.Add($startButton)
$topPanel.Controls.Add($copyLogButton)

# 将 TabControl 添加到主窗口
$form.Controls.Add($topPanel)
$form.Controls.Add($tabControl)
$form.Controls.Add($statusLabel)
$form.Controls.Add($progressBar)

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
    $logLine = "[" + $timestamp + "] [" + $Level + "] " + $Message + "`r`n"
    
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
        
        Write-Log "成功加载配置文件，共 $totalGames 个游戏" "Success"
        
        # 为每个游戏添加表格行
        for ($i = 0; $i -lt $totalGames; $i++) {
            $game = $script:configArray[$i]
            $gameName = $game.name
            $savePath = $game.save
            
            # 替换环境变量显示
            $displayPath = $savePath -replace "%USERPROFILE%", '$env:USERPROFILE'
            $displayPath = $displayPath -replace "%PROGRAMDATA%", '$env:PROGRAMDATA'
            
            # 添加行到表格
            $gameDataGridView.Rows.Add(($i + 1), $gameName, $displayPath)
        }
        
        Write-Log "游戏列表已更新" "Info"
        
        # 切换到游戏列表标签页
        $tabControl.SelectedTab = $gameListTabPage
        
    } catch {
        Write-Log "加载游戏列表失败：$_" "Error"
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
    
    # 查找所有 json 文件
    $jsonFiles = Get-ChildItem -Path $scriptDir -Filter "*.json" -File -ErrorAction SilentlyContinue
    
    if ($jsonFiles.Count -eq 0) {
        Write-Log "警告：当前目录下未找到 [.json] 配置文件" "Warning"
        return $false
    }
    
    if ($jsonFiles.Count -gt 1) {
        Write-Log "警告：当前目录下找到多个 [.json] 配置文件（共 $($jsonFiles.Count) 个），请选择一个加载" "Warning"
        return $false
    }
    
    # 只有一个 json 文件，自动加载
    $global:configPath = $jsonFiles.FullName
    $configTextBox.Text = $global:configPath
    
    Write-Log "自动检测到配置文件：$((Split-Path -Leaf $script:configPath))" "Info"
    
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
    $fileDialog.Filter = "JSON 文件 (*.json)|*.json|所有文件 (*.*)|*.*"
    $fileDialog.Title = "选择配置文件"
    
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
        Write-Log "已选择配置文件：" + $global:configPath "Info"
        
        # 加载游戏列表（Load-GameList 函数内部会在成功后切换到游戏列表标签页）
        Load-GameList -ConfigPath $global:configPath
        
        # 如果加载成功，启用开始按钮
        if ($null -ne $script:configArray) {
            $startButton.Enabled = $true
        }
    }
})

# 获取机器名和用户名并显示日志
Write-Log "========================================" "Info"
Write-Log ("机器名：" + $script:machineName + "  用户名：" + $script:userName) "Info"
Write-Log "========================================" "Info"

# 复制日志按钮点击事件
$copyLogButton.Add_Click({
    if ($logTextBox.Text.Length -gt 0) {
        [System.Windows.Forms.Clipboard]::SetText($logTextBox.Text)
        Write-Log "日志已复制到剪贴板" "Success"
    } else {
        Write-Log "当前没有日志内容" "Warning"
    }
})

# 窗口加载时自动查找并加载 JSON 文件
Write-Log "正在扫描配置文件..." "Info"
Find-AndLoadJsonFile

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
    
    Write-Log "========================================" "Progress"
    Write-Log "开始备份任务" "Progress"
    Write-Log "========================================" "Progress"
    
    # 创建 Runspace 池来执行备份任务
    $runspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, 1)
    $runspacePool.Open()
    
    # 创建 PowerShell 实例
    $psInstance = [System.Management.Automation.PowerShell]::Create()
    $psInstance.RunspacePool = $runspacePool
    
    # 添加要执行的脚本和参数
    $psInstance.AddScript({
        param($configPath, $machineName, $userName, $logQueue)
        
        # 切换到配置目录
        $configDir = Split-Path -Parent $configPath
        Push-Location $configDir
            
        # 检查 Git
        $gitExe = Get-Command git -ErrorAction SilentlyContinue
        if (-not $gitExe) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [ERROR] 错误：缺少 git.exe 组件") | Out-Null
            $logQueue.Add("[$timestamp] [ERROR] 请从 https://git-scm.com/install/windows 下载") | Out-Null
            $logQueue.Add("[$timestamp] [INFO] ") | Out-Null
            return
        }
            
        # 验证选定的配置文件是否存在
        if (-not (Test-Path $configPath)) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [ERROR] 错误：选定的配置文件不存在：" + $configPath) | Out-Null
            $logQueue.Add("[$timestamp] [INFO] ") | Out-Null
            return
        }
            
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logQueue.Add("[$timestamp] [INFO] 使用配置文件：" + (Split-Path -Leaf $configPath)) | Out-Null
            
        # 读取配置文件
        try {
            $configContent = Get-Content -Path $configPath -Raw -Encoding UTF8
            $configArray = $configContent | ConvertFrom-Json
            $totalGames = $configArray.Count
        }
        catch {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [ERROR] 读取配置文件失败：" + $_) | Out-Null
            return
        }
            
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logQueue.Add("[$timestamp] [INFO] ") | Out-Null
        $logQueue.Add("[$timestamp] [INFO] 找到 " + $totalGames + " 个游戏配置") | Out-Null
            
        # 初始化 Git
        if (-not (Test-Path ".git")) {
            & git init | Out-Null
            & git config --local core.autocrlf false | Out-Null
            & git config --local core.safecrlf false | Out-Null
            & git config --local core.ignorecase false | Out-Null
            & git config --local core.quotepath false | Out-Null
            & git config --local i18n.logoutputencoding utf-8 | Out-Null
            & git config --local i18n.commitencoding utf-8 | Out-Null
        }
            
        $gameIndex = 0
        foreach ($game in $configArray) {
            $gameIndex++
            $name = $game.name
            $save = $game.save
            $ignore = $game.ignore
                
            # 显示当前处理的遊戲
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [PROGRESS] 处理 " + $gameIndex + " / " + $totalGames + " : `"" + $name + "`" 位于 `"" + $save + "`"") | Out-Null
                
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
                    $logQueue.Add("[$timestamp] [INFO] 忽略项：`"" + $itemExpanded + "`"") | Out-Null
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
            $logQueue.Add("[$timestamp] [INFO] 本地文件修改时间:[" + $maxLocalTimeString + "] 备份文件修改时间:[" + $maxBackupTimeString + "]") | Out-Null
                
            # 创建备份目录
            if (-not (Test-Path $backupDir)) {
                New-Item -ItemType Directory -Path $backupDir | Out-Null
            }
                
            Push-Location $backupDir
                
            # 判断备份策略
            if ($null -eq $maxLocalTime) {
                if ($null -eq $maxBackupTime) {
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [WARNING] 本地存档文件与备份文件都不存在，跳过操作") | Out-Null
                }
                else {
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [WARNING] 本地存档文件缺失，使用备份文件恢复") | Out-Null
                    $sh = New-Object -ComObject Shell.Application
                    $sh.Namespace(10).MoveHere($saveExpanded)
                    $result = & robocopy . $saveExpanded /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [INFO] Robocopy 返回码：" + $result) | Out-Null
                }
            }
            elseif ($null -eq $maxBackupTime) {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [INFO] 备份文件缺失，进行备份") | Out-Null
                if (-not (Test-Path "存档位置.bat")) {
                    $batContent = "if not exist `"" + $saveExpanded + "`" mkdir `"" + $saveExpanded + "`"`r`n"
                    $batContent += "`"explorer.exe`" `"" + $saveExpanded + "`""
                    Set-Content -Path "存档位置.bat" -Value $batContent -Encoding UTF8
                    (Get-Item "存档位置.bat").LastWriteTime = [DateTimeOffset]::FromUnixTimeSeconds(0).UtcDateTime
                }
                $result = & robocopy $saveExpanded . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [INFO] Robocopy 返回码：" + $result) | Out-Null
                & git add .
                if (-not (& git diff --cached --quiet)) {
                    & git commit -m ("Update - " + $name + " on " + $machineName + " by " + $userName)
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [SUCCESS] Git 提交完成") | Out-Null
                }
            }
            elseif ($maxLocalTime -lt $maxBackupTime) {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [WARNING] 本地存档文件修改时间较旧，删除到回收站，并使用备份文件更新") | Out-Null
                $sh = New-Object -ComObject Shell.Application
                $sh.Namespace(10).MoveHere($saveExpanded)
                $result = & robocopy . $saveExpanded /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [INFO] Robocopy 返回码：" + $result) | Out-Null
            }
            elseif ($maxLocalTime -gt $maxBackupTime) {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [INFO] 本地存档文件修改时间较新，进行备份") | Out-Null
                $result = & robocopy $saveExpanded . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [INFO] Robocopy 返回码：" + $result) | Out-Null
                & git add .
                if (-not (& git diff --cached --quiet)) {
                    & git commit -m ("Update - " + $name + " on " + $machineName + " by " + $userName)
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $logQueue.Add("[$timestamp] [SUCCESS] Git 提交完成") | Out-Null
                }
            }
            else {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logQueue.Add("[$timestamp] [SUCCESS] 本地存档文件与备份文件修改时间相同，跳过操作") | Out-Null
            }
                
            Pop-Location
            
            # 游戏处理完成后，发送进度更新信号
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [PROGRESS_SIGNAL] $gameIndex|$totalGames") | Out-Null
            $logQueue.Add("[$timestamp] [INFO] ") | Out-Null
        }
            
        # 最终 Git 提交
        & git add .
        if (-not (& git diff --cached --quiet)) {
            & git commit -m ("Update - on " + $machineName + " by " + $userName)
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logQueue.Add("[$timestamp] [SUCCESS] 最终 Git 提交完成") | Out-Null
        }
            
        & git clean -df *>$null
            
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logQueue.Add("[$timestamp] [SUCCESS] 备份完成") | Out-Null
            
        Pop-Location
    }) | Out-Null
    
    $psInstance.AddParameter('configPath', $global:configPath) | Out-Null
    $psInstance.AddParameter('machineName', $script:machineName) | Out-Null
    $psInstance.AddParameter('userName', $script:userName) | Out-Null
    $psInstance.AddParameter('logQueue', $global:logQueue) | Out-Null
    
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
                    $secondBracketStart = $logLine.IndexOf('[', $firstBracketEnd)
                    $secondBracketEnd = $logLine.IndexOf(']', $secondBracketStart)
                    
                    if ($firstBracketEnd -gt 0 -and $secondBracketStart -gt 0 -and $secondBracketEnd -gt $secondBracketStart) {
                        $level = $logLine.Substring($secondBracketStart + 1, $secondBracketEnd - $secondBracketStart - 1)
                        # 提取完整消息 (包含所有原始内容)
                        $message = $logLine.Substring($secondBracketEnd + 2).Trim()
                        
                        # 处理进度信号
                        if ($level -eq "PROGRESS_SIGNAL") {
                            $signalParts = $message -split '\|'
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
                        # 显示其他完整日志
                        elseif (-not [string]::IsNullOrWhiteSpace($message)) {
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
                        $secondBracketStart = $logLine.IndexOf('[', $firstBracketEnd)
                        $secondBracketEnd = $logLine.IndexOf(']', $secondBracketStart)
                        
                        if ($firstBracketEnd -gt 0 -and $secondBracketStart -gt 0 -and $secondBracketEnd -gt $secondBracketStart) {
                            $level = $logLine.Substring($secondBracketStart + 1, $secondBracketEnd - $secondBracketStart - 1)
                            $message = $logLine.Substring($secondBracketEnd + 2).Trim()
                            if ($level -ne "PROGRESS_SIGNAL" -and -not [string]::IsNullOrWhiteSpace($message)) {
                                Write-Log $message $level
                            }
                        }
                    }
                }
            }
            catch {}
            
            Write-Log "========================================" "Progress"
            Write-Log "备份任务完成" "Success"
            Write-Log "========================================" "Progress"
            
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
    
    Write-Log "Runspace 已启动，开始监控备份任务" "Progress"
})

# 显示窗口
$form.ShowDialog()
