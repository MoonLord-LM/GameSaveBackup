@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion



if /i "%cd%"=="%SystemRoot%\System32" (
    echo Use "Run as administrator" from right-click menu, switching to script directory
    cd /d "%~dp0"
)

"git.exe" --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Missing git.exe component
    echo Please download from https://git-scm.com/install/windows
    "explorer.exe" "https://git-scm.com/install/windows"
    pause
    exit
)

if not exist ".git" (
    git init
    git config --local core.autocrlf false
    git config --local core.safecrlf false
    git config --local core.ignorecase false

    git config --local core.quotepath false
    git config --local i18n.logoutputencoding utf-8
    git config --local i18n.commitencoding utf-8
)

for /f "tokens=*" %%a in ('hostname') do set "machine_name=%%a"
for /f "tokens=*" %%b in ('powershell -NoProfile -Command "[Environment]::UserName"') do set "user_name=%%b"
echo Machine Name: !machine_name! User Name: !user_name!

set "json_count=0"
for %%f in (*.json) do (
    set /a json_count+=1
    set "config=%%f"
)
if !json_count! equ 0 (
    echo Error: No [.json] configuration file found in the current directory
    echo Please ensure there is [.json] configuration file in this directory
    pause
    exit
)
if !json_count! gtr 1 (
    echo Error: Multiple [.json] configuration files found in the current directory, total: !json_count!
    echo Please keep only one [.json] configuration file
    pause
    exit
)

echo Using configuration file: [!config!]
for /f %%i in ('powershell -NoProfile -Command "$arr = (Get-Content -Raw -Encoding UTF8 -Path \""!config!\"" | ConvertFrom-Json); [string]$arr.Count"') do set "length=%%i"
echo.

for /l %%i in (1, 1, !length!) do (
    for /f "tokens=*" %%j in ('powershell -NoProfile -Command "(Get-Content -Raw -Encoding UTF8 -Path \""!config!\"" | ConvertFrom-Json)[%%i - 1].name"') do set "name=%%j"
    for /f "tokens=*" %%j in ('powershell -NoProfile -Command "(Get-Content -Raw -Encoding UTF8 -Path \""!config!\"" | ConvertFrom-Json)[%%i - 1].save"') do set "save=%%j"

    set "save=!save:%%USERPROFILE%%=%USERPROFILE%!"
    set "save=!save:%%PROGRAMDATA%%=%PROGRAMDATA%!"
    echo Processing %%i / !length! :  "!name!" at "!save!"

    set "ignore_args="
    for /f "delims=" %%k in ('powershell -NoProfile -Command "$item = (Get-Content -Raw -Encoding UTF8 -Path \""!config!\"" | ConvertFrom-Json)[%%i - 1].ignore; if ($item) { $item } else { }"') do (
        set "item=%%k"
        set "item=!item:%%USERPROFILE%%=%USERPROFILE%!"
        set "item=!item:%%PROGRAMDATA%%=%PROGRAMDATA%!"
        echo ignore item: "!item!"
        set "ignore_args=!ignore_args! /XF "!item!" /XD "!item!""
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
            robocopy . "!save!" /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH /XF "存档位置.bat" /XF "SaveLocation.bat" !ignore_args!
        )
    ) else if "!max_backup_time!"=="" (
        echo Backup files are missing, begin to backup
        if not exist "SaveLocation.bat" (
            echo if not exist "!save!" mkdir "!save!" > "SaveLocation.bat"
            echo "explorer.exe" "!save!" >> "SaveLocation.bat"
            powershell -NoProfile -Command "(Get-Item 'SaveLocation.bat').LastWriteTime = [DateTimeOffset]::FromUnixTimeSeconds(0).UtcDateTime"
        )
        robocopy "!save!" . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH /XF "存档位置.bat" /XF "SaveLocation.bat" !ignore_args!
        git add .
        git diff --cached --quiet || git commit -m "Update - !name! on !machine_name! by !user_name!"
    ) else if !max_local_time! lss !max_backup_time! (
        echo Local files are older, moving to recycle bin and updating with backup files
        powershell -NoProfile -Command "$sh = New-Object -ComObject Shell.Application; $sh.Namespace(10).MoveHere(\""!save!\"")"
        robocopy . "!save!" /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH /XF "存档位置.bat" /XF "SaveLocation.bat" !ignore_args!
    ) else if !max_local_time! gtr !max_backup_time! (
        echo Local files are newer, begin to backup
        robocopy "!save!" . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH /XF "存档位置.bat" /XF "SaveLocation.bat" !ignore_args!
        git add .
        git diff --cached --quiet || git commit -m "Update - !name! on !machine_name! by !user_name!"
    ) else (
        echo Local save files and backup files are modified at same time, skip with no operation
    )

    cd ..
    echo.
)

git add .
git diff --cached --quiet || ( git commit -m "Update - on !machine_name! by !user_name!" && echo. )
git clean -df >nul

echo Backup completed
echo.

pause
exit
