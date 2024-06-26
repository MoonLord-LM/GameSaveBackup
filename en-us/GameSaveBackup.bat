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
    xcopy "!save!" . /E /I /Y
    echo "explorer.exe" "!save!" > "OpenSave.bat"

    git add .
    git commit -m "Update - !game!"
    cd ..
    echo.
)

git add .
git commit -m "Update"

endlocal
pause
exit
