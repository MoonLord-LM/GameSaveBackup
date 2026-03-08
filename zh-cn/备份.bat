@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

if /i "%cd%"=="%SystemRoot%\System32" (
    echo 错误: 当前目录为系统目录，不应该在这里执行
    echo 请不要使用右键的 "以管理员权限运行"
    pause
    exit
)

"git.exe" --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 缺少 git.exe 组件
    echo 请从 https://git-scm.com/install/windows 下载
    "explorer.exe" "https://git-scm.com/install/windows"
    pause
    exit
)

if not exist ".git" (
    git init
)

git config --local core.autocrlf false
git config --local core.safecrlf false
git config --local core.ignorecase false

for /f "tokens=*" %%a in ('hostname') do set "machine_name=%%a"
for /f "tokens=3 delims=\" %%b in ('echo %USERPROFILE%') do set "user_name=%%b"
echo 机器名: !machine_name! 用户名: !user_name!

set "json_count=0"
for %%f in (*.json) do (
    set /a json_count+=1
    set "config=%%f"
)
if !json_count! equ 0 (
    echo 错误: 当前目录下没有找到 [.json] 配置文件
    echo 请确保有一个 [.json] 配置文件在此目录中
    pause
    exit
)
if !json_count! gtr 1 (
    echo 错误: 当前目录下找到多个 [.json] 配置文件（共 !json_count! 个）
    echo 请只保留一个 [.json] 配置文件
    pause
    exit
)

echo 使用配置文件: [!config!]
for /f %%i in ('powershell -NoProfile -Command "(Get-Content -Raw -Path '!config!' | ConvertFrom-Json).Count"') do set "length=%%i"
echo.

for /l %%i in (1, 1, %length%) do (
    for /f "tokens=*" %%j in ('powershell -NoProfile -Command "(Get-Content -Raw -Path '!config!' | ConvertFrom-Json)[%%i - 1].name"') do set "name=%%j"
    for /f "tokens=*" %%j in ('powershell -NoProfile -Command "(Get-Content -Raw -Path '!config!' | ConvertFrom-Json)[%%i - 1].save"') do set "save=%%j"

    set "save=!save:%%USERPROFILE%%=%USERPROFILE%!"
    set "save=!save:%%PROGRAMDATA%%=%PROGRAMDATA%!"
    echo "处理 %%i / !length!"  :  "!name!" in "!save!"

    set "ignore_args="
    for /f "delims=" %%k in ('powershell -NoProfile -Command "$item = (Get-Content -Raw -Path '!config!' | ConvertFrom-Json)[%%i - 1].ignore; if ($item) { $item } else { }"') do (
        set "item=%%k"
        set "item=!item:%%USERPROFILE%%=%USERPROFILE%!"
        set "item=!item:%%PROGRAMDATA%%=%PROGRAMDATA%!"
        echo "忽略项: !item!"
        set "ignore_args=!ignore_args! /XF "!item!" /XD "!item!""
    )

    set "max_local_time="
    set "max_backup_time="

    if exist "!save!" (
        for /f %%a in ('powershell -NoProfile -Command "try { $files = Get-ChildItem -Recurse -Path \""!save!\"" -File -ErrorAction SilentlyContinue; if ($files) { ($files | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.Ticks } else { 0 } } catch { 0 }"') do set "max_local_time=%%a"
        if "!max_local_time!"=="0" (
            set "max_local_time="
        ) else (
            for /f "delims=" %%a in ('powershell -NoProfile -Command "[DateTime]::new(!max_local_time!, 'UTC').ToString('yyyy-MM-dd HH:mm:ss UTC')"') do set "max_local_time=%%a"
        )
    )

    if not exist "!name!" (
        mkdir "!name!"
    ) else (
        for /f %%a in ('powershell -NoProfile -Command "try { $files = Get-ChildItem -Recurse -Path \""!name!\"" -File -ErrorAction SilentlyContinue; if ($files) { ($files | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.Ticks } else { 0 } } catch { 0 }"') do set "max_backup_time=%%a"
        if "!max_backup_time!"=="0" (
            set "max_backup_time="
        ) else (
            for /f "delims=" %%a in ('powershell -NoProfile -Command "[DateTime]::new(!max_backup_time!, 'UTC').ToString('yyyy-MM-dd HH:mm:ss UTC')"') do set "max_backup_time=%%a"
        )
    )
    cd "!name!"

    echo 本地文件修改时间: [!max_local_time!] 备份文件修改时间: [!max_backup_time!]

    if "!max_local_time!"=="" (
        if "!max_backup_time!"=="" (
            echo 本地存档文件与备份文件都不存在，跳过操作
        ) else (
            echo 本地存档文件缺失，使用备份文件恢复
            powershell -NoProfile -Command "$sh = New-Object -ComObject Shell.Application; $sh.Namespace(10).MoveHere(\""!save!\"")"
            robocopy . "!save!" /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH /XF "存档位置.bat" /XF "SaveLocation.bat" !ignore_args!
        )
    ) else if "!max_backup_time!"=="" (
        echo 备份文件缺失，进行备份
        if not exist "存档位置.bat" (
            echo if not exist "!save!" mkdir "!save!" > "存档位置.bat"
            echo "explorer.exe" "!save!" >> "存档位置.bat"
            powershell -NoProfile -Command "(Get-Item '存档位置.bat').LastWriteTime = [DateTimeOffset]::FromUnixTimeSeconds(0).UtcDateTime"
        )
        robocopy "!save!" . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH /XF "存档位置.bat" /XF "SaveLocation.bat" !ignore_args!
        git add .
        git diff --cached --quiet || git commit -m "Update - !name! on !machine_name! by !user_name!"
    ) else if !max_local_time! lss !max_backup_time! (
        echo 本地存档文件的修改时间较老，删除到回收站，并使用备份文件更新
        powershell -NoProfile -Command "$sh = New-Object -ComObject Shell.Application; $sh.Namespace(10).MoveHere(\""!save!\"")"
        robocopy . "!save!" /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH /XF "存档位置.bat" /XF "SaveLocation.bat" !ignore_args!
    ) else if !max_local_time! gtr !max_backup_time! (
        echo 本地存档文件的修改时间较新，进行备份
        robocopy "!save!" . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH /XF "存档位置.bat" /XF "SaveLocation.bat" !ignore_args!
        git add .
        git diff --cached --quiet || git commit -m "Update - !name! on !machine_name! by !user_name!"
    ) else (
        echo 本地存档文件与备份文件修改时间相同，跳过操作
    )

    cd ..
    echo.
)

git add .
git diff --cached --quiet || ( git commit -m "Update - on !machine_name! by !user_name!" && echo. )
git clean -df >nul

echo 备份完成
echo.

pause
exit
