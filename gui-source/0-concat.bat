@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion



if not exist "Backup.ps1" (
    echo Error: "Backup.ps1" file not found
    pause
    exit /b 1
)

(
    echo @echo off
    echo chcp 65001 ^>nul
    echo setlocal enabledelayedexpansion
    echo set "temp_file=%%temp%%\MyBatch_%%random%%_%%random%%_%%random%%_%%random%%.ps1"
    echo more +10 "%%~f0" ^> "^!temp_file^!"
    echo powershell.exe -NoProfile -ExecutionPolicy Bypass -File "^!temp_file^!"
    echo set exitcode=%%errorlevel%%
    echo del "^!temp_file^!" 2^>nul
    echo exit /b %%exitcode%%
    echo.
    type "Backup.ps1"
) > "../gui-i18n/GUI.bat"

echo Success: "GUI.bat" has been generated



echo.
pause
exit
