@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

if not exist "Backup.ps1" (
    echo Error: "Backup.ps1" file not found
    pause
    exit /b 1
)

SET "BEGIN_MARKER=-----BEGIN POWERSHELL SCRIPT-----"
SET "END_MARKER=-----END POWERSHELL SCRIPT-----"

(
    echo @echo off
    echo chcp 65001 ^>nul
    echo setlocal enabledelayedexpansion
    echo set "temp_file=%%temp%%\MyBatch_%%random%%_%%random%%_%%random%%_%%random%%.ps1"
    echo set "self_path=%%~f0"
    echo.
    echo powershell -NoProfile -ExecutionPolicy Bypass -Command ^^
    echo     "$lines = Get-Content -LiteralPath $env:self_path -Encoding utf8;" ^^
    echo     "$startIndex = -1; $endIndex = -1;" ^^
    echo     "for ($i = 0; $i -lt $lines.Length; $i++) { if ($lines[$i] -eq '%BEGIN_MARKER%') { $startIndex = $i; break } }" ^^
    echo     "if ($startIndex -eq -1) { Write-Error 'BEGIN marker not found'; exit 1 }" ^^
    echo     "for ($i = $startIndex + 1; $i -lt $lines.Length; $i++) { if ($lines[$i] -eq '%END_MARKER%') { $endIndex = $i; break } }" ^^
    echo     "if ($endIndex -eq -1) { Write-Error 'END marker not found'; exit 1 }" ^^
    echo     "$b64Lines = @(); if ($endIndex - $startIndex -gt 1) { $b64Lines = $lines[($startIndex+1)..($endIndex-1)] }" ^^
    echo     "$b64 = $b64Lines -join '';" ^^
    echo     "$b64 = $b64 -replace '\s', '';" ^^
    echo     "$bytes = [Convert]::FromBase64String($b64);" ^^
    echo     "$ms = New-Object System.IO.MemoryStream (,$bytes);" ^^
    echo     "$gzip = New-Object System.IO.Compression.GzipStream($ms, [System.IO.Compression.CompressionMode]::Decompress);" ^^
    echo     "$outMs = New-Object System.IO.MemoryStream;" ^^
    echo     "$gzip.CopyTo($outMs); $gzip.Close(); $ms.Close();" ^^
    echo     "$rawBytes = $outMs.ToArray(); $outMs.Close();" ^^
    echo     "[System.IO.File]::WriteAllBytes($env:temp_file, $rawBytes);" ^^
    echo     "& $env:temp_file; exit $LASTEXITCODE"
    echo.
    echo set exitcode=%%errorlevel%%
    echo if exist "%%temp_file%%" del "%%temp_file%%" 2^>nul
    echo exit /b %%exitcode%%
    echo %BEGIN_MARKER%
    echo.
) > "Backup.enc.bat"

echo 正在压缩和编码...

(
    powershell -NoProfile -Command ^
        "$bytes = [System.IO.File]::ReadAllBytes(\""Backup.ps1\"");" ^
        "$ms = New-Object System.IO.MemoryStream;" ^
        "$gzip = New-Object System.IO.Compression.GzipStream($ms, [System.IO.Compression.CompressionMode]::Compress);" ^
        "$gzip.Write($bytes, 0, $bytes.Length);" ^
        "$gzip.Close();" ^
        "$compressed = $ms.ToArray();" ^
        "$ms.Close();" ^
        "$base64 = [Convert]::ToBase64String($compressed);" ^
        "for ($i = 0; $i -lt $base64.Length; $i += 64) {" ^
        "    $base64.Substring($i, [Math]::Min(64, $base64.Length - $i));" ^
        "}"
) >> "Backup.enc.bat"

(
    echo %END_MARKER%
) >> "Backup.enc.bat"

echo Success: "Backup.enc.bat" has been generated

echo.
pause
exit
