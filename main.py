from urllib import error
from urllib.request import urlopen
from os import system, path
from time import sleep
from wget import download
from subprocess import call, run, DEVNULL, STDOUT

# Googele Chrome location
c64 = path.isfile('C:\Program Files\Google\Chrome\Application\chrome.exe')
cx86 = path.isfile('C:\Program Files (x86)\Google\Chrome\Application\chrome.exe')
win764 = path.isfile('C:\Program Files\Google\Application\chrome.exe')
win7x86 = path.isfile('C:\Program Files (x86)\Google\Application\chrome.exe')

def connected(): # Cek koneksi ke github
    try:
        urlopen('https://github.com/', timeout=5)
        return True
    except error.URLError:
        return False

def git(): # Pengecek git sudah terinstall
    try:
        call(['git'], stdout=DEVNULL, stderr=STDOUT)
        return False
    except:
        return True

def gitinstall(): # Menginstall git
    try:
        run('winget install --id Git.Git -e --source winget')
    except FileNotFoundError:
        print('Mendownload git.')
        download('https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/Git-2.38.1-32-bit.exe')
        print('\n')
        print('Sedang menginstall git.')
        system('Git-2.38.1-32-bit.exe /VERYSILENT')

def gitclone(): # Handle errors git clone
    try:
        system('git clone https://github.com/agusnurwanto/sipd-chrome-extension.git D:\sipd-chrome-extension')
        download('https://raw.githubusercontent.com/evanvyz/sipd-chrome-extension-autoinstall/main/config.js', out = 'D:\sipd-chrome-extension')
        print('\n')
    except:
        system('git clone https://github.com/agusnurwanto/sipd-chrome-extension.git C:\sipd-chrome-extension')
        download('https://raw.githubusercontent.com/evanvyz/sipd-chrome-extension-autoinstall/main/config.js', out = 'C:\sipd-chrome-extension')
        print('\n')

def configjs(): # Mengecek config.js
    if path.isfile('D:\sipd-chrome-extension\config.js'):
        return False
    else:
        return True

def pullclone(): # Melakukan git clone & git pull
    if path.isfile('D:\sipd-chrome-extension'):
        system('del /f D:\sipd-chrome-extension')
    elif configjs():
        download('https://raw.githubusercontent.com/evanvyz/sipd-chrome-extension-autoinstall/main/config.js', out = 'D:\sipd-chrome-extension')
        system('git -C D:\sipd-chrome-extension pull')
    elif path.isfile('D:\sipd-chrome-extension\manifest.json'):
        system('git -C D:\sipd-chrome-extension pull')
    elif path.isfile('C:\sipd-chrome-extension'):
        system('del /f C:\sipd-chrome-extension')
    elif configjs():
        download('https://raw.githubusercontent.com/evanvyz/sipd-chrome-extension-autoinstall/main/config.js', out = 'C:\sipd-chrome-extension')
        system('git -C C:\sipd-chrome-extension pull')
    elif path.isfile('C:\sipd-chrome-extension\manifest.json'):
        system('git -C C:\sipd-chrome-extension pull')
    else:
        print('Sedang clone extension.')
        gitclone()

def cekchrome(): # Mengecek Google Chrome terinstall
    if c64 or cx86 or win764 or win7x86:
        pass
    else:
        print('Google Chrome belum di install, Silakan download & install Google Chrome.')
        print('https://www.google.com/chrome/')
        sleep(5)

if connected():
    if git(): # Mengecek git sudah terinstall
        gitinstall()
    else:
        print('Git sudah terinstall.')
    if git():
        print('Silakan jalankan ulang aplikasi ini.')
        sleep(5)
    else:
        pullclone()
        cekchrome()
        sleep(5)
else:
    print('Tidak dapat terkoneksi ke internet, Harap cek koneksi internet anda.')
    print('Jika hanya aplikasi ini saja yang tidak dapat terkoneksi ke internet, Coba lakukan berikut ini:')
    print('1. Tambahkan dan izinkan aplikasi ini ke Firewall.')
    print('2. Jika belum berhasil, Matikan anti virus seperti SMADAV dan Windows Defender jika perlu matikan juga Firewall.')
    sleep(10)