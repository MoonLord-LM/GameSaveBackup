@echo off
chcp 65001 >nul
setlocal disabledelayedexpansion
set "script=%~0" & set "script_path=%~f0" & set "script_dir=%~dp0" & set "script_name=%~n0" & set "script_ext=%~x0" & set "script_name_ext=%~nx0"
setlocal enabledelayedexpansion
if /i "!cd!"=="!SystemRoot!\System32" ( cd /d "!script_dir!" )
powershell -NoProfile -Command "Write-Host '[ !script_name_ext! ]' -ForegroundColor Cyan" && echo.



REM 开源地址：https://github.com/MoonLord-LM/GameSaveBackup
REM 功能：把本地游戏存档备份到当前目录的 Git 仓库，并按修改时间自动双向同步



powershell -NoProfile -Command "Write-Host '把本地游戏存档备份到 Git 仓库，并自动双向同步' -ForegroundColor Green"
echo.



REM 检查 git 组件是否可用
"git.exe" --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 缺少 git.exe 组件
    echo 请从 https://git-scm.com/install/windows 下载
    "explorer.exe" "https://git-scm.com/install/windows"
    echo.
    pause
    exit /b 1
)

REM 初始化本地 Git 仓库（若不存在）
if not exist ".git" (
    git init
    git config --local core.autocrlf false
    git config --local core.safecrlf false
    git config --local core.ignorecase false
    git config --local core.quotepath false
    git config --local i18n.logoutputencoding utf-8
    git config --local i18n.commitencoding utf-8
)

REM 读取当前机器名与用户名，用于提交信息
for /f "tokens=*" %%a in ('hostname') do set "machine_name=%%a"
for /f "tokens=*" %%b in ('powershell -NoProfile -Command "[Environment]::UserName"') do set "user_name=%%b"
echo 机器名: !machine_name! 用户名: !user_name!

REM 从本脚本末尾的标记区块中提取内嵌的 JSON 配置，写入临时文件
set "json_config_marker=-----BEGIN JSON CONFIG-----"
set "json_config_temp=%temp%\GameSaveBackup_!random!_!random!_!random!_!random!.json" & type nul > "!json_config_temp!"
powershell -NoProfile -Command ^
    "[System.Console]::OutputEncoding=[System.Text.Encoding]::UTF8;" ^
    "$lines = Get-Content -Encoding UTF8 -LiteralPath $env:script_path;" ^
    "$begin = [array]::IndexOf($lines, $env:json_config_marker) + 1;" ^
    "$end = [array]::IndexOf($lines, '-----END JSON CONFIG-----');" ^
    "if ($begin -lt 1 -or $end -lt $begin) {" ^
    "    Write-Host '错误: 未找到内嵌的 JSON 配置' -ForegroundColor Red;" ^
    "    exit 1;" ^
    "};" ^
    "$json = $lines[$begin..($end - 1)] -join [Environment]::NewLine;" ^
    "[System.IO.File]::WriteAllText($env:json_config_temp, $json, [System.Text.UTF8Encoding]::new($false));"
if !errorlevel! neq 0 (
    echo 错误: 提取内嵌的 JSON 配置失败
    echo.
    pause
    exit /b 1
)

set "config=!json_config_temp!"
echo 使用内嵌配置
for /f %%i in ('powershell -NoProfile -Command "$arr = (Get-Content -Raw -Encoding UTF8 -Path \""!config!\"" | ConvertFrom-Json); [string]$arr.Count"') do set "length=%%i"
echo.



REM 遍历配置中的每一项，按修改时间自动备份 / 还原
for /l %%i in (1, 1, !length!) do (
    for /f "tokens=*" %%j in ('powershell -NoProfile -Command "(Get-Content -Raw -Encoding UTF8 -Path \""!config!\"" | ConvertFrom-Json)[%%i - 1].name"') do set "name=%%j"
    for /f "tokens=*" %%j in ('powershell -NoProfile -Command "(Get-Content -Raw -Encoding UTF8 -Path \""!config!\"" | ConvertFrom-Json)[%%i - 1].save"') do set "save=%%j"

    set "save=!save:%%USERPROFILE%%=%USERPROFILE%!"
    set "save=!save:%%PROGRAMDATA%%=%PROGRAMDATA%!"
    set "save=!save:%%PUBLIC%%=%PUBLIC%!"
    echo 处理 %%i / !length! :  "!name!" 位于 "!save!"

    set "ignore_args=/XF ""SaveLocation.bat"" /XF ""存档位置.bat"""
    for /f "delims=" %%k in ('powershell -NoProfile -Command "$item = (Get-Content -Raw -Encoding UTF8 -Path \""!config!\"" | ConvertFrom-Json)[%%i - 1].ignore; if ($item) { $item } else { }"') do (
        set "item=%%k"
        set "item=!item:%%USERPROFILE%%=%USERPROFILE%!"
        set "item=!item:%%PROGRAMDATA%%=%PROGRAMDATA%!"
        set "item=!item:%%PUBLIC%%=%PUBLIC%!"
        echo 忽略项: "!item!"
        set "ignore_args=!ignore_args! /XF ""!item!"" /XD ""!item!"""
    )

    set "max_local_time="
    set "max_backup_time="
    set "max_local_time_string="
    set "max_backup_time_string="

    if exist "!save!" (
        for /f %%a in ('powershell -NoProfile -Command "try { $files = Get-ChildItem -Recurse -Path \""!save!\"" -File -ErrorAction SilentlyContinue; if ($files) { ($files | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.Ticks } else { 0 } } catch { 0 }"') do set "max_local_time=%%a"
        if "!max_local_time!"=="0" (
            set "max_local_time="
        ) else (
            for /f "delims=" %%a in ('powershell -NoProfile -Command "[DateTime]::new(!max_local_time!, 'UTC').ToString('yyyy-MM-dd HH:mm:ss UTC')"') do set "max_local_time_string=%%a"
        )
    )

    if not exist "!name!" (
        mkdir "!name!"
    ) else (
        for /f %%a in ('powershell -NoProfile -Command "try { $files = Get-ChildItem -Recurse -Path \""!name!\"" -File -ErrorAction SilentlyContinue; if ($files) { ($files | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.Ticks } else { 0 } } catch { 0 }"') do set "max_backup_time=%%a"
        if "!max_backup_time!"=="0" (
            set "max_backup_time="
        ) else (
            for /f "delims=" %%a in ('powershell -NoProfile -Command "[DateTime]::new(!max_backup_time!, 'UTC').ToString('yyyy-MM-dd HH:mm:ss UTC')"') do set "max_backup_time_string=%%a"
        )
    )
    cd "!name!"

    echo 本地文件修改时间: [!max_local_time_string!] 备份文件修改时间: [!max_backup_time_string!]

    if "!max_local_time!"=="" (
        if "!max_backup_time!"=="" (
            echo 本地存档文件与备份文件都不存在，跳过操作
        ) else (
            echo 本地存档文件缺失，使用备份文件恢复
            powershell -NoProfile -Command "$sh = New-Object -ComObject Shell.Application; $sh.Namespace(10).MoveHere(\""!save!\"")"
            robocopy . "!save!" /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH !ignore_args!
        )
    ) else (
        if "!max_backup_time!"=="" (
            echo 备份文件缺失，进行备份
            if not exist "存档位置.bat" (
                echo if not exist "!save!" mkdir "!save!" > "存档位置.bat"
                echo "explorer.exe" "!save!" >> "存档位置.bat"
                powershell -NoProfile -Command "(Get-Item '存档位置.bat').LastWriteTime = [DateTimeOffset]::FromUnixTimeSeconds(0).UtcDateTime"
            )
            robocopy "!save!" . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH !ignore_args!
            git add .
            git diff --cached --quiet || git commit -m "Update - !name! on !machine_name! by !user_name!"
        ) else (
            if "!max_local_time!" lss "!max_backup_time!" (
                echo 本地存档文件修改时间较旧，删除到回收站，并使用备份文件更新
                powershell -NoProfile -Command "$sh = New-Object -ComObject Shell.Application; $sh.Namespace(10).MoveHere(\""!save!\"")"
                robocopy . "!save!" /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH !ignore_args!
            ) else (
                if "!max_local_time!" gtr "!max_backup_time!" (
                    echo 本地存档文件修改时间较新，进行备份
                    robocopy "!save!" . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH !ignore_args!
                    git add .
                    git diff --cached --quiet || git commit -m "Update - !name! on !machine_name! by !user_name!"
                ) else (
                    echo 本地存档文件与备份文件修改时间相同，跳过操作
                )
            )
        )
    )

    cd ..
    echo.
)

REM 提交整体变更并清理未跟踪文件
git add .
git diff --cached --quiet || ( git commit -m "Update - on !machine_name! by !user_name!" && echo. )
git clean -df >nul

REM 清理临时配置文件
if exist "!json_config_temp!" ( del /f /q "!json_config_temp!" )

echo 备份完成



echo.
pause
exit /b



-----BEGIN JSON CONFIG-----
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
-----END JSON CONFIG-----
