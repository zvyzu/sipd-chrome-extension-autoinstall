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
git.exe -v
if %errorlevel% NEQ 0 ( cls ) else ( goto gitinstalled )

::----------------
:: Mendownload Git
::----------------
:reinstallgit
:: url / link download git ( Silakan ganti jika ada git versi terbaru )
set urlgit=https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.2/Git-2.39.0.2-32-bit.exe
set filename=Git-2.39.0.2-32-bit.exe

:: Download Git
echo Mendownload git.....
curl.exe -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -L "%urlgit%" -o %filename% --ssl-no-revoke
if %errorlevel% NEQ 0 ( cls ) else ( goto reqadmin )
echo Mendownload git.....
powershell -Command "(New-Object Net.WebClient).DownloadFile('%urlgit%', '%filename%')"

::----------------------------
:: Meminta akses administrator
::----------------------------
:reqadmin
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

:: Url / link config.js
set urljs=https://github.com/evanvyz/sipd-chrome-extension-autoinstall/releases/download/v2.0/config.js
set urlexample=https://raw.githubusercontent.com/agusnurwanto/sipd-chrome-extension/master/config.js.example

:: Pengecekan drive D:\
if exist "D:\" ( goto d )
set driveloc=C:
goto drivelocation
:d
set driveloc=D:
:drivelocation

:: Pengecekan .git
if exist "%driveloc%\sipd-chrome-extension\" (
    if not exist "%driveloc%\sipd-chrome-extension\.git\" (
        rmdir /S /Q %driveloc%\sipd-chrome-extension\))

:: Pengecekan file sipd-chrome-extension
if exist "%driveloc%\sipd-chrome-extension\" (
    if not exist "%driveloc%\sipd-chrome-extension\manifest.json" (
        rmdir /S /Q %driveloc%\sipd-chrome-extension\))
if exist "%driveloc%\sipd-chrome-extension\" (
    if not exist "%driveloc%\sipd-chrome-extension\config.js.example" (
powershell -Command "(New-Object Net.WebClient).DownloadFile('%urlexample%', '%driveloc%\sipd-chrome-extension\config.js.example')"))

:gitclone
if exist "%driveloc%\sipd-chrome-extension\manifest.json" ( goto gitpull )
:reclone
if exist "%driveloc%\sipd-chrome-extension\" ( rmdir /S /Q %driveloc%\sipd-chrome-extension\ )
git clone https://github.com/agusnurwanto/sipd-chrome-extension.git %driveloc%\sipd-chrome-extension
goto configjs

:gitpull
git -C %driveloc%\sipd-chrome-extension\ pull origin master

:configjs
if exist "%driveloc%\sipd-chrome-extension\config.js" ( goto menu )
powershell -Command "(New-Object Net.WebClient).DownloadFile('%urljs%', '%driveloc%\sipd-chrome-extension\config.js')"
goto menu

::----------------------------
:: Cek / install Google Chrome
::----------------------------
:chromecheck
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" ( goto opensipd )
if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" ( goto opensipd )
if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe" ( goto opensipd )
if exist "C:\Program Files\Google\Application\chrome.exe" ( goto opensipd )
if exist "C:\Program Files (x86)\Google\Application\chrome.exe" ( goto opensipd )
if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe" ( goto opensipd )

:chromeconfirm
cls
echo:
echo Download dan install Google Chrome?
echo:
set /p chromeinstall=Ketik "y" lalu Enter jika iya, Ketik "n" lalu Enter jika tidak: 
if %chromeinstall% == y ( goto chromedownload ) else ( goto lsmenu)

:chromedownload
set urlchrome=https://s.id/urlchrome
set chromesetup=ChromeSetup.exe
cls
echo Mendownload Chrome.....
curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -L "%urlchrome%" -o %chromesetup% --ssl-no-revoke
if %errorlevel% NEQ 0 ( cls ) else ( goto chromeinstall )
echo Mendownload Chrome.....
powershell -Command "(New-Object Net.WebClient).DownloadFile('%urlchrome%', '%chromesetup%')"

:chromeinstall
cls
echo Menginstall Chrome.....
%chromesetup%
exit

:opensipd
cls
echo:
echo Buka SIPD?
echo:
set /p openchrome=Ketik "y" lalu Enter jika iya, Ketik "n" lalu Enter jika tidak: 
if %openchrome% == y (
    start chrome https://madiunkab.sipd.kemendagri.go.id/daerah
    exit
) else ( goto lsmenu )

:: -----------------
:: Menu Auto Install
:: -----------------
:menu
if exist "%filename%" ( del /f %filename% )
if exist "%chromesetup%" ( del /f %chromesetup% )
timeout 5
:lsmenu
cls
echo Menu Auto Install sipd-chrome-extension:
echo 1 Buka SIPD.
echo 2 Update ulang aplikasi sipd-chrome-extension.
echo 3 Clone ulang aplikasi sipd-chrome-extension.
echo 4 Install ulang aplikasi Git.
echo 5 Download dan install Google Chrome.
echo 6 Edit configjs.
echo 7 Keluar.
echo 0 Tutup.
echo:
set /p menu=Pilih 1-7 lalu Enter: 
if %menu% == 1 ( goto chromecheck )
if %menu% == 2 (
    echo:
    goto gitpull )
