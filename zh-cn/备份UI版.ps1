# 设置字符编码
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 加载 Windows Forms 程序集
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 创建主窗口
$form = New-Object System.Windows.Forms.Form
$form.Text = "游戏存档备份工具"
$form.Size = New-Object System.Drawing.Size(900, 700)
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

# 创建中部日志区域
$logTextBox = New-Object System.Windows.Forms.RichTextBox
$logTextBox.Location = New-Object System.Drawing.Point(20, 80)
$logTextBox.Size = New-Object System.Drawing.Size(840, 500)
$logTextBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom
$logTextBox.ReadOnly = $true
$logTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$logTextBox.BackColor = [System.Drawing.Color]::White

# 创建底部状态栏
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "就绪"
$statusLabel.Location = New-Object System.Drawing.Point(20, 590)
$statusLabel.AutoSize = $true
$statusLabel.ForeColor = [System.Drawing.Color]::Blue

# 进度条
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(200, 590)
$progressBar.Size = New-Object System.Drawing.Size(660, 23)
$progressBar.Visible = $false

# 将控件添加到顶部面板
$topPanel.Controls.Add($configLabel)
$topPanel.Controls.Add($configTextBox)
$topPanel.Controls.Add($browseButton)
$topPanel.Controls.Add($startButton)

# 将控件添加到主窗口
$form.Controls.Add($topPanel)
$form.Controls.Add($logTextBox)
$form.Controls.Add($statusLabel)
$form.Controls.Add($progressBar)

# 全局变量
$script:configPath = ""
$script:isRunning = $false

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
        $script:configPath = $fileDialog.FileName
        $configTextBox.Text = $script:configPath
        $startButton.Enabled = $true
        Write-Log "已选择配置文件：" + $script:configPath "Info"
    }
})

# 获取机器名和用户名
$machineName = $env:COMPUTERNAME
$userName = [Environment]::UserName
Write-Log "机器名：" + $machineName + "  用户名：" + $userName "Info"

