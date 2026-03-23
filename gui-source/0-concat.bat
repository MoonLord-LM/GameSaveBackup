@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion



REM Use this script to concat [ Backup.ps1 ] into [ GUI-0-concat.bat ]
REM When you run [ GUI-0-concat.bat ], it will generate [ Backup.ps1 ] into a temp file and run it automatically



if /i "%cd%"=="%SystemRoot%\System32" (
    echo Use "Run as administrator" from right-click menu, switching to script directory & echo.
    cd /d "%~dp0"
)

if not exist "Backup.ps1" (
    echo Error: "Backup.ps1" file not found
    echo.
    pause
    exit /b 1
)



set "new_file=GUI-0-concat.bat"
(
    echo @echo off
    echo chcp 65001 ^>nul
    echo setlocal enabledelayedexpansion
    echo powershell -NoProfile -Command "Write-Host '[ %~nx0 ]' -ForegroundColor Cyan" ^&^& echo.
    echo.
    echo.
    echo.
    echo REM Open source address: https://github.com/MoonLord-LM/GameSaveBackup
    echo.
    echo.
    echo.
    echo set "temp_file=%%temp%%\MyBatch_%%random%%_%%random%%_%%random%%_%%random%%.ps1"
    echo more +20 "%%~f0" ^> "^!temp_file^!"
    echo powershell -NoProfile -ExecutionPolicy Bypass -File "^!temp_file^!"
    echo.
    echo.
    echo.
    echo set "exitcode=^!errorlevel^!"
    echo if exist "^!temp_file^!" ^( del /f /q "^!temp_file^!" ^)
    echo exit /b ^!exitcode^!
    echo.
    echo.
    echo.
    type "Backup.ps1"
) > "!new_file!"

echo Success: file [ !new_file! ] has been generated



echo.
pause
exit