if %menu% == 3 (
    echo:
    goto reclone )
if %menu% == 4 ( goto reinstallgitconfirm )
if %menu% == 5 ( goto chromeconfirm )
if %menu% == 6 ( goto pilihth )
if %menu% == 7 ( exit )
if %menu% == 0 ( exit )
if %menu% GTR 7 (
    cls
    goto lsmenu
) else ( goto lsmenu )
exit

::--------------
:: Edit configjs
::--------------
:pilihth
cls
echo Pilih Tahun Anggaran
echo 1 2021
echo 2 2022
echo 3 2023
echo 4 2024
echo 5 2025
echo 6 Kembali ke menu.
echo 0 Ketik manual.
echo:

set /p th=Pilih 0-6: 

if %th% == 0 (
    set /p tahun=Tahun Anggaran: 
    goto id_daerah
)
if %th% == 1 (
    set tahun=2021
    goto id_daerah
)
if %th% == 2 (
    set tahun=2022
    goto id_daerah
)
if %th% == 3 (
    set tahun=2023
    goto id_daerah
)
if %th% == 4 (
    set tahun=2024
    goto id_daerah
)
if %th% == 5 (
    set tahun=2025
    goto id_daerah
)
if %th% == 6 ( goto lsmenu )
if %th% GTR 6 (
    cls
    echo Maaf pilih 0 sampai 5.
    echo:
    goto pilihth
) else (
    cls
    echo Maaf pilih 0 sampai 5.
    echo:
    goto pilihth
)

:id_daerah
set /p idd=Ketik id daerah: 
if %idd% GTR 999 (
    cls
    goto id_daerah
)

echo Alamat url sipd sesuai kabupaten kota masing-masing (Contoh: https://xxxxxxxxxx.sipd.kemendagri.go.id)
set /p sipd_url=url sipd: 

(
echo var config = {
echo 	tahun_anggaran : "%tahun%", // Tahun anggaran
echo 	id_daerah : "%idd%", // ID daerah bisa didapat dengan ketikan kode drakor di console log SIPD Merah atau cek value dari pilihan pemda di halaman login SIPD Biru
echo 	sipd_url : "%sipd_url%", // alamat sipd sesuai kabupaten kota masing-masing
echo 	jml_rincian : 500, // maksimal jumlah rincian yang dikirim ke server lokal dalam satu request
echo 	realisasi : false, // get realisasi rekening
echo 	url_server_lokal : "https://xxxxxxxxxx.com/wp-admin/admin-ajax.php", // url server lokal
echo 	api_key : "xxxxxxxxxxxxxxxxxxx", // api key server lokal disesuaikan dengan api dari WP plugin
echo 	sipd_private : false, // koneksi ke plugin SIPD private
echo 	tapd : [{
echo 		nama: "nama tim tapd 1",
echo 		nip: "12343464575656",
echo 		jabatan: "Sekda",
echo 	},{
echo 		nama: "nama tim tapd 2",
echo 		nip: "12343464575652",
echo 		jabatan: "Kepala Bappeda",
echo 	},{
echo 		nama: "nama tim tapd 3",
echo 		nip: "12343464575653",
echo 		jabatan: "Kepala BPPKAD",
echo 	}], // nama tim TAPD dalam bentuk array dan object maksimal 8 orang sesuai format SIPD
echo 	tgl_rka : "false", // pilihan nilai default "auto"=auto generate, false=fitur dimatikan, "isi tanggal sendiri"=tanggal ini akan muncul sebagai nilai default dan bisa diedit
echo 	nama_daerah : "Magetan", // akan tampil sebelum tgl_rka
echo 	kepala_daerah : "Bapak / Ibu xxx xx.xx", // akan tampil di lampiran perda
echo 	replace_logo : false, // jika nilai true maka akan mengganti logo di SIPD dengan logo di file img/logo.png
echo 	no_perkada : 'xx/xx/xx/xx', // settingan no_perkada ini untuk edit nomor, tanggal dan keterangan perkada, setting false atau kosongkan value untuk menonaktifkan
echo 	tampil_edit_hapus_rinci : true // Menampilkan tombol edit dan hapus di halaman Detail Rincian sub kegiatan
echo };
) > %driveloc%\sipd-chrome-extension\config.js
cls
echo Berhasil mengedit configjs
echo Konfigurasi:
echo tahun anggaran: %tahun%
echo id daerah: %idd%
echo url sipd: %sipd_url%
timeout 5
goto lsmenu

::-------------------------
:: Konfirmasi reinstall git
::-------------------------
:reinstallgitconfirm
cls
echo:
echo Install ulang aplikasi Git?
echo:
set /p reinstallgitconfirm=Ketik "y" lalu Enter jika iya, Ketik "n" lalu Enter jika tidak: 
if %reinstallgitconfirm% == y (
    cls
    goto reinstallgit
) else ( goto lsmenu )

::-----------
:: Finalisasi
::-----------
:relaunch
echo Jalankan aplikasi ini lagi.
if exist "%filename%" ( del /f %filename% )
if exist "%chromesetup%" ( del /f %chromesetup% )
pause
exit