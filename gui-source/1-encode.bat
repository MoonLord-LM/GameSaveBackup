@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion



REM Use this script to encode [ Backup.ps1 ] into [ GUI-1-encode.bat ]
REM When you run [ GUI-1-encode.bat ], it will generate [ Backup.ps1 ] into a temp file and run it automatically



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



set "new_file=GUI-1-encode.bat"

set "BEGIN_MARKER=-----BEGIN POWERSHELL-----"
set "END_MARKER=-----END POWERSHELL-----"

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
    echo set "self_path=%%~f0"
    echo.
    echo powershell -NoProfile -ExecutionPolicy Bypass -Command ^^
    echo     "$lines = Get-Content -LiteralPath $env:self_path -Encoding utf8;" ^^
    echo     "$startIndex = -1;" ^^
    echo     "$endIndex = -1;" ^^
    echo     "for ($i = 0; $i -lt $lines.Length; $i++) {" ^^
    echo     "    if ($lines[$i] -eq '%BEGIN_MARKER%') {" ^^
    echo     "        $startIndex = $i;" ^^
    echo     "        break;" ^^
    echo     "    }" ^^
    echo     "}" ^^
    echo     "if ($startIndex -eq -1) {" ^^
    echo     "    Write-Error 'BEGIN marker not found';" ^^
    echo     "    exit 1;" ^^
    echo     "}" ^^
    echo     "for ($i = $startIndex + 1; $i -lt $lines.Length; $i++) {" ^^
    echo     "    if ($lines[$i] -eq '%END_MARKER%') {" ^^
    echo     "        $endIndex = $i;" ^^
    echo     "        break;" ^^
    echo     "    }" ^^
    echo     "}" ^^
    echo     "if ($endIndex -eq -1) {" ^^
    echo     "    Write-Error 'END marker not found';" ^^
    echo     "    exit 1;" ^^
    echo     "}" ^^
    echo     "if ($endIndex - $startIndex -le 1) {" ^^
    echo     "    Write-Error 'Base64 content not found';" ^^
    echo     "    exit 1;" ^^
    echo     "}" ^^
    echo     "$base64Lines = $lines[($startIndex+1)..($endIndex-1)];" ^^
    echo     "$base64 = $base64Lines -join '';" ^^
    echo     "$base64 = $base64 -replace '\s', '';" ^^
    echo     "$bytes = [Convert]::FromBase64String($base64);" ^^
    echo     "[System.IO.File]::WriteAllBytes($env:temp_file, $bytes);" ^^
    echo     "& $env:temp_file;" ^^
    echo     "exit $LASTEXITCODE;"
    echo.
    echo.
    echo.
    echo set "exitcode=^!errorlevel^!"
    echo del "^!temp_file^!" 2^>nul
    echo exit /b ^!exitcode^!
    echo.
    echo.
    echo.
    echo !BEGIN_MARKER!

    powershell -NoProfile -Command ^
        "$bytes = [System.IO.File]::ReadAllBytes(\"Backup.ps1\");" ^
        "$base64 = [Convert]::ToBase64String($bytes);" ^
        "for ($i = 0; $i -lt $base64.Length; $i += 64) {" ^
        "    $base64.Substring($i, [Math]::Min(64, $base64.Length - $i));" ^
        "}"
    echo !END_MARKER!
) > "!new_file!"

echo Success: file [ !new_file! ] has been generated



echo.
pause
exit
