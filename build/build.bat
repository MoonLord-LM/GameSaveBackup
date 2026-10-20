@echo off
chcp 65001 >nul
setlocal disabledelayedexpansion
set "script=%~0" & set "script_path=%~f0" & set "script_dir=%~dp0" & set "script_name=%~n0" & set "script_ext=%~x0" & set "script_name_ext=%~nx0"
set "param1=%~1" & set "param1_path=%~f1" & set "param1_dir=%~dp1" & set "param1_name=%~n1" & set "param1_ext=%~x1" & set "param1_name_ext=%~nx1"
setlocal enabledelayedexpansion
if /i "!cd!"=="!SystemRoot!\System32" ( cd /d "!script_dir!" )
powershell -NoProfile -Command "Write-Host '[ !script_name_ext! ]' -ForegroundColor Cyan" && echo.



powershell -NoProfile -Command "Write-Host '将单个文件，打包转换为 exe 窗体程序，自动附加图标' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '双击运行时，按提示输入要打包转换的文件的路径；也可以拖拽单个文件到此脚本上' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '适用于对不需要控制台交互的程序打包，不会显示 cmd 黑窗口，但是也无法展示输入输出流' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '双击生成的 exe 脚本，自动解码解压并打开原文件，如果是 ps1 / bat / py / exe 则自动执行' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '处理方式：把原文件内容，执行压缩，嵌入到自解压的 C# 程序中作为资源，编译出 exe 文件' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '尝试使用 PowerShell 内置的 GZipStream / makecab.exe / 7-Zip 压缩，尽可能压缩到最小' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '优先使用系统的 C# Roslyn 编译器并开启 /deterministic 参数，保证相同输入打包出的 exe 字节完全一致' -ForegroundColor Green"
echo.



REM 检查 7-Zip 组件（可选）
if exist "!script_dir!7za.exe" (
    set "seven_zip=!script_dir!7za.exe"
) else if exist "!cd!\7za.exe" (
    set "seven_zip=!cd!\7za.exe"
) else if exist "!script_dir!..\7za.exe" (
    set "seven_zip=!script_dir!..\7za.exe"
) else if exist "..\7za.exe" (
    set "seven_zip=..\7za.exe"
) else if exist "!ProgramFiles!\7-Zip\7z.exe" (
    set "seven_zip=!ProgramFiles!\7-Zip\7z.exe"
) else if exist "!ProgramFiles(x86)!\7-Zip\7z.exe" (
    set "seven_zip=!ProgramFiles(x86)!\7-Zip\7z.exe"
) else (
    set "seven_zip=7z"
)
"!seven_zip!" i >nul 2>&1
if !errorlevel! neq 0 (
    set "seven_zip="
)

REM 检查 7-Zip 自解压模块（可选）
if exist "!script_dir!7zCon.sfx" (
    set "seven_zip_sfx=!script_dir!7zCon.sfx"
) else if exist "!cd!\7zCon.sfx" (
    set "seven_zip_sfx=!cd!\7zCon.sfx"
) else if exist "!script_dir!..\7zCon.sfx" (
    set "seven_zip_sfx=!script_dir!..\7zCon.sfx"
) else if exist "..\7zCon.sfx" (
    set "seven_zip_sfx=..\7zCon.sfx"
) else if exist "!ProgramFiles!\7-Zip\7zCon.sfx" (
    set "seven_zip_sfx=!ProgramFiles!\7-Zip\7zCon.sfx"
) else if exist "!ProgramFiles(x86)!\7-Zip\7zCon.sfx" (
    set "seven_zip_sfx=!ProgramFiles(x86)!\7-Zip\7zCon.sfx"
) else (
    set "seven_zip_sfx="
)

REM 检查 C# Roslyn 编译器（可选）
set "csharp_roslyn_compiler="
for %%v in (18 2022) do (
    for %%r in ("!ProgramFiles!" "!ProgramFiles(x86)!") do (
        for %%e in (Enterprise Professional Community BuildTools) do (
            if "!csharp_roslyn_compiler!"=="" (
                if exist "%%~r\Microsoft Visual Studio\%%v\%%e\MSBuild\Current\Bin\Roslyn\csc.exe" (
                    set "csharp_roslyn_compiler=%%~r\Microsoft Visual Studio\%%v\%%e\MSBuild\Current\Bin\Roslyn\csc.exe"
                )
            )
        )
    )
)



REM ============================================================
REM 调试与一致性分析（服务器产物不一致排查）
REM   GSB_DEBUG=0         关闭调试（恢复正常速度）
REM   GSB_ECHO=1          同时开启命令回显（最详细）
REM   GSB_REFERENCE=路径  指定参考 exe，做二进制比对
REM 每次运行生成日志 %temp%\MyBatch\build_*.log
REM 以及 %temp%\MyBatch\debug\run_*.txt（含全部哈希/环境/比对结果），
REM 把不同服务器/不同次运行的日志拿到本地用文本对比即可定位差异。
REM ============================================================
set "DEBUG=1"
if defined GSB_DEBUG ( set "DEBUG=!GSB_DEBUG!" )
set "log_file=%temp%\MyBatch\build_!script_name!.log"
if not exist "%temp%\MyBatch" ( mkdir "%temp%\MyBatch" >nul 2>&1 )
set "debug_dir=%temp%\MyBatch\debug"
if not exist "!debug_dir!" ( mkdir "!debug_dir!" >nul 2>&1 )
set "manifest_file=!debug_dir!\run_!script_name!_!random!.txt"
if "!DEBUG!"=="1" (
    call :log "============================================================"
    call :log "build.bat 启动（服务器产物不一致排查）"
    call :log "时间：!date! !time!"
    call :log "脚本：!script_path!"
    call :log "工作目录：!cd!"
    call :log "临时目录 TEMP：!temp!"
    call :log "7-Zip：!seven_zip!"
    call :log "7-Zip SFX：!seven_zip_sfx!"
    call :log "C# Roslyn：!csharp_roslyn_compiler!"
    call :log "DEBUG=!DEBUG!"
    call :log "--- 环境信息快照（本地与服务器对比，定位差异来源）---"
    call :env_dump
    call :log "------------------------------------------------------------"
)
if "!DEBUG!"=="1" if defined GSB_ECHO ( echo on )

