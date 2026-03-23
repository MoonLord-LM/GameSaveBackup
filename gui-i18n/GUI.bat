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
-----END POWERSHELL ZIP-----
