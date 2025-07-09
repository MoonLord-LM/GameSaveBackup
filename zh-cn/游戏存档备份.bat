@echo off
setlocal enabledelayedexpansion
chcp 65001

:: jq-windows-amd64.exe
:: 1.7.1
:: https://jqlang.github.io/jq/download/



if /i "%cd%"=="%SystemRoot%\System32" (
    echo 当前目录为系统目录，不应该在这里执行
    pause
    exit
)

if not exist ".git" (
    git init
    git config --local core.autocrlf false
    git config --local core.safecrlf false
    git config --local core.ignorecase false
)

for /f "tokens=*" %%a in ('hostname') do set "machine_name=%%a"
for /f "tokens=3 delims=\" %%b in ('echo %USERPROFILE%') do set "user_name=%%b"
echo 机器名: !machine_name! 用户名: !user_name!

set "config=config.json"
for /f %%i in ('jq length "%config%"') do set "length=%%i"
echo.

for /l %%i in (1, 1, %length%) do (
    for /f "tokens=*" %%j in ('jq -r ".[%%i - 1].game" "%config%"') do set "game=%%j"
    for /f "tokens=*" %%j in ('jq -r ".[%%i - 1].save" "%config%"') do set "save=%%j"

    set "save=!save:%%USERPROFILE%%=%USERPROFILE%!"
    echo "progress %%i / !length!"  :  "!game!" in "!save!"

    set "ignore_args="
    for /f "delims=" %%k in ('jq -r ".[%%i - 1].ignore // empty | .[]" "%config%"') do (
        set "item=%%k"
        set "item=!item:%%USERPROFILE%%=%USERPROFILE%!"
        echo "ignore item: !item!"
        set "ignore_args=!ignore_args! /XF "!item!" /XD "!item!""
    )

    if not exist "!game!" ( mkdir "!game!" )
    cd "!game!"

    set "max_local_time="
    set "max_backup_time="

    for /f %%a in ('powershell -NoProfile -Command "((Get-ChildItem -Recurse -Path \""!save!\"" | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.Ticks)"') do set "max_local_time=%%a"
    for /f %%a in ('powershell -NoProfile -Command "((Get-ChildItem -Recurse -Path \""%cd%\!game!\"" | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.Ticks)"') do set "max_backup_time=%%a"
    if "!max_local_time!"=="621356256000000000" ( set "max_local_time=" )
    if "!max_backup_time!"=="621356256000000000" ( set "max_backup_time=" )

    for /f "delims=" %%a in ('powershell -NoProfile -Command "[datetime]::new(!max_local_time!, 'UTC').ToString('yyyy-MM-dd HH:mm:ss (zzz)')"') do set "max_local_time=%%a"
    for /f "delims=" %%a in ('powershell -NoProfile -Command "[datetime]::new(!max_backup_time!, 'UTC').ToString('yyyy-MM-dd HH:mm:ss (zzz)')"') do set "max_backup_time=%%a"
    if "!max_local_time!"==" " ( set "max_local_time=" )
    if "!max_backup_time!"==" " ( set "max_backup_time=" )

    echo 本地文件修改时间: [!max_local_time!] 备份文件修改时间: [!max_backup_time!]

    if not exist "存档位置.bat" (
        echo if not exist "!save!" mkdir "!save!" > "存档位置.bat"
        echo "explorer.exe" "!save!" >> "存档位置.bat"
        powershell -NoProfile -Command "(Get-Item '存档位置.bat').LastWriteTime = [DateTimeOffset]::FromUnixTimeSeconds(0).UtcDateTime"
    )

    if "!max_local_time!"=="" (
        if "!max_backup_time!"=="" (
            echo 本地存档文件与备份文件都不存在，跳过操作
        ) else (
            echo 本地存档文件缺失，使用备份文件恢复
            powershell -NoProfile -Command "$sh = New-Object -ComObject Shell.Application; $sh.Namespace(10).MoveHere(\""!save!\"")"
            robocopy . "!save!" /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH /XF "存档位置.bat" !ignore_args!
        )
    ) else if "!max_backup_time!"=="" (
        echo 备份文件缺失，进行备份
        robocopy "!save!" . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH /XF "存档位置.bat" !ignore_args!
        git add .
        git commit -m "Update - !game! on !machine_name! by !user_name!"
    ) else if !max_local_time! lss !max_backup_time! (
        echo 本地存档文件修改时间较老，使用备份文件更新
        powershell -NoProfile -Command "$sh = New-Object -ComObject Shell.Application; $sh.Namespace(10).MoveHere(\""!save!\"")"
        robocopy . "!save!" /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH /XF "存档位置.bat" !ignore_args!
    ) else if !max_local_time! gtr !max_backup_time! (
        echo 本地存档文件修改时间较新，进行备份
        robocopy "!save!" . /MIR /COPY:DAT /DCOPY:T /NP /NS /NC /NFL /NDL /NJH /XF "存档位置.bat" !ignore_args!
        git add .
        git commit -m "Update - !game! on !machine_name! by !user_name!"
    ) else (
        echo 本地存档文件与备份文件修改时间相同，跳过操作
    )

    cd ..
    echo.
)

git add .
git commit -m "Update - on !machine_name! by !user_name!"
git clean -df

endlocal
pause
exit
