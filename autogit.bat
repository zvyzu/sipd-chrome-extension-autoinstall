@echo off
set urljs=https://raw.githubusercontent.com/evanvyz/sipd-chrome-extension-autoinstall/main/config.js
set urlex=https://raw.githubusercontent.com/agusnurwanto/sipd-chrome-extension/master/config.js.example
if not exist "D:\" ( goto c )
if not exist "D:\sipd-chrome-extension\" ( goto gitclone )
if exist "D:\sipd-chrome-extension\config.js.example" ( goto gitclone )
curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -L "%urlex%" -o D:\sipd-chrome-extension\config.js.example --ssl-no-revoke
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
curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -L "%urljs%" -o D:\sipd-chrome-extension\config.js --ssl-no-revoke
goto done
:c
if not exist "C:\sipd-chrome-extension\" ( goto cgitclone )
if exist "C:\sipd-chrome-extension\config.js.example" ( goto cgitclone )
curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -L "%urlex%" -o C:\sipd-chrome-extension\config.js.example --ssl-no-revoke
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
curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -L "%urljs%" -o C:\sipd-chrome-extension\config.js --ssl-no-revoke
:done
timeout 2