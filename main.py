import os
import subprocess

# Lokasi git terinstall
exist64 = os.path.isfile('C:\Program Files\Git\cmd\git.exe')
existx86 = os.path.isfile('C:\Program Files (x86)\git\Git\cmd\git.exe')
existlocal = os.path.isfile('AppData\Local\Programs\Git\cmd\git.exe')

# Mengecek git sudah terinstall
if exist64 or existx86 or existlocal:
    print('Mengecek git sudah terinstall')
else:
    try: # Pengecekan terakhir jika lokasi git terinstall tidak diketahui
        subprocess.call(['git'])
        print('Git sudah terinstall')
    except:
        print('Mendownload dan Menginstall git')
        os.system('winget install --id Git.Git -e --source winget')