# 开始备份按钮点击事件
$startButton.Add_Click({
    if ($script:isRunning) {
        return
    }
    
    $script:isRunning = $true
    $startButton.Enabled = $false
    $browseButton.Enabled = $false
    $progressBar.Visible = $true
    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
    
    Write-Log "========================================" "Progress"
    Write-Log "开始备份任务" "Progress"
    Write-Log "========================================" "Progress"
    
    # 使用 PowerShell 异步执行备份任务
    $job = Start-Job -ScriptBlock {
        param($configPath, $machineName, $userName)
        
        $output = [System.Collections.ArrayList]::new()
        
        # 切换到配置目录
        $configDir = Split-Path -Parent $configPath
        Push-Location $configDir
        
        # 检查 Git
        $gitExe = Get-Command git -ErrorAction SilentlyContinue
        if (-not $gitExe) {
            $output.Add("ERROR|错误：缺少 git.exe 组件") | Out-Null
            $output.Add("ERROR|请从 https://git-scm.com/install/windows 下载") | Out-Null
            $output.Add("INFO|") | Out-Null
            return $output
        }
        
        # 检查配置文件数量
        $jsonFiles = Get-ChildItem -Path "*.json" -File
        if ($jsonFiles.Count -eq 0) {
            $output.Add("ERROR|错误：当前目录下没有找到 [.json] 配置文件") | Out-Null
            $output.Add("ERROR|请确保有一个 [.json] 配置文件在此目录中") | Out-Null
            $output.Add("INFO|") | Out-Null
            return $output
        }
        if ($jsonFiles.Count -gt 1) {
            $output.Add("ERROR|错误：当前目录下找到多个 [.json] 配置文件，共 " + $jsonFiles.Count + " 个") | Out-Null
            $output.Add("ERROR|请只保留一个 [.json] 配置文件") | Out-Null
            $output.Add("INFO|") | Out-Null
            return $output
        }
        
        $output.Add("INFO|使用配置文件：" + (Split-Path -Leaf $configPath)) | Out-Null
        
        # 读取配置文件
        try {
            $configContent = Get-Content -Path $configPath -Raw -Encoding UTF8
            $configArray = $configContent | ConvertFrom-Json
            $totalGames = $configArray.Count
        }
        catch {
            $output.Add("ERROR|读取配置文件失败：" + $_) | Out-Null
            return $output
        }
        
        $output.Add("INFO|") | Out-Null
        $output.Add(("INFO|找到 " + $totalGames + " 个游戏配置")) | Out-Null
        
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
            
            $output.Add(("PROGRESS|处理 " + $gameIndex + " / " + $totalGames + " : `"" + $name + "`" 位于 `"" + $save + "`"")) | Out-Null
            
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
                    $output.Add(("INFO|忽略项：`"" + $itemExpanded + "`"")) | Out-Null
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
            
            $output.Add(("INFO|本地文件修改时间：[" + $maxLocalTimeString + "] 备份文件修改时间：[" + $maxBackupTimeString + "]")) | Out-Null
            
            # 创建备份目录
            if (-not (Test-Path $backupDir)) {
                New-Item -ItemType Directory -Path $backupDir | Out-Null
            }
            
            Push-Location $backupDir
            
            # 判断备份策略
            if ($null -eq $maxLocalTime) {
                if ($null -eq $maxBackupTime) {
                    $output.Add("WARNING|本地存档文件与备份文件都不存在，跳过操作") | Out-Null
                }
                else {
                    $output.Add("WARNING|本地存档文件缺失，使用备份文件恢复") | Out-Null
                    $sh = New-Object -ComObject Shell.Application
                    $sh.Namespace(10).MoveHere($saveExpanded)
                    $result = & robocopy . $saveExpanded /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs
                    $output.Add(("INFO|Robocopy 返回码：" + $result)) | Out-Null
                }
            }
            elseif ($null -eq $maxBackupTime) {
                $output.Add("INFO|备份文件缺失，进行备份") | Out-Null
                if (-not (Test-Path "存档位置.bat")) {
                    $batContent = "if not exist `"" + $saveExpanded + "`" mkdir `"" + $saveExpanded + "`"`r`n"
                    $batContent += "`"explorer.exe`" `"" + $saveExpanded + "`""
                    Set-Content -Path "存档位置.bat" -Value $batContent -Encoding UTF8
                    (Get-Item "存档位置.bat").LastWriteTime = [DateTimeOffset]::FromUnixTimeSeconds(0).UtcDateTime
                }
                $result = & robocopy $saveExpanded . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs
                $output.Add(("INFO|Robocopy 返回码：" + $result)) | Out-Null
                & git add .
                if (-not (& git diff --cached --quiet)) {
                    & git commit -m ("Update - " + $name + " on " + $machineName + " by " + $userName)
                    $output.Add("SUCCESS|Git 提交完成") | Out-Null
                }
            }
            elseif ($maxLocalTime -lt $maxBackupTime) {
                $output.Add("WARNING|本地存档文件修改时间较旧，删除到回收站，并使用备份文件更新") | Out-Null
                $sh = New-Object -ComObject Shell.Application
                $sh.Namespace(10).MoveHere($saveExpanded)
                $result = & robocopy . $saveExpanded /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs
                $output.Add(("INFO|Robocopy 返回码：" + $result)) | Out-Null
            }
            elseif ($maxLocalTime -gt $maxBackupTime) {
                $output.Add("INFO|本地存档文件修改时间较新，进行备份") | Out-Null
                $result = & robocopy $saveExpanded . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH $ignoreArgs
                $output.Add(("INFO|Robocopy 返回码：" + $result)) | Out-Null
                & git add .
                if (-not (& git diff --cached --quiet)) {
                    & git commit -m ("Update - " + $name + " on " + $machineName + " by " + $userName)
                    $output.Add("SUCCESS|Git 提交完成") | Out-Null
                }
            }
            else {
                $output.Add("SUCCESS|本地存档文件与备份文件修改时间相同，跳过操作") | Out-Null
            }
            
            Pop-Location
            $output.Add("INFO|") | Out-Null
        }
        
        # 最终 Git 提交
        & git add .
        if (-not (& git diff --cached --quiet)) {
            & git commit -m ("Update - on " + $machineName + " by " + $userName)
            $output.Add("SUCCESS|最终 Git 提交完成") | Out-Null
        }
        
        & git clean -df >nul
        
        $output.Add("SUCCESS|备份完成") | Out-Null
        
        Pop-Location
        
        return $output
    } -ArgumentList $script:configPath, $machineName, $userName
    
    # 轮询 Job 输出
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 500
    $timer.Add_Tick({
        if ($job.JobStateInfo.State -eq "Completed") {
            $timer.Stop()
            $results = Receive-Job -Job $job
            foreach ($line in $results) {
                $parts = $line -split '\|', 2
                if ($parts.Count -eq 2) {
                    $level = $parts[0]
                    $message = $parts[1]
                    Write-Log $message $level
                }
            }
            
            Write-Log "========================================" "Progress"
            Write-Log "备份任务完成" "Success"
            Write-Log "========================================" "Progress"
            
            $statusLabel.Text = "备份完成"
            $statusLabel.ForeColor = [System.Drawing.Color]::Green
            $progressBar.Visible = $false
            $startButton.Enabled = $true
            $browseButton.Enabled = $true
            $script:isRunning = $false
            Remove-Job -Job $job
        }
        elseif ($job.JobStateInfo.State -eq "Failed") {
            $timer.Stop()
            Write-Log ("备份任务失败：" + $job.JobStateInfo.Reason.Message) "Error"
            $statusLabel.Text = "备份失败"
            $statusLabel.ForeColor = [System.Drawing.Color]::Red
            $progressBar.Visible = $false
            $startButton.Enabled = $true
            $browseButton.Enabled = $true
            $script:isRunning = $false
            Remove-Job -Job $job
        }
    })
    $timer.Start()
})

# 显示窗口
$form.ShowDialog()
