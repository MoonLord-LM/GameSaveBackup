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
+B2rwuLLe8QAAA==
-----END POWERSHELL ZIP-----
