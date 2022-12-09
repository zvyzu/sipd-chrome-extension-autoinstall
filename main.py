import os
from wget import download
from subprocess import call, Popen, DEVNULL, STDOUT

# Chrome location
c64 = os.path.isfile('C:\Program Files\Google\Chrome\Application\chrome.exe')
cx86 = os.path.isfile('C:\Program Files (x86)\Google\Chrome\Application\chrome.exe')
win764 = os.path.isfile('C:\Program Files\Google\Application\chrome.exe')
win7x86 = os.path.isfile('C:\Program Files (x86)\Google\Application\chrome.exe')

try: # Mengecek git sudah terinstall
    call(['git'], stdout=DEVNULL, stderr=STDOUT)
    print('Git sudah terinstall')
except:
    print('Mendownload & menginstall git')
    try:
        Popen('winget install --id Git.Git -e --source winget')
        print('Git berhasil terinstall.')
    except:
        print('Mendownload git')
        download('https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/Git-2.38.1-32-bit.exe')
        print('Sedang menginstall git')
        os.system('Git-2.38.1-32-bit.exe /VERYSILENT')
        print('Git berhasil terinstall.')

if c64 or cx86 or win764 or win7x86: # Mengecek Google Chrome terinstall
    pass
else:
    print('Silakan download & install Google Chrome.')
    print('https://www.google.com/chrome/')