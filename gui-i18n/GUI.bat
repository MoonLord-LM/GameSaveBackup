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
7NuXmwAA
-----END POWERSHELL ZIP-----
