@echo off
setlocal enabledelayedexpansion
chcp 65001

:: jq-windows-amd64.exe
:: 1.7.1
:: https://jqlang.github.io/jq/download/



if /i "%cd%"=="%SystemRoot%\System32" (
    echo 当前目录为系统目录，不应该在这里执行
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
    echo if not exist "!save!" mkdir "!save!" > "存档位置.bat"
    echo "explorer.exe" "!save!" >> "存档位置.bat"

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
