@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion



if not exist "Backup.ps1" (
    echo Error: "Backup.ps1" file not found
    pause
    exit /b 1
)

set "BEGIN_MARKER=-----BEGIN POWERSHELL GZIP-----"
set "END_MARKER=-----END POWERSHELL GZIP-----"

(
    echo @echo off
    echo chcp 65001 ^>nul
    echo setlocal enabledelayedexpansion
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
    echo set exitcode=%%errorlevel%%
    echo if exist "%%temp_file%%" del "%%temp_file%%" 2^>nul
    echo exit /b %%exitcode%%
    echo.
    echo !BEGIN_MARKER!

    set "temp_file1=%temp%\MyBatch_%random%_%random%_%random%_%random%.ps1"
    powershell -NoProfile -Command ^
        "$lines = Get-Content -LiteralPath 'Backup.ps1' -Encoding utf8;" ^
        "$out = New-Object System.Collections.Generic.List[string];" ^
        "$prevEmpty = $false;" ^
        "foreach ($line in $lines) {" ^
        "    $l = $line.Trim();" ^
        "    if ($l.StartsWith('#')) { continue; }" ^
        "    if ($l -eq '') { continue; }" ^
        "    if ($out.Count -gt 0 -and $out[$out.Count-1].Contains('#') -eq $false) {" ^
        "        if ($out[$out.Count-1].EndsWith('{')) { $out[$out.Count-1] += $l; continue; }" ^
        "        if ($l.StartsWith('}')) { $out[$out.Count-1] += $l; continue; }" ^
        "    }" ^
        "    $out.Add($l);" ^
        "}" ^
        "[System.IO.File]::WriteAllLines(\""!temp_file1!\"", $out, [System.Text.Encoding]::UTF8);"

    set "exe_7z=C:\Program Files\7-Zip\7z.exe"
    if exist "!exe_7z!" (
        set "temp_file2=%temp%\MyBatch_%random%_%random%_%random%_%random%.ps1"
        "!exe_7z!" a -tgzip -mx=9 "!temp_file2!" "!temp_file1!" >nul
        powershell -NoProfile -Command ^
            "$bytes = [System.IO.File]::ReadAllBytes(\""!temp_file2!\"");" ^
            "$base64 = [Convert]::ToBase64String($bytes);" ^
            "for ($i = 0; $i -lt $base64.Length; $i += 64) {" ^
            "    $base64.Substring($i, [Math]::Min(64, $base64.Length - $i));" ^
            "}"
    ) else (
        powershell -NoProfile -Command ^
            "$bytes = [System.IO.File]::ReadAllBytes(\""!temp_file1!\"");" ^
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
    )
    echo !END_MARKER!
) > "../gui-i18n/GUI.bat"

echo Success: "GUI.bat" has been generated



echo.
pause
exit
