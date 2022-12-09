import os
from time import sleep
from wget import download
from subprocess import call, Popen, DEVNULL, STDOUT

# Chrome location
c64 = os.path.isfile('C:\Program Files\Google\Chrome\Application\chrome.exe')
cx86 = os.path.isfile('C:\Program Files (x86)\Google\Chrome\Application\chrome.exe')
win764 = os.path.isfile('C:\Program Files\Google\Application\chrome.exe')
win7x86 = os.path.isfile('C:\Program Files (x86)\Google\Application\chrome.exe')

def cek(): # Mengecek git sudah terinstall
    try:
        call(['git'], stdout=DEVNULL, stderr=STDOUT)
        return False
    except OSError:
        return True

if cek(): # Mengecek git sudah terinstall
    try:
        Popen('wwinget install --id Git.Git -e --source winget')
    except OSError as e:
        print('Mendownload git')
        download('https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/Git-2.38.1-32-bit.exe')
        print('Sedang menginstall git')
        os.system('Git-2.38.1-32-bit.exe /VERYSILENT')
else:
    print('Git sudah terinstall')

while cek(): # Pengecekan sedang mendownload & menginstall git
    if cek() == False:
        break
    print('Sedang mendownload & menginstall git |')
    sleep(0.25)
    print('Sedang mendownload & menginstall git /')
    sleep(0.25)
    print('Sedang mendownload & menginstall git -')
    sleep(0.25)
    print('Sedang mendownload & menginstall git \\')
    sleep(0.25)
else:
    print('Sedang clone extension')
    os.system('git clone https://github.com/agusnurwanto/sipd-chrome-extension.git D:\sipd-chrome-extension')
    download('https://raw.githubusercontent.com/evanvyz/sipd-chrome-extension-autoinstall/main/config.js', out = 'D:\sipd-chrome-extension')

if c64 or cx86 or win764 or win7x86: # Mengecek Google Chrome terinstall
    pass
else:
    print('Silakan download & install Google Chrome.')
    print('https://www.google.com/chrome/')