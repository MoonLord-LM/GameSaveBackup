@echo off
setlocal enabledelayedexpansion
chcp 65001

:: jq-windows-amd64.exe
:: 1.7.1
:: https://jqlang.github.io/jq/download/



if /i "%cd%"=="%SystemRoot%\System32" (
    echo Current directory is the system directory, no action should be done here
    pause
    exit
)

if not exist ".git" (
    git init
    git config --local core.autocrlf false
    git config --local core.safecrlf false
    git config --local core.ignorecase false
)

for /f "tokens=*" %%a in ('hostname') do set "machine_name=%%a"
for /f "tokens=3 delims=\" %%b in ('echo %USERPROFILE%') do set "user_name=%%b"
echo Machine Name: !machine_name! User Name: !user_name!

set "config=config.json"
for /f %%i in ('jq length "%config%"') do set "length=%%i"
echo.

for /l %%i in (1, 1, %length%) do (
    for /f "tokens=*" %%j in ('jq -r ".[%%i - 1].game" "%config%"') do set "game=%%j"
    for /f "tokens=*" %%j in ('jq -r ".[%%i - 1].save" "%config%"') do set "save=%%j"

    set "save=!save:%%USERPROFILE%%=%USERPROFILE%!"
    echo "progress %%i / !length!"  :  "!game!" in "!save!"

    if not exist "!game!" ( mkdir "!game!" )
    cd "!game!"

    for /f %%a in ('powershell -NoProfile -Command "((Get-ChildItem -Recurse -Path '!save!' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.Ticks)"') do set "max_local_time=%%a"
    for /f %%a in ('powershell -NoProfile -Command "((Get-ChildItem -Recurse -Path '%cd%\!game!' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.Ticks)"') do set "max_backup_time=%%a"
    for /f "delims=" %%a in ('powershell -NoProfile -Command "[datetime]::new(!max_local_time!, 'UTC').ToString('yyyy-MM-dd HH:mm:ss (zzz)')"') do set "max_local_time=%%a"
    for /f "delims=" %%a in ('powershell -NoProfile -Command "[datetime]::new(!max_backup_time!, 'UTC').ToString('yyyy-MM-dd HH:mm:ss (zzz)')"') do set "max_backup_time=%%a"
    echo Max Local Time: !max_local_time! Max Backup Time: !max_backup_time!

    if !max_local_time! gtr !max_backup_time! (
        echo Local file is newer, begin to backup
        xcopy "!save!" . /E /I /Y
        echo if not exist "!save!" mkdir "!save!" > "OpenSave.bat"
        echo "explorer.exe" "!save!" >> "OpenSave.bat"
        git add .
        git commit -m "Update - !game! on !machine_name! by !user_name!"
    ) else (
        echo Local file is older, no need to backup
    )

    cd ..
    echo.
)

git add .
git commit -m "Update - on !machine_name! by !user_name!"
git clean -df

endlocal
pause
exit
