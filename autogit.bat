@echo off
set url=https://raw.githubusercontent.com/evanvyz/sipd-chrome-extension-autoinstall/main/config.js
if not exist "D:\" ( goto c )
if not exist "D:\sipd-chrome-extension\" ( goto gitclone )
if exist "D:\sipd-chrome-extension\config.js.example" ( goto gitclone )
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/agusnurwanto/sipd-chrome-extension/master/config.js.example', 'D:\sipd-chrome-extension\config.js.example')"
:gitclone
if exist "D:\sipd-chrome-extension\manifest.json" ( goto gitpull )
git clone https://github.com/agusnurwanto/sipd-chrome-extension.git D:\sipd-chrome-extension
cls
goto configjs
:gitpull
git -C D:\sipd-chrome-extension\ pull origin master
if not exist "D:\sipd-chrome-extension\config.js" ( goto configjs )
goto done
:configjs
powershell -Command "(New-Object Net.WebClient).DownloadFile('%url%', 'D:\sipd-chrome-extension\config.js')"
goto done
:c
if not exist "C:\sipd-chrome-extension\" ( goto cgitclone )
if exist "C:\sipd-chrome-extension\config.js.example" ( goto cgitclone )
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/agusnurwanto/sipd-chrome-extension/master/config.js.example', 'C:\sipd-chrome-extension\config.js.example')"
:cgitclone
if exist "C:\sipd-chrome-extension\manifest.json" ( goto cgitpull )
git clone https://github.com/agusnurwanto/sipd-chrome-extension.git C:\sipd-chrome-extension
cls
goto cconfigjs
:cgitpull
git -C C:\sipd-chrome-extension\ pull origin master
if not exist "C:\sipd-chrome-extension\config.js" ( goto cconfigjs )
goto done
:cconfigjs 
powershell -Command "(New-Object Net.WebClient).DownloadFile('%url%', 'C:\sipd-chrome-extension\config.js')"
:done
timeout 2