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
