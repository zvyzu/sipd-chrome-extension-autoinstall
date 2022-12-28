@echo off
::--------------------------
:: Mengecek koneksi internet
::--------------------------
ping google.com -n 1 -w 1000
cls
if %errorlevel% EQU 0 ( goto connected )
echo Tidak dapat terkoneksi ke internet, Cek koneksi internet anda.
timeout 5
exit
:connected

::------------------------
:: Mengecek git terinstall
::------------------------
git -v
if %errorlevel% NEQ 0 ( cls ) else ( goto gitinstalled )

::----------------------------
:: Meminta akses administrator
::----------------------------
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

if '%errorlevel%' NEQ '0' (
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

::---------------------------
:: Menghentikan proses SMADAV
::---------------------------
::for /F "delims=" %%G in ('FORFILES /P "C:\Program Files (x86)\SMADAV" /M *.exe /S') do ( taskkill /F /IM %%G /T )
::cls

::----------------
:: Mendownload Git
::----------------
set urlgit=https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.2/Git-2.39.0.2-32-bit.exe
set filename=Git-2.39.0.2-32-bit.exe
echo Mendownload git.....
curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -L "%urlgit%" -o %filename% --ssl-no-revoke
if %errorlevel% NEQ 0 ( cls ) else ( goto gitinstall )
echo Mendownload git.....
powershell -Command "(New-Object Net.WebClient).DownloadFile('%urlgit%', '%filename%')"

::----------------
:: Menginstall Git
::----------------
:gitinstall
cls
echo Menginstall git.....
%filename% /VERYSILENT
cls
goto relaunch

::-------------------------------
:: Melakukan git clone / git pull
::-------------------------------
:gitinstalled
cls

:: Pengecekan .git
if exist "D:\sipd-chrome-extension\" (
if not exist "D:\sipd-chrome-extension\.git\" ( rmdir /S /Q D:\sipd-chrome-extension\ )
)
if exist "C:\sipd-chrome-extension\" (
if not exist "C:\sipd-chrome-extension\.git\" ( rmdir /S /Q C:\sipd-chrome-extension\ )
)

:: Url / link config.js
set urljs=https://raw.githubusercontent.com/evanvyz/sipd-chrome-extension-autoinstall/main/config.js
set urlexample=https://raw.githubusercontent.com/agusnurwanto/sipd-chrome-extension/master/config.js.example

:: Pengecekan Drive D:\
if not exist "D:\" ( goto c )

:: Melakunkan di Drive D:\
if not exist "D:\sipd-chrome-extension\" ( goto gitclone )
if exist "D:\sipd-chrome-extension\config.js.example" ( goto gitclone )
powershell -Command "(New-Object Net.WebClient).DownloadFile('%urlexample%', 'D:\sipd-chrome-extension\config.js.example')"

:gitclone
if exist "D:\sipd-chrome-extension\manifest.json" ( goto gitpull )
git clone https://github.com/agusnurwanto/sipd-chrome-extension.git D:\sipd-chrome-extension
goto configjs

:gitpull
git -C D:\sipd-chrome-extension\ pull origin master
if not exist "D:\sipd-chrome-extension\config.js" ( goto configjs ) else ( goto done )

:configjs
powershell -Command "(New-Object Net.WebClient).DownloadFile('%urljs%', 'D:\sipd-chrome-extension\config.js')"
goto done

:: Melakunkan di Drive C:\
:c
if not exist "C:\sipd-chrome-extension\" ( goto cgitclone )
if exist "C:\sipd-chrome-extension\config.js.example" ( goto cgitclone )
powershell -Command "(New-Object Net.WebClient).DownloadFile('%urlexample%', 'C:\sipd-chrome-extension\config.js.example')"

:cgitclone
if exist "C:\sipd-chrome-extension\manifest.json" ( goto cgitpull )
git clone https://github.com/agusnurwanto/sipd-chrome-extension.git C:\sipd-chrome-extension
goto cconfigjs

:cgitpull
git -C C:\sipd-chrome-extension\ pull origin master
if not exist "C:\sipd-chrome-extension\config.js" ( goto cconfigjs ) else ( goto done )

:cconfigjs
powershell -Command "(New-Object Net.WebClient).DownloadFile('%urljs%', 'C:\sipd-chrome-extension\config.js')"
goto done

::-----------
:: Finalisasi
::-----------
:relaunch
echo Jalankan aplikasi ini lagi.
if exist "%filename%" ( del /f %filename% )
pause
exit
:done
if exist "%filename%" ( del /f %filename% )
timeout 5