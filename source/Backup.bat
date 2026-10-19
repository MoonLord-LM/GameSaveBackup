@echo off
chcp 65001 >nul
setlocal disabledelayedexpansion
set "script=%~0" & set "script_path=%~f0" & set "script_dir=%~dp0" & set "script_name=%~n0" & set "script_ext=%~x0" & set "script_name_ext=%~nx0"
setlocal enabledelayedexpansion
if /i "!cd!"=="!SystemRoot!\System32" ( cd /d "!script_dir!" )
powershell -NoProfile -Command "Write-Host '[ !script_name_ext! ]' -ForegroundColor Cyan" && echo.





powershell -NoProfile -Command "Write-Host 'https://github.com/MoonLord-LM/GameSaveBackup' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '把本地游戏存档备份到 Git 仓库，并自动双向同步' -ForegroundColor Green"
echo.



REM Define the backup root directory (unified Backup subfolder, to avoid modifying files outside the script directory)
set "backup_dir=!script_dir!Backup"
if not exist "!backup_dir!" (
    mkdir "!backup_dir!"
)
cd /d "!backup_dir!" || (
    echo Error: Failed to enter backup directory "!backup_dir!"
    echo.
    pause
    exit /b 1
)

REM Check git component availability
"git.exe" --version >nul 2>&1
if !errorlevel! neq 0 (
    echo Error: Missing git.exe component
    echo Please download from https://git-scm.com/install/windows
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
echo Machine Name: !machine_name! User Name: !user_name!

REM Config path: Backup\config.json (English default) or Backup\配置.json (compatible)
REM English version prefers config.json, falls back to 配置.json if missing, otherwise writes embedded default config
set "config_primary=!backup_dir!\config.json"
set "config_secondary=!backup_dir!\配置.json"
if exist "!config_primary!" (
    set "config=!config_primary!"
    echo Using config file: "!config!"
) else if exist "!config_secondary!" (
    set "config=!config_secondary!"
    echo Using config file: "!config!"
) else (
    set "json_config_marker=-----BEGIN JSON CONFIG-----"
    powershell -NoProfile -Command ^
        "[System.Console]::OutputEncoding=[System.Text.Encoding]::UTF8;" ^
        "$lines = Get-Content -Encoding UTF8 -LiteralPath $env:script_path;" ^
        "$begin = [array]::IndexOf($lines, $env:json_config_marker) + 1;" ^
        "$end = [array]::IndexOf($lines, '-----END JSON CONFIG-----');" ^
        "if ($begin -lt 1 -or $end -lt $begin) {" ^
        "    Write-Host 'Error: No embedded JSON configuration found' -ForegroundColor Red;" ^
        "    exit 1;" ^
        "};" ^
        "$json = $lines[$begin..($end - 1)] -join [Environment]::NewLine;" ^
        "[System.IO.File]::WriteAllText($env:config_primary, $json, [System.Text.UTF8Encoding]::new($false));"
    if !errorlevel! neq 0 (
        echo Error: Failed to write default config file
        echo.
        pause
        exit /b 1
    )
    set "config=!config_primary!"
    echo Default config file written: "!config!"
)
for /f %%i in ('powershell -NoProfile -Command "$arr = (Get-Content -Raw -Encoding UTF8 -Path \""!config!\"" | ConvertFrom-Json); [string]$arr.Count"') do set "length=%%i"
echo.



REM 遍历配置中的每一项，按修改时间自动备份 / 还原
for /l %%i in (1, 1, !length!) do (
    for /f "tokens=*" %%j in ('powershell -NoProfile -Command "(Get-Content -Raw -Encoding UTF8 -Path \""!config!\"" | ConvertFrom-Json)[%%i - 1].name"') do set "name=%%j"
    for /f "tokens=*" %%j in ('powershell -NoProfile -Command "(Get-Content -Raw -Encoding UTF8 -Path \""!config!\"" | ConvertFrom-Json)[%%i - 1].save"') do set "save=%%j"

    set "save=!save:%%USERPROFILE%%=%USERPROFILE%!"
    set "save=!save:%%PROGRAMDATA%%=%PROGRAMDATA%!"
    set "save=!save:%%PUBLIC%%=%PUBLIC%!"
    echo Processing %%i / !length! :  "!name!" at "!save!"

    set "ignore_args=/XF ""SaveLocation.bat"" /XF ""存档位置.bat"""
    for /f "delims=" %%k in ('powershell -NoProfile -Command "$item = (Get-Content -Raw -Encoding UTF8 -Path \""!config!\"" | ConvertFrom-Json)[%%i - 1].ignore; if ($item) { $item } else { }"') do (
        set "item=%%k"
        set "item=!item:%%USERPROFILE%%=%USERPROFILE%!"
        set "item=!item:%%PROGRAMDATA%%=%PROGRAMDATA%!"
        set "item=!item:%%PUBLIC%%=%PUBLIC%!"
        echo ignore item: "!item!"
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

    echo Max Local Time: [!max_local_time_string!] Max Backup Time: [!max_backup_time_string!]

    if "!max_local_time!"=="" (
        if "!max_backup_time!"=="" (
            echo Both local save files and backup files do not exist, skip with no operation
        ) else (
            echo Local save files are missing, begin to restore from backup files
            powershell -NoProfile -Command "$sh = New-Object -ComObject Shell.Application; $sh.Namespace(10).MoveHere(\""!save!\"")"
            robocopy . "!save!" /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH !ignore_args!
            if !errorlevel! geq 8 (
                echo Error: Restore failed
            )
        )
    ) else (
        echo if not exist "!save!" mkdir "!save!" > "SaveLocation.bat"
        echo "explorer.exe" "!save!" >> "SaveLocation.bat"
        powershell -NoProfile -Command "(Get-Item 'SaveLocation.bat').LastWriteTime = [DateTimeOffset]::FromUnixTimeSeconds(0).UtcDateTime"

        if "!max_backup_time!"=="" (
            echo Backup files are missing, begin to backup
            robocopy "!save!" . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH !ignore_args!
            if !errorlevel! geq 8 (
                echo Error: Backup failed
            ) else (
                git add .
                git diff --cached --quiet || git commit -m "Update - !name! on !machine_name! by !user_name!"
            )
        ) else (
            REM Use PowerShell for safe Ticks comparison (exceeds 32-bit integer range, cannot use cmd if numeric comparison)
            for /f "delims=" %%d in ('powershell -NoProfile -Command "try { $a=[long]::Parse($env:max_local_time); $b=[long]::Parse($env:max_backup_time); if ($a -lt $b) { Write-Output 'older' } elseif ($a -gt $b) { Write-Output 'newer' } else { Write-Output 'same' } } catch { Write-Output 'error' }"') do set "decision=%%d"
            if "!decision!"=="older" (
                echo Local files are older, moving to recycle bin and updating with backup files
                powershell -NoProfile -Command "$sh = New-Object -ComObject Shell.Application; $sh.Namespace(10).MoveHere(\""!save!\"")"
                robocopy . "!save!" /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH !ignore_args!
                if !errorlevel! geq 8 (
                    echo Error: Restore failed
                )
            ) else if "!decision!"=="newer" (
                echo Local files are newer, begin to backup
                robocopy "!save!" . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH !ignore_args!
                if !errorlevel! geq 8 (
                    echo Error: Backup failed
                ) else (
                    git add .
                    git diff --cached --quiet || git commit -m "Update - !name! on !machine_name! by !user_name!"
                )
            ) else if "!decision!"=="same" (
                echo Local save files and backup files are modified at same time, skip with no operation
            ) else (
                echo Error: Failed to compare modification time
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

echo Backup completed



echo.
pause
exit /b



-----BEGIN JSON CONFIG-----
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
-----END JSON CONFIG-----
