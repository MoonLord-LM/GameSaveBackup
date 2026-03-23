@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion



REM Use this script to minify [ Backup.ps1 ] into [ GUI-3-min.bat ]
REM When you run [ GUI-3-min.bat ], it will generate [ Backup.ps1 ] into a temp file and run it automatically



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



set "new_file=GUI-3-min.bat"
set "exe_7z=%ProgramFiles%\7-Zip\7z.exe"

set "BEGIN_MARKER=-----BEGIN POWERSHELL ZIP-----"
set "END_MARKER=-----END POWERSHELL ZIP-----"

(
    echo @echo off
    echo chcp 65001 ^>nul
    echo setlocal enabledelayedexpansion
    echo powershell -NoProfile -Command "Write-Host '[ %%~nx0 ]' -ForegroundColor Cyan" ^&^& echo.
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
    echo powershell -NoProfile -Command ^^
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
    echo     "$ms = New-Object System.IO.MemoryStream (,$bytes);" ^^
    echo     "$gzip = New-Object System.IO.Compression.GzipStream($ms, [System.IO.Compression.CompressionMode]::Decompress);" ^^
    echo     "$outMs = New-Object System.IO.MemoryStream;" ^^
    echo     "$gzip.CopyTo($outMs);" ^^
    echo     "$gzip.Close();" ^^
    echo     "$ms.Close();" ^^
    echo     "$rawBytes = $outMs.ToArray();" ^^
    echo     "$outMs.Close();" ^^
    echo     "[System.IO.File]::WriteAllBytes($env:temp_file, $rawBytes);" ^^
    echo     "& $env:temp_file;" ^^
    echo     "exit $LASTEXITCODE;"
    echo.
    echo.
    echo.
    echo set "exitcode=^!errorlevel^!"
    echo if exist "^!temp_file^!" ^( del /f /q "^!temp_file^!" ^)
    echo exit /b ^!exitcode^!
    echo.
    echo.
    echo.
    echo !BEGIN_MARKER!

    set "temp_file_min=%temp%\MyBatch_%random%_%random%_%random%_%random%.ps1"
    powershell -NoProfile -Command ^
        "$input = Get-Content -LiteralPath 'Backup.ps1' -Encoding utf8;" ^
        "$out = New-Object System.Collections.Generic.List[string];" ^
        "foreach ($i in $input) {" ^
        "    $line = $i.Trim();" ^
        "    if ($line.StartsWith('#')) {" ^
        "        continue;" ^
        "    }" ^
        "    if ($line -eq '') {" ^
        "        continue;" ^
        "    }" ^
        "    if ($out.Count -gt 0) {" ^
        "        if ($out[$out.Count-1].Contains('#') -eq $false) {" ^
        "            if ($out[$out.Count-1].EndsWith('{')) {" ^
        "                $out[$out.Count-1] += ''+$line;" ^
        "                continue;" ^
        "            }" ^
        "            if ($line.StartsWith('}')) {" ^
        "                $out[$out.Count-1] += ''+$line;" ^
        "                continue;" ^
        "            }" ^
        "        }" ^
        "    }" ^
        "    $out.Add($line);" ^
        "}" ^
        "[System.IO.File]::WriteAllLines(\"!temp_file_min!\", $out, [System.Text.Encoding]::UTF8);"

    if exist "!exe_7z!" (
        set "temp_file_7z=%temp%\MyBatch_%random%_%random%_%random%_%random%.ps1"
        "!exe_7z!" a -tgzip -mx=9 -mtc=off -mtm=off -mta=off -siBackup.ps1 "!temp_file_7z!" < "!temp_file_min!" >nul
        powershell -NoProfile -Command ^
            "$bytes = [System.IO.File]::ReadAllBytes(\"!temp_file_7z!\");" ^
            "$base64 = [Convert]::ToBase64String($bytes);" ^
            "for ($i = 0; $i -lt $base64.Length; $i += 64) {" ^
            "    $base64.Substring($i, [Math]::Min(64, $base64.Length - $i));" ^
            "}"
        if exist "!temp_file_7z!" ( del /f /q "!temp_file_7z!" )
    ) else (
        powershell -NoProfile -Command ^
            "$rawBytes = [System.IO.File]::ReadAllBytes(\"!temp_file_min!\");" ^
            "$ms = New-Object System.IO.MemoryStream;" ^
            "$gzip = New-Object System.IO.Compression.GzipStream($ms, [System.IO.Compression.CompressionMode]::Compress);" ^
            "$gzip.Write($rawBytes, 0, $rawBytes.Length);" ^
            "$gzip.Close();" ^
            "$bytes = $ms.ToArray();" ^
            "$ms.Close();" ^
            "$base64 = [Convert]::ToBase64String($bytes);" ^
            "for ($i = 0; $i -lt $base64.Length; $i += 64) {" ^
            "    $base64.Substring($i, [Math]::Min(64, $base64.Length - $i));" ^
            "}"
    )
    if exist "!temp_file_min!" ( del /f /q "!temp_file_min!" )
    echo !END_MARKER!
) > "!new_file!"

if exist "!exe_7z!" (
    echo Use 7zip to compress the file
    echo.
) else (
    echo Use PowerShell to compress the file
    echo.
)

echo Success: file [ !new_file! ] has been generated



echo.
pause
exit