set "input_file=!param1_path!"

:input_file
    if "!input_file!"=="" (
        echo 请输入要打包转换的文件的路径
        set /p "input_file="
        if !errorlevel! neq 0 (
            echo 无输入，退出脚本
            echo.
            exit /b 1
        )
        echo.
    )
    if "!input_file!"=="" (
        echo 输入不能为空，请重新输入
        echo.
        goto input_file
    )
    set "input_file=!input_file:"=!"
    if "!input_file!"=="" (
        echo 输入不能为空，请重新输入
        echo.
        goto input_file
    )
    if "!input_file:~-1!"=="\" set "input_file=!input_file:~0,-1!"
    if not exist "!input_file!" (
        echo 错误：路径不存在："!input_file!"，请重新输入
        echo.
        set "input_file="
        goto input_file
    )
    if exist "!input_file!\" (
        echo 错误：不支持文件夹，请输入单个文件
        echo.
        set "input_file="
        goto input_file
    )



echo 开始处理："!input_file!"
echo.

for %%i in ("!input_file!") do (
    setlocal disabledelayedexpansion
    set "file_dir=%%~dpi"
    set "base_name=%%~ni"
    set "file_name_ext=%%~nxi"
    setlocal enabledelayedexpansion

    set "file_size=-1"
    for /f %%s in ('powershell -NoProfile -Command "try { ([System.IO.FileInfo]($env:input_file)).Length } catch { -1 }"') do set "file_size=%%s"
    if "!file_size!"=="-1" (
        echo 错误：文件大小获取失败："!input_file!"
        echo.
        pause
        exit /b 1
    )
    echo 原始大小：!file_size! 字节
    set "input_size=!file_size!"
    echo.

    REM 计算文件内容的 SHA512 哈希值
    set "file_sha512="
    for /f "delims=" %%a in ('
        powershell -NoProfile -Command ^
            "[System.Console]::OutputEncoding=[System.Text.Encoding]::UTF8;" ^
            "$sha512 = [System.Security.Cryptography.SHA512]::Create();" ^
            "$fileBytes = [System.IO.File]::ReadAllBytes($env:input_file);" ^
            "Write-Output ([System.BitConverter]::ToString($sha512.ComputeHash($fileBytes)).Replace('-', '').ToLowerInvariant());"
    ') do (
        set "file_sha512=%%a"
    )
    if "!file_sha512!"=="" (
        echo 错误：计算文件内容的 SHA512 哈希值失败："!input_file!"
        echo.
        pause
        exit /b 1
    )

    REM 如果输出文件已存在，则继续追加 .exe 后缀，直到文件名不重复
    set "output_file=!file_dir!!base_name!.exe"
    for /l %%n in (1,1,16) do (
        if exist "!output_file!" set "output_file=!output_file!.exe"
    )
    echo 目标文件："!output_file!"
    echo.

    REM 临时文件统一放在固定目录，保证生成一致性
    set "temp_dir=%temp%\MyBatch\cache\!file_size!\!file_sha512!"
    if not exist "!temp_dir!" ( mkdir "!temp_dir!" )



    REM 方式一：压缩为 gzip 格式
    set "temp_gzip=!temp_dir!\archive.gz"
    if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
    if "!seven_zip!"=="" (
        echo 压缩方式：使用 PowerShell 内置的 GZipStream 压缩
        powershell -NoProfile -Command ^
            "[System.Console]::OutputEncoding=[System.Text.Encoding]::UTF8;" ^
            "Add-Type -AssemblyName System.IO.Compression;" ^
            "$rawBytes = [System.IO.File]::ReadAllBytes($env:input_file);" ^
            "$memStream = New-Object System.IO.MemoryStream;" ^
            "$mode = [System.IO.Compression.CompressionMode]::Compress;" ^
            "$gzipStream = New-Object System.IO.Compression.GzipStream($memStream, $mode);" ^
            "$gzipStream.Write($rawBytes, 0, $rawBytes.Length);" ^
            "$gzipStream.Close();" ^
            "$bytes = $memStream.ToArray();" ^
            "$memStream.Close();" ^
            "[System.IO.File]::WriteAllBytes($env:temp_gzip, $bytes);"
        if !errorlevel! neq 0 (
            echo 错误：压缩失败："!input_file!"
            echo.
            if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
            pause
            exit /b 1
        )
    ) else (
        echo 压缩方式：使用 7-Zip 压缩 gzip 格式
        "!seven_zip!" a -tgzip -mx=9 -mmt=on -mtc=off -mtm=off -mta=off -si"!file_name_ext!" "!temp_gzip!" < "!input_file!" >nul
        if !errorlevel! neq 0 (
            echo 错误：压缩失败："!input_file!"
            echo.
            if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
            pause
            exit /b 1
        )
    )
    if not exist "!temp_gzip!" (
        echo 错误：压缩文件生成失败："!temp_gzip!"
        echo.
        pause
        exit /b 1
    )

    call :log "[gzip] 压缩完成，开始一致性检测"
    call :hash_file "!temp_gzip!"
    call :log "[gzip] 主压缩包 SHA256：!hf_hash!"
    call :peek "!temp_gzip!" 12
    call :log "[gzip] 文件头前12字节(含mtime/OS字段，跨运行若变化说明压缩含时间戳)：!pk_hex!"
    if "!DEBUG!"=="1" (
        set "temp_gzip_repeat=!temp_dir!\archive_repeat.gz"
        if exist "!temp_gzip_repeat!" ( del /f /q "!temp_gzip_repeat!" )
        if "!seven_zip!"=="" (
            powershell -NoProfile -Command "[System.Console]::OutputEncoding=[System.Text.Encoding]::UTF8; Add-Type -AssemblyName System.IO.Compression; $rawBytes=[System.IO.File]::ReadAllBytes($env:input_file); $memStream=New-Object System.IO.MemoryStream; $mode=[System.IO.Compression.CompressionMode]::Compress; $gzipStream=New-Object System.IO.Compression.GzipStream($memStream,$mode); $gzipStream.Write($rawBytes,0,$rawBytes.Length); $gzipStream.Close(); $bytes=$memStream.ToArray(); $memStream.Close(); [System.IO.File]::WriteAllBytes($env:temp_gzip_repeat,$bytes);"
        ) else (
            "!seven_zip!" a -tgzip -mx=9 -mmt=on -mtc=off -mtm=off -mta=off -si"!file_name_ext!" "!temp_gzip_repeat!" < "!input_file!" >nul
        )
        if !errorlevel! neq 0 (
            call :log "[gzip] 重复压缩失败"
        ) else (
            call :hash_file "!temp_gzip_repeat!"
            call :log "[gzip] 重复压缩 SHA256：!hf_hash!"
            call :bin_cmp "!temp_gzip!" "!temp_gzip_repeat!"
            call :log "[gzip] 重复压缩二进制比对：!bc_result!"
        )
    )



    REM 方式二：压缩为 cab 格式
    echo 压缩方式：使用 makecab 压缩 cab 格式
    set "temp_cab=!temp_dir!\archive.cab"
    if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
    makecab /D CompressionType=LZX /D CompressionMemory=21 "!input_file!" "!temp_cab!" >nul
    if !errorlevel! neq 0 (
        echo 错误：压缩失败："!input_file!"
        echo.
        if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
        if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
        pause
        exit /b 1
    )
    if not exist "!temp_cab!" (
        if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
        echo 错误：压缩文件生成失败："!temp_cab!"
        echo.
        pause
        exit /b 1
    )

    call :log "[cab] 压缩完成，开始一致性检测"
    call :hash_file "!temp_cab!"
    call :log "[cab] 主压缩包 SHA256：!hf_hash!"
    if "!DEBUG!"=="1" (
        set "temp_cab_repeat=!temp_dir!\archive_repeat.cab"
        if exist "!temp_cab_repeat!" ( del /f /q "!temp_cab_repeat!" )
        makecab /D CompressionType=LZX /D CompressionMemory=21 "!input_file!" "!temp_cab_repeat!" >nul
        if !errorlevel! neq 0 (
            call :log "[cab] 重复压缩失败"
        ) else (
            call :hash_file "!temp_cab_repeat!"
            call :log "[cab] 重复压缩 SHA256：!hf_hash!"
            call :bin_cmp "!temp_cab!" "!temp_cab_repeat!"
            call :log "[cab] 重复压缩二进制比对：!bc_result!"
        )
    )



    REM 方式三：压缩为 7z 格式的自解压 exe
    set "use_7z_exe=0"
    if not "!seven_zip!"=="" (
        if not "!seven_zip_sfx!"=="" (
            set "use_7z_exe=1"
        )
    )
    if "!use_7z_exe!"=="0" (
        echo 缺少 7-Zip 组件或自解压模块，只使用 gzip / cab 方式压缩
        echo.
    )
    if "!use_7z_exe!"=="1" (
        echo 压缩方式：使用 7z 自解压 exe 格式
        set "temp_7z=!temp_dir!\archive.7z"
        if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
        "!seven_zip!" a -t7z -mx=9 -m0=LZMA2 -md=2048m -mfb=256 -ms=off -mmt=on -mtc=off -mtm=off -mta=off -sccUTF-8 -scsUTF-8 -y "!temp_7z!" "!input_file!" >nul
        if !errorlevel! neq 0 (
            echo 错误：压缩失败："!input_file!"
            echo.
            if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
            if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
            if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
            pause
            exit /b 1
        )
        if not exist "!temp_7z!" (
            echo 错误：压缩文件生成失败："!temp_7z!"
            echo.
            if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
            if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
            pause
            exit /b 1
        )

        set "temp_7z_exe=!temp_dir!\archive.sfx.exe"
        copy /b /y "!seven_zip_sfx!" + "!temp_7z!" "!temp_7z_exe!" >nul
        if !errorlevel! neq 0 (
            echo 错误：制作自解压 exe 失败："!temp_7z_exe!"
            echo.
            if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
            if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
            if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
            if exist "!temp_7z_exe!" ( del /f /q "!temp_7z_exe!" )
            pause
            exit /b 1
        )
        if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
        call :log "[7z] 压缩完成，开始一致性检测"
        call :hash_file "!temp_7z_exe!"
        call :log "[7z] 自解压exe SHA256：!hf_hash!"
        if "!DEBUG!"=="1" (
            set "temp_7z_repeat=!temp_dir!\archive_repeat.7z"
            if exist "!temp_7z_repeat!" ( del /f /q "!temp_7z_repeat!" )
            "!seven_zip!" a -t7z -mx=9 -m0=LZMA2 -md=2048m -mfb=256 -ms=off -mmt=on -mtc=off -mtm=off -mta=off -sccUTF-8 -scsUTF-8 -y "!temp_7z_repeat!" "!input_file!" >nul
            set "temp_7z_exe_repeat=!temp_dir!\archive_repeat.sfx.exe"
            copy /b /y "!seven_zip_sfx!" + "!temp_7z_repeat!" "!temp_7z_exe_repeat!" >nul
            if !errorlevel! neq 0 (
                call :log "[7z] 重复压缩失败"
            ) else (
                call :hash_file "!temp_7z_repeat!"
                call :log "[7z] 重复压缩(7z数据) SHA256：!hf_hash!"
                call :bin_cmp "!temp_7z_exe!" "!temp_7z_exe_repeat!"
                call :log "[7z] 重复自解压exe 二进制比对：!bc_result!"
            )
        )
    )



    REM 选择体积最小的压缩包作为内嵌资源
    set "method="
    set "smallest_size="
    set "resource_file="
    echo.

    set "gzip_size=-1"
    for /f %%s in ('powershell -NoProfile -Command "try { ([System.IO.FileInfo]($env:temp_gzip)).Length } catch { -1 }"') do set "gzip_size=%%s"
    if "!gzip_size!"=="-1" (
        echo 错误：获取 gzip 压缩包大小失败："!temp_gzip!"
        echo.
        if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
        if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
        if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
        if exist "!temp_7z_exe!" ( del /f /q "!temp_7z_exe!" )
        pause
        exit /b 1
    )
    echo gzip 压缩包大小：!gzip_size! 字节
    set "method=gzip" & set "smallest_size=!gzip_size!" & set "resource_file=!temp_gzip!"

    set "cab_size=-1"
    for /f %%s in ('powershell -NoProfile -Command "try { ([System.IO.FileInfo]($env:temp_cab)).Length } catch { -1 }"') do set "cab_size=%%s"
    if "!cab_size!"=="-1" (
        echo 错误：获取 cab 压缩包大小失败："!temp_cab!"
        echo.
        if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
        if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
        if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
        if exist "!temp_7z_exe!" ( del /f /q "!temp_7z_exe!" )
        pause
        exit /b 1
    )
    echo cab 压缩包大小：!cab_size! 字节
    set "size_smaller=0"
    for /f "delims=" %%c in ('
        powershell -NoProfile -Command ^
            "[System.Console]::OutputEncoding=[System.Text.Encoding]::UTF8;" ^
            "Write-Output ([int]([int64]$env:cab_size -lt [int64]$env:smallest_size));"
    ') do (
        set "size_smaller=%%c"
    )
    if "!size_smaller!"=="1" (
        set "method=cab" & set "smallest_size=!cab_size!" & set "resource_file=!temp_cab!"
    )

    if "!use_7z_exe!"=="1" (
        set "seven_zip_size=-1"
        for /f %%s in ('powershell -NoProfile -Command "try { ([System.IO.FileInfo]($env:temp_7z_exe)).Length } catch { -1 }"') do set "seven_zip_size=%%s"
        if "!seven_zip_size!"=="-1" (
            echo 错误：获取 7z 压缩包大小失败："!temp_7z_exe!"
            echo.
            if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
            if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
            if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
            if exist "!temp_7z_exe!" ( del /f /q "!temp_7z_exe!" )
            pause
            exit /b 1
        )
        echo 7z 压缩包大小：!seven_zip_size! 字节
        set "size_smaller=0"
        for /f "delims=" %%c in ('
            powershell -NoProfile -Command ^
                "[System.Console]::OutputEncoding=[System.Text.Encoding]::UTF8;" ^
                "Write-Output ([int]([int64]$env:seven_zip_size -lt [int64]$env:smallest_size));"
        ') do (
            set "size_smaller=%%c"
        )
        if "!size_smaller!"=="1" (
            set "method=7z" & set "smallest_size=!seven_zip_size!" & set "resource_file=!temp_7z_exe!"
        )
    )

    echo.
    echo 选择压缩方式：!method!，压缩包大小：!smallest_size! 字节
    echo.
    call :log "选择压缩方式：!method!，压缩包大小：!smallest_size! 字节，资源文件：!resource_file!"
    call :hash_file "!resource_file!"
    call :log "所选资源文件 SHA256：!hf_hash!"

    REM 提取内嵌的 C# 代码
    set "temp_cs=!temp_dir!\program.cs"
    if exist "!temp_cs!" ( del /f /q "!temp_cs!" )
    set "inner_begin_marker=-----BEGIN CSHARP CODE-----"
    set "inner_end_marker=-----END CSHARP CODE-----"
    set "origin_file_name_marker=-----ORIGIN FILE NAME-----"
    set "origin_file_size_marker=-----ORIGIN FILE SIZE-----"
    set "origin_file_sha512_marker=-----ORIGIN FILE SHA512-----"
    set "origin_file_product_marker=-----ORIGIN FILE PRODUCT-----"
    powershell -NoProfile -Command ^
        "[System.Console]::OutputEncoding=[System.Text.Encoding]::UTF8;" ^
        "$lines = Get-Content -Encoding UTF8 -LiteralPath $env:script_path;" ^
        "$begin = [array]::IndexOf($lines, $env:inner_begin_marker) + 1;" ^
        "$end = [array]::IndexOf($lines, $env:inner_end_marker);" ^
        "if ($begin -lt 1 -or $end -lt $begin) {" ^
        "    Write-Host '错误：未找到内嵌的 C# 代码块' -ForegroundColor Red;" ^
        "    exit 1;" ^
        "};" ^
        "$code = $lines[$begin..($end - 1)];" ^
        "for ($i = 0; $i -lt $code.Count; $i++) {" ^
        "    $code[$i] = $code[$i].Replace($env:origin_file_name_marker, $env:file_name_ext);" ^
        "    $code[$i] = $code[$i].Replace($env:origin_file_size_marker, $env:file_size);" ^
        "    $code[$i] = $code[$i].Replace($env:origin_file_sha512_marker, $env:file_sha512);" ^
        "    $code[$i] = $code[$i].Replace($env:origin_file_product_marker, $env:base_name);" ^
        "};" ^
        "$utf8NoBOM = [System.Text.UTF8Encoding]::new($false);" ^
        "[System.IO.File]::WriteAllLines($env:temp_cs, $code, $utf8NoBOM);"
    if !errorlevel! neq 0 (
        echo 错误：提取内嵌代码失败
        echo.
        if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
        if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
        if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
        if exist "!temp_7z_exe!" ( del /f /q "!temp_7z_exe!" )
        if exist "!temp_cs!" ( del /f /q "!temp_cs!" )
        pause
        exit /b 1
    )
    if not exist "!temp_cs!" (
        echo 错误：提取内嵌代码文件生成失败："!temp_cs!"
        echo.
        if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
        if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
        if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
        if exist "!temp_7z_exe!" ( del /f /q "!temp_7z_exe!" )
        pause
        exit /b 1
    )

    call :log "[cs] 内嵌C#代码提取完成"
    call :hash_file "!temp_cs!"
    call :log "[cs] C#代码 SHA256：!hf_hash!"

    REM 自动生成图标：以源文件名的首字，绘制蓝色圆形 + 白色首字的 ico 文件
    set "icon_char=!base_name:~0,1!"
    set "temp_ico=!temp_dir!\icon.ico"
    if exist "!temp_ico!" ( del /f /q "!temp_ico!" )
    powershell -NoProfile -Command ^
        "[System.Console]::OutputEncoding=[System.Text.Encoding]::UTF8;" ^
        "Add-Type -AssemblyName System.Drawing;" ^
        "$ch = $env:icon_char;" ^
        "if ([string]::IsNullOrEmpty($ch) -or ($ch.Length -gt 0 -and [char]::IsWhiteSpace($ch[0]))) { $ch = 'M' }" ^
        "$sizeList = New-Object System.Collections.ArrayList;" ^
        "$streams = New-Object System.Collections.ArrayList;" ^
        "foreach ($s in @(16,32,48,256)) {" ^
        "    $bmp = New-Object System.Drawing.Bitmap($s,$s);" ^
        "    $g = [System.Drawing.Graphics]::FromImage($bmp);" ^
        "    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias;" ^
        "    $g.Clear([System.Drawing.Color]::Transparent);" ^
        "    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(91,155,213));" ^
        "    $m = [int]($s*0.06);" ^
        "    $g.FillEllipse($brush, $m, $m, $s - 2*$m, $s - 2*$m);" ^
        "    $fs = [int]($s*0.55);" ^
        "    $font = New-Object System.Drawing.Font('Microsoft YaHei', $fs, [System.Drawing.FontStyle]::Bold);" ^
        "    $fmt = New-Object System.Drawing.StringFormat;" ^
        "    $fmt.Alignment = [System.Drawing.StringAlignment]::Center;" ^
        "    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center;" ^
        "    $rect = New-Object System.Drawing.RectangleF(0, [int]($s*0.04), $s, [int]($s*0.92));" ^
        "    $g.DrawString($ch, $font, [System.Drawing.Brushes]::White, $rect, $fmt);" ^
        "    $pms = New-Object System.IO.MemoryStream;" ^
        "    $bmp.Save($pms, [System.Drawing.Imaging.ImageFormat]::Png);" ^
        "    [void]$sizeList.Add($s); [void]$streams.Add($pms);" ^
        "    $g.Dispose(); $brush.Dispose(); $font.Dispose(); $fmt.Dispose(); $bmp.Dispose();" ^
        "};" ^
        "$ms = New-Object System.IO.MemoryStream;" ^
        "$bw = New-Object System.IO.BinaryWriter($ms);" ^
        "$bw.Write([uint16]0); $bw.Write([uint16]1); $bw.Write([uint16]$streams.Count);" ^
        "$offset = 6 + 16 * $streams.Count;" ^
        "for ($i = 0; $i -lt $streams.Count; $i++) {" ^
        "    $s = $sizeList[$i]; $w = $(if ($s -eq 256) {0} else {$s});" ^
        "    $bw.Write([byte]$w); $bw.Write([byte]$w); $bw.Write([byte]0); $bw.Write([byte]0);" ^
        "    $bw.Write([uint16]1); $bw.Write([uint16]32);" ^
        "    $bw.Write([uint32]$streams[$i].Length); $bw.Write([uint32]$offset);" ^
        "    $offset = $offset + $streams[$i].Length;" ^
        "};" ^
        "foreach ($pms in $streams) { $bw.Write($pms.ToArray()); $pms.Dispose() }" ^
        "$bw.Flush();" ^
        "[System.IO.File]::WriteAllBytes($env:temp_ico, $ms.ToArray());" ^
        "$bw.Dispose(); $ms.Dispose();"
    if not exist "!temp_ico!" (
        echo 错误：自动生成图标失败："!temp_ico!"
        echo.
        if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
        if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
        if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
        if exist "!temp_7z_exe!" ( del /f /q "!temp_7z_exe!" )
        if exist "!temp_cs!" ( del /f /q "!temp_cs!" )
        pause
        exit /b 1
    )

    call :log "[ico] 图标生成完成"
    call :hash_file "!temp_ico!"
    call :log "[ico] 图标 ICO SHA256：!hf_hash!  (若本地与服务器不同，说明字体/渲染差异导致图标不一致)"
    call :peek "!temp_ico!" 32
    call :log "[ico] 图标文件头：!pk_hex!"

    REM 临时文件写入完成后，把时间统一刷新为 UNIX 0 时间戳（1970-01-01 00:00:00 UTC），保证生成一致性
    powershell -NoProfile -Command ^
        "[System.Console]::OutputEncoding=[System.Text.Encoding]::UTF8;" ^
        "$epoch = [System.DateTimeOffset]::FromUnixTimeSeconds(0).UtcDateTime;" ^
        "$paths = @($env:temp_gzip, $env:temp_cab, $env:temp_7z, $env:temp_7z_exe, $env:temp_cs, $env:temp_ico);" ^
        "foreach ($p in $paths) {" ^
        "    if ([string]::IsNullOrEmpty($p)) { continue };" ^
        "    if (-not [System.IO.File]::Exists($p)) { continue };" ^
        "    [System.IO.File]::SetCreationTimeUtc($p, $epoch);" ^
        "    [System.IO.File]::SetLastWriteTimeUtc($p, $epoch);" ^
        "    [System.IO.File]::SetLastAccessTimeUtc($p, $epoch);" ^
        "}"
    if !errorlevel! neq 0 (
        echo 错误：临时文件时间刷新失败："!temp_dir!"
        echo.
        if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
        if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
        if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
        if exist "!temp_7z_exe!" ( del /f /q "!temp_7z_exe!" )
        if exist "!temp_cs!" ( del /f /q "!temp_cs!" )
        if exist "!temp_ico!" ( del /f /q "!temp_ico!" )
        pause
        exit /b 1
    )



    echo 正在编译代码，并嵌入压缩包资源
    echo.
    if exist "!output_file!" ( del /f /q "!output_file!" )
    if not "!csharp_roslyn_compiler!"=="" (
        echo 使用 C# Roslyn 编译器 + /deterministic 参数，保证一致性 & REM
        echo.
        "!csharp_roslyn_compiler!" /deterministic /target:winexe /optimize "/pathmap:!temp_dir!=/src" ^
            /out:"!output_file!" ^
            /win32icon:"!temp_ico!" ^
            /resource:"!resource_file!" ^
            "!temp_cs!"
    ) else (
        echo 使用系统默认的 C# 编译器，不保证一致性 & REM
        echo.
        powershell -NoProfile -Command ^
            "[System.Console]::OutputEncoding=[System.Text.Encoding]::UTF8;" ^
            "[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.CSharp');" ^
            "$provider = New-Object Microsoft.CSharp.CSharpCodeProvider;" ^
            "$params = New-Object System.CodeDom.Compiler.CompilerParameters;" ^
            "$params.OutputAssembly = $env:output_file;" ^
            "$params.GenerateExecutable = $true;" ^
            "$params.CompilerOptions = '/target:winexe /optimize /win32icon:\"' + $env:temp_ico + '\"';" ^
            "[void]$params.ReferencedAssemblies.Add('System.dll');" ^
            "[void]$params.ReferencedAssemblies.Add('System.Core.dll');" ^
            "[void]$params.ReferencedAssemblies.Add('System.IO.Compression.dll');" ^
            "[void]$params.ReferencedAssemblies.Add('System.Windows.Forms.dll');" ^
            "[void]$params.EmbeddedResources.Add($env:resource_file);" ^
            "$result = $provider.CompileAssemblyFromFile($params, $env:temp_cs);" ^
            "if ($result.Errors.Count -gt 0) {" ^
            "    Write-Host '错误：编译 C# 代码失败：' -ForegroundColor Red;" ^
            "    foreach ($err in $result.Errors) { Write-Host $err.ToString() -ForegroundColor Red };" ^
            "    exit 1;" ^
            "}"
    )
    if !errorlevel! neq 0 (
        echo 错误：编译 C# 代码失败："!temp_cs!"
        echo.
        if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
        if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
        if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
        if exist "!temp_7z_exe!" ( del /f /q "!temp_7z_exe!" )
        if exist "!temp_cs!" ( del /f /q "!temp_cs!" )
        if exist "!temp_ico!" ( del /f /q "!temp_ico!" )
        if exist "!output_file!" ( del /f /q "!output_file!" )
        pause
        exit /b 1
    )
    echo 编译完成
    echo.
    if not exist "!output_file!" (
        echo 错误：生成 exe 文件不存在："!output_file!"
        echo.
        if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
        if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
        if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
        if exist "!temp_7z_exe!" ( del /f /q "!temp_7z_exe!" )
        if exist "!temp_cs!" ( del /f /q "!temp_cs!" )
        if exist "!temp_ico!" ( del /f /q "!temp_ico!" )
        pause
        exit /b 1
    )

    set "file_size=-1"
    for /f %%s in ('powershell -NoProfile -Command "try { ([System.IO.FileInfo]($env:output_file)).Length } catch { -1 }"') do set "file_size=%%s"
    echo 最终大小：!file_size! 字节

    if "!DEBUG!"=="1" (
        call :log "============================================================"
        call :log "一致性分析汇总"
        call :log "输入文件：!input_file!"
        call :log "输入大小：!input_size! 字节  输入SHA512：!file_sha512!"
        call :log "最终大小：!file_size! 字节"
        call :log "压缩方式：!method!  压缩包大小：!smallest_size!"
        call :hash_file "!resource_file!"
        call :log "资源文件 SHA256：!hf_hash!"
        call :hash_file "!temp_ico!"
        call :log "图标 ICO SHA256：!hf_hash!"
        call :hash_file "!temp_cs!"
        call :log "C# 代码 SHA256：!hf_hash!"
        call :hash_file "!output_file!"
        call :log "最终 EXE SHA256：!hf_hash!"
        call :log "--- 内嵌资源名（确认是否被 /pathmap 归一化，否则将包含本机临时路径）---"
        for /f "delims=" %%r in ('
            powershell -NoProfile -Command "$asm=[System.Reflection.Assembly]::ReflectionOnlyLoadFrom($env:output_file); $asm.GetManifestResourceNames() | ForEach-Object { Write-Output $_ }"
        ') do call :log "    内嵌资源：%%r"
        if defined GSB_REFERENCE (
            if exist "!GSB_REFERENCE!" (
                call :bin_cmp "!output_file!" "!GSB_REFERENCE!"
                call :log "与参考产物二进制比对：!bc_result!"
            ) else (
                call :log "参考产物不存在：!GSB_REFERENCE!"
            )
        ) else (
            call :log "提示：设置 GSB_REFERENCE=参考exe路径 可进行二进制比对"
        )
        call :log "============================================================"
    )

    if exist "!temp_gzip!" ( del /f /q "!temp_gzip!" )
    if exist "!temp_cab!" ( del /f /q "!temp_cab!" )
    if exist "!temp_7z!" ( del /f /q "!temp_7z!" )
    if exist "!temp_7z_exe!" ( del /f /q "!temp_7z_exe!" )
    if exist "!temp_cs!" ( del /f /q "!temp_cs!" )
    if exist "!temp_ico!" ( del /f /q "!temp_ico!" )
    if exist "!temp_dir!\archive_repeat.gz" ( del /f /q "!temp_dir!\archive_repeat.gz" )
    if exist "!temp_dir!\archive_repeat.cab" ( del /f /q "!temp_dir!\archive_repeat.cab" )
    if exist "!temp_dir!\archive_repeat.7z" ( del /f /q "!temp_dir!\archive_repeat.7z" )
    if exist "!temp_dir!\archive_repeat.sfx.exe" ( del /f /q "!temp_dir!\archive_repeat.sfx.exe" )
    if exist "%temp%\MyBatch\envdump.txt" ( del /f /q "%temp%\MyBatch\envdump.txt" )

    endlocal
    endlocal
)



echo.
pause
exit /b

REM ============================================================
REM 以下为调试 / 一致性分析子程序（主流程已在上方 exit /b 退出，不会执行到这里）
REM 启用：默认开启；GSB_DEBUG=0 关闭；GSB_REFERENCE=参考exe 路径 做二进制比对
REM ============================================================

:log
set "log_msg=%~1"
if not defined log_msg set "log_msg= "
echo(!log_msg!
echo(!log_msg!>> "!log_file!"
if defined MANIFEST_FILE ( echo(!log_msg!>> "!MANIFEST_FILE!" )
goto :eof

:hash_file
set "hf_path=%~1"
set "hf_algo=%~2"
if "!hf_algo!"=="" set "hf_algo=SHA256"
set "hf_hash=ERROR"
for /f "delims=" %%h in ('
    powershell -NoProfile -Command "[System.Console]::OutputEncoding=[System.Text.Encoding]::UTF8; try { $a=[System.Security.Cryptography.HashAlgorithm]::Create($env:hf_algo); $b=[System.IO.File]::ReadAllBytes($env:hf_path); Write-Output ([System.BitConverter]::ToString($a.ComputeHash($b)).Replace('-','').ToLowerInvariant()); } catch { Write-Output 'ERROR' }"
') do set "hf_hash=%%h"
goto :eof

:bin_cmp
set "bc_a=%~1"
set "bc_b=%~2"
set "bc_result=ERROR"
for /f "delims=" %%r in ('
    powershell -NoProfile -Command "$a=[System.IO.File]::ReadAllBytes($env:bc_a); $b=[System.IO.File]::ReadAllBytes($env:bc_b); if($a.Length -ne $b.Length){ Write-Output ('SIZE_DIFF a='+$a.Length+' b='+$b.Length); exit } $found=-1; for($i=0;$i -lt $a.Length;$i++){ if($a[$i]-ne$b[$i]){ $found=$i; break } } if($found -lt 0){ Write-Output 'IDENTICAL' } else { $s=[Math]::Max(0,$found-8); $e=[Math]::Min($a.Length,$found+24); $sb=New-Object System.Text.StringBuilder; for($i=$s;$i -lt $e;$i++){ [void]$sb.Append(('{0:X2} ' -f $a[$i])); if($i -eq $found){ [void]$sb.Append('^ ') } }; Write-Output ('DIFF_AT '+$found+' len='+$a.Length+': '+$sb.ToString()) }"
') do set "bc_result=%%r"
goto :eof

:peek
set "pk_path=%~1"
set "pk_n=%~2"
if "!pk_n!"=="" set "pk_n=16"
set "pk_hex=ERROR"
for /f "delims=" %%p in ('
    powershell -NoProfile -Command "$b=[System.IO.File]::ReadAllBytes($env:pk_path); if($b.Length -gt [int]$env:pk_n){ $b=$b[0..([int]$env:pk_n-1)] }; Write-Output (($b | ForEach-Object { '{0:X2}' -f $_ }) -join ' ')"
') do set "pk_hex=%%p"
goto :eof

:log_file
set "lf_path=%~1"
for /f "usebackq delims=" %%l in ("!lf_path!") do call :log "%%l"
goto :eof

:env_dump
set "ed_tmp=%temp%\MyBatch\envdump.txt"
powershell -NoProfile -Command "$out=New-Object System.Collections.ArrayList; $os=[System.Environment]::OSVersion; $bld=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue).CurrentBuildNumber; [void]$out.Add('OS: '+$os.VersionString+' Build='+$bld); $psv=$PSVersionTable; [void]$out.Add('PowerShell: '+$psv.PSVersion.ToString()+' CLR='+$psv.CLRVersion.ToString()); [void]$out.Add('Culture: '+(Get-Culture).Name+' UICulture: '+(Get-UICulture).Name); [void]$out.Add('User: '+[System.Security.Principal.WindowsIdentity]::GetCurrent().Name); [void]$out.Add('Machine: '+[System.Environment]::MachineName); [void]$out.Add('TEMP: '+$env:TEMP); [void]$out.Add('ARCH: '+$env:PROCESSOR_ARCHITECTURE); try { $ff=[System.Drawing.FontFamily]::new('Microsoft YaHei'); [void]$out.Add('Font Microsoft YaHei: OK ('+$ff.Name+')'); } catch { [void]$out.Add('Font Microsoft YaHei: MISSING (回退字体可能导致图标不一致)') }; try { [void]$out.Add('.NET Runtime: '+[System.Environment]::Version.ToString()) } catch {} if($env:csharp_roslyn_compiler -and (Test-Path $env:csharp_roslyn_compiler)){ $vi=(Get-Item $env:csharp_roslyn_compiler).VersionInfo; [void]$out.Add('C# Roslyn: '+$env:csharp_roslyn_compiler+' v'+$vi.FileVersion) } else { [void]$out.Add('C# Roslyn: 未找到(将用 CodeDom，不保证一致性)') }; if($env:seven_zip -and (Test-Path $env:seven_zip)){ $vi=(Get-Item $env:seven_zip).VersionInfo; [void]$out.Add('7-Zip: '+$env:seven_zip+' v'+$vi.FileVersion) } else { [void]$out.Add('7-Zip: 未找到') }; $out | Out-File -Encoding UTF8 $env:ed_tmp"
call :log_file "!ed_tmp!"
goto :eof

-----BEGIN CSHARP CODE-----
using System;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Windows.Forms;
using System.Runtime.InteropServices;

[assembly: System.Reflection.AssemblyTitle("-----ORIGIN FILE PRODUCT-----")]
[assembly: System.Reflection.AssemblyProduct("-----ORIGIN FILE PRODUCT-----")]

public static class Program
{
    private static string originFileName = "-----ORIGIN FILE NAME-----";
    private static long originFileSize = long.Parse("-----ORIGIN FILE SIZE-----");
    private static string originFileSha512 = "-----ORIGIN FILE SHA512-----";

    private static void ShowError(string msg)
    {
        try { MessageBox.Show(msg, originFileName, MessageBoxButtons.OK, MessageBoxIcon.Error); } catch { }
    }

    [STAThread]
    private static int Main(string[] args)
    {
        string tempRoot = Path.Combine(Path.GetTempPath(), "MyBatch", "cache", originFileSize.ToString(), originFileSha512);
        try { if (!Directory.Exists(tempRoot)) Directory.CreateDirectory(tempRoot); } catch { }
        string extracted = Path.Combine(tempRoot, originFileName);

        bool needExtract = true;
        if (File.Exists(extracted))
        {
            try
            {
                FileInfo fi = new FileInfo(extracted);
                if (fi.Length == originFileSize)
                {
                    using (var sha = SHA512.Create())
                    using (var fs = File.OpenRead(extracted))
                    {
                        byte[] h = sha.ComputeHash(fs);
                        string hex = BitConverter.ToString(h).Replace("-", "").ToLowerInvariant();
                        if (string.Equals(hex, originFileSha512, StringComparison.OrdinalIgnoreCase))
                            needExtract = false;
                    }
                }
            }
            catch { }
        }

        if (needExtract)
        {
            var asm = Assembly.GetExecutingAssembly();
            string resName = null;
            foreach (string n in asm.GetManifestResourceNames())
            {
                string ln = n.ToLowerInvariant();
                if (ln.EndsWith(".gz") || ln.EndsWith(".cab") || ln.EndsWith(".exe")) { resName = n; break; }
            }
            if (resName == null)
            {
                ShowError("错误：未找到内嵌的压缩资源");
                return 1;
            }
            string lowerMethod = null;
            if (resName.EndsWith(".gz", StringComparison.OrdinalIgnoreCase)) lowerMethod = "gzip";
            else if (resName.EndsWith(".cab", StringComparison.OrdinalIgnoreCase)) lowerMethod = "cab";
            else if (resName.EndsWith(".exe", StringComparison.OrdinalIgnoreCase)) lowerMethod = "7z";
            if (lowerMethod == null)
            {
                ShowError("错误：未知的内嵌压缩资源格式：" + resName);
                return 1;
            }
            try
            {
                if (lowerMethod == "gzip")
                {
                    using (var stream = asm.GetManifestResourceStream(resName))
                    using (var gzip = new GZipStream(stream, CompressionMode.Decompress))
                    using (var outp = File.Create(extracted))
                    {
                        gzip.CopyTo(outp);
                    }
                    if (!File.Exists(extracted)) { ShowError("错误：gzip 解压失败"); return 1; }
                }
                else if (lowerMethod == "cab")
                {
                    var rnd = new Random();
                    string tempFilePrefix = "MyBatch_" + rnd.Next(0, 32768) + "_" + rnd.Next(0, 32768) + "_" + rnd.Next(0, 32768) + "_" + rnd.Next(0, 32768);
                    string cabPath = Path.Combine(Path.GetTempPath(), tempFilePrefix + ".cab");
                    using (var stream = asm.GetManifestResourceStream(resName))
                    using (var outp = File.Create(cabPath)) { stream.CopyTo(outp); }
                    var cabPsi = new ProcessStartInfo("expand.exe", "\"" + cabPath + "\" \"" + extracted + "\"");
                    cabPsi.UseShellExecute = false;
                    cabPsi.CreateNoWindow = true;
                    using (var p = Process.Start(cabPsi)) { if (p != null) p.WaitForExit(); }
                    try { if (File.Exists(cabPath)) File.Delete(cabPath); } catch { }
                    if (!File.Exists(extracted)) { ShowError("错误：cab 解压失败"); return 1; }
                }
                else if (lowerMethod == "7z")
                {
                    var rnd = new Random();
                    string tempFilePrefix = "MyBatch_" + rnd.Next(0, 32768) + "_" + rnd.Next(0, 32768) + "_" + rnd.Next(0, 32768) + "_" + rnd.Next(0, 32768);
                    string sfxPath = Path.Combine(Path.GetTempPath(), tempFilePrefix + ".exe");
                    using (var stream = asm.GetManifestResourceStream(resName))
                    using (var outp = File.Create(sfxPath)) { stream.CopyTo(outp); }
                    var sfxPsi = new ProcessStartInfo(sfxPath, "-o\"" + tempRoot + "\" -y");
                    sfxPsi.UseShellExecute = false;
                    sfxPsi.CreateNoWindow = true;
                    using (var p = Process.Start(sfxPsi)) { if (p != null) p.WaitForExit(); }
                    try { if (File.Exists(sfxPath)) File.Delete(sfxPath); } catch { }
                    if (!File.Exists(extracted)) { ShowError("错误：7z 解压失败"); return 1; }
                }
                else
                {
                    ShowError("错误：未知的内嵌压缩方式：" + lowerMethod);
                    return 1;
                }
            }
            catch (Exception ex)
            {
                ShowError("错误：解压失败：" + ex.Message);
                return 1;
            }
        }

        try
        {
            string exeLocation = Assembly.GetExecutingAssembly().Location;
            string exeDirectory = Path.GetDirectoryName(exeLocation);
            ProcessStartInfo psi = new ProcessStartInfo();
            psi.WorkingDirectory = exeDirectory;
            psi.UseShellExecute = false;
            psi.CreateNoWindow = true;
            string lower = originFileName.ToLowerInvariant();
            string argStr = "";
            for (int i = 0; i < args.Length; i++)
            {
                string a = args[i];
                if (a.IndexOf(' ') >= 0) argStr += " \"" + a + "\"";
                else argStr += " " + a;
            }
            if (lower.EndsWith(".ps1"))
            {
                psi.FileName = "powershell.exe";
                psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File \"" + extracted + "\"" + argStr;
            }
            else if (lower.EndsWith(".py"))
            {
                psi.FileName = "python.exe";
                psi.Arguments = "\"" + extracted + "\"" + argStr;
            }
            else if (lower.EndsWith(".bat"))
            {
                psi.FileName = "cmd.exe";
                psi.Arguments = "/s /c \"\"" + extracted + "\" " + argStr.TrimStart() + "\"";
            }
            else if (lower.EndsWith(".exe"))
            {
                psi.FileName = extracted;
                psi.Arguments = argStr.TrimStart();
            }
            else
            {
                psi.FileName = extracted;
                psi.Arguments = argStr.TrimStart();
                psi.UseShellExecute = true;
                Process.Start(psi);
                return 0;
            }
            using (Process p = Process.Start(psi))
            {
                if (p != null)
                {
                    p.WaitForExit();
                    return p.ExitCode;
                }
            }
            ShowError("错误：无法启动解压出的文件");
            return 1;
        }
        catch (Exception ex)
        {
            ShowError("错误：执行失败：" + ex.Message);
            return 1;
        }
    }
}
-----END CSHARP CODE-----
