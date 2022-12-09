import os
from time import sleep
from wget import download
from subprocess import call, Popen, DEVNULL, STDOUT

# Chrome location
c64 = os.path.isfile('C:\Program Files\Google\Chrome\Application\chrome.exe')
cx86 = os.path.isfile('C:\Program Files (x86)\Google\Chrome\Application\chrome.exe')
win764 = os.path.isfile('C:\Program Files\Google\Application\chrome.exe')
win7x86 = os.path.isfile('C:\Program Files (x86)\Google\Application\chrome.exe')

def cek(): # Pengecek git sudah terinstall
    try:
        call(['git'], stdout=DEVNULL, stderr=STDOUT)
        return False
    except OSError:
        return True

def gitinstall(): # Menginstall git
    try:
        Popen('winget install --id Git.Git -e --source winget')
        while cek():
            sleep(0.25)
    except OSError as e:
        print('Mendownload git')
        download('https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/Git-2.38.1-32-bit.exe')
        print('Sedang menginstall git')
        os.system('Git-2.38.1-32-bit.exe /VERYSILENT')

def gitclone(): # Melakukan git pull & git clone
    if os.path.isfile('D:\sipd-chrome-extension'):
        os.system('del /f D:\sipd-chrome-extension')
    elif os.path.isfile('D:\sipd-chrome-extension\manifest.json'):
        os.system('git -C D:\sipd-chrome-extension pull')
    elif os.path.isfile('C:\sipd-chrome-extension\manifest.json'):
        os.system('git -C C:\sipd-chrome-extension pull')
    else:
        print('Sedang clone extension')
        os.system('git clone https://github.com/agusnurwanto/sipd-chrome-extension.git D:\sipd-chrome-extension')
        print('Mendownload config.js')
        download('https://raw.githubusercontent.com/evanvyz/sipd-chrome-extension-autoinstall/main/config.js', out = 'D:\sipd-chrome-extension')

if cek(): # Mengecek git sudah terinstall
    gitinstall()
else:
    gitclone()

if cek():
    gitinstall()
else:
    gitclone()

if c64 or cx86 or win764 or win7x86: # Mengecek Google Chrome terinstall
    pass
else:
    print('Silakan download & install Google Chrome.')
    print('https://www.google.com/chrome/')