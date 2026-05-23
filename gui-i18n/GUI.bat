@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
powershell -NoProfile -Command "Write-Host '[ %~nx0 ]' -ForegroundColor Cyan" && echo.



REM Open source address: https://github.com/MoonLord-LM/GameSaveBackup



set "temp_file=%temp%\MyBatch_%random%_%random%_%random%_%random%.ps1"
set "self_path=%~f0"

powershell -NoProfile -Command ^
    "$lines = Get-Content -LiteralPath $env:self_path -Encoding utf8;" ^
    "$startIndex = -1;" ^
    "$endIndex = -1;" ^
    "for ($i = 0; $i -lt $lines.Length; $i++) {" ^
    "    if ($lines[$i] -eq '-----BEGIN POWERSHELL ZIP-----') {" ^
    "        $startIndex = $i;" ^
    "        break;" ^
    "    }" ^
    "}" ^
    "if ($startIndex -eq -1) {" ^
    "    Write-Error 'BEGIN marker not found';" ^
    "    exit 1;" ^
    "}" ^
    "for ($i = $startIndex + 1; $i -lt $lines.Length; $i++) {" ^
    "    if ($lines[$i] -eq '-----END POWERSHELL ZIP-----') {" ^
    "        $endIndex = $i;" ^
    "        break;" ^
    "    }" ^
    "}" ^
    "if ($endIndex -eq -1) {" ^
    "    Write-Error 'END marker not found';" ^
    "    exit 1;" ^
    "}" ^
    "if ($endIndex - $startIndex -le 1) {" ^
    "    Write-Error 'Base64 content not found';" ^
    "    exit 1;" ^
    "}" ^
    "$base64Lines = $lines[($startIndex+1)..($endIndex-1)];" ^
    "$base64 = $base64Lines -join '';" ^
    "$base64 = $base64 -replace '\s', '';" ^
    "$bytes = [Convert]::FromBase64String($base64);" ^
    "$ms = New-Object System.IO.MemoryStream (,$bytes);" ^
    "$gzip = New-Object System.IO.Compression.GzipStream($ms, [System.IO.Compression.CompressionMode]::Decompress);" ^
    "$outMs = New-Object System.IO.MemoryStream;" ^
    "$gzip.CopyTo($outMs);" ^
    "$gzip.Close();" ^
    "$ms.Close();" ^
    "$rawBytes = $outMs.ToArray();" ^
    "$outMs.Close();" ^
    "[System.IO.File]::WriteAllBytes($env:temp_file, $rawBytes);" ^
    "& $env:temp_file;" ^
    "exit $LASTEXITCODE;"



set "exitcode=!errorlevel!"
if exist "!temp_file!" ( del /f /q "!temp_file!" )
exit /b 



-----BEGIN POWERSHELL ZIP-----
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
/AJo1uro7qEAAA==
-----END POWERSHELL ZIP-----
