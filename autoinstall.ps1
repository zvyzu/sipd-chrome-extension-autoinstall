#=================
# Global Functions
#=================

function Start-Download {
    Param (
        [Parameter(Mandatory = $true)][string]$url,
        [Parameter(Mandatory = $true)][string]$pathname
    )

    try {
        Invoke-WebRequest -Uri $url -OutFile $pathname
    }
    catch {
        try {
            Invoke-RestMethod -Uri $url -OutFile $pathname
        }
        catch {
            try {
                (New-Object System.Net.WebClient).DownloadFile($url, $pathname)
            }
            catch {
                Start-BitsTransfer -Source $url -Destination $pathname
            }
        }
    }
}

#=================
# Global Variables
#=================

# Nama folder untuk menampung chrome extension lain
$folder = "chrome-extension"

# Nama folder untuk sipd-chrome-extension
$sipd = "sipd-chrome-extension"

# Pengecekan drive D:
if (Test-Path "D:\" ) {
    $drive = "D:\$folder"
}
else {
    $drive = "$env:SystemDrive\$folder"
}

#=====================
# Cek Koneksi Internet
#=====================

# Cek Koneksi ke www.google.com
if (-Not (Test-Connection www.google.com -Count 1 -Quiet)) {
    Write-Host "Tidak dapat terkoneksi ke internet, Cek koneksi internet anda."
    Start-Sleep -Seconds 5
    exit
}

#=============================
# Mengecek dan menginstall Git
#=============================

function Install-choco {
    # Pengecekan Chocolatey sudah terinstall
    if ((Get-Command -Name choco -ErrorAction Ignore) -and ($chocoVersion = (Get-Item "$env:ChocolateyInstall\choco.exe" -ErrorAction Ignore).VersionInfo.ProductVersion)) {
        Write-Output "Chocolatey Versi $chocoVersion sudah terinstall"
    }
    else {
        Write-Output "Menginstall Chocolatey"
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        powershell choco feature enable -n allowGlobalConfirmation
    }
}

function Install-git {
    # Penginstallan Git menggunakan Chocolatey
    try {
        # Nama package official Git adalah "git.install" bukan "git"
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-command choco install git.install --yes | Out-Host" -WindowStyle Normal
        Start-Sleep -Seconds 10
        Wait-Process choco -Timeout 240 -ErrorAction SilentlyContinue
    }
    catch [System.InvalidOperationException] {
        Write-Warning "Klik Yes di User Access Control untuk Menginstall"
    }
    catch {
        Write-Error $_.Exception
        Start-Sleep -Seconds 10
    }
}

# Cek jika git sudah terinstall
if (-Not(Get-Command -Name git -ErrorAction Ignore)) {
    Install-choco
    Install-git
}
else {
    Write-Host ' '
    choco outdated
}

#===============================
# Melakukan git clone / git pull
#===============================

Function Start-Download_configjs {
    write-Host 'Mengunduh config.js'
    # URL config.js
    $url_configjs = "https://raw.githubusercontent.com/evanvyz/sipd-chrome-extension-autoinstall/main/config.js"
    # Mendownload config.js
    Start-Download -url $url_configjs -pathname "$drive\$sipd\config.js"
}

Function Start-Git_Clone_Sipd {
    # Mengecek folder sudah ada
    if (Test-Path "$drive\$sipd") {
        Remove-Item -LiteralPath "$drive\$sipd" -Force -Recurse
    }
    # Melakukan git clone
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-command git clone https://github.com/agusnurwanto/sipd-chrome-extension.git $drive\$sipd | Out-Host" -WindowStyle Normal
        Start-Sleep -s 1
        Wait-Process git -Timeout 120 -ErrorAction SilentlyContinue
        Start-Download_configjs
    }
    catch {
        Write-Error $_.Exception
        Start-Sleep -Seconds 10
    }
}

Function Start-Git_Pull_Sipd {
    # Melakukan git pull
    try {
        Write-Host ' '
        # git config --global --add safe.directory $drive\$sipd
        # git -C $drive\$sipd\ pull origin master
        Start-Sleep -s 5
        Wait-Process git -Timeout 60 -ErrorAction SilentlyContinue
    }
    catch {
        Write-Error $_.Exception
        Start-Sleep -Seconds 10
    }
}

if (Test-Path "$drive\$sipd") {
    # Daftar file dan folder sipd-chrome-extension
    $files = @(
        '.git',
        'css',
        'excel\BANKEU.xlsx',
        'excel\BOS-HIBAH.xlsx',
        'img\indonesia-flag.png',
        'img\logo.png',
        'js',
        '.gitignore',
        'config.js.example',
        'manifest.json',
        'popup.html',
        'README.md'
    )
    # Mengecek kelengkapan file sipd-chrome-extension
    foreach ($file in $files) {
        if (-Not(Test-Path "$drive\$sipd\$file")) {
            Write-Host ' '
            Write-Warning 'File / folder tidak lengkap, Menghapus folder sipd-chrome-extension.'
            Remove-Item -Path "$drive\$sipd" -Force -Recurse
            Write-Host ' '
            Write-Host 'Menjalankan git clone...'
            Write-Host ' '
            Start-Git_Clone_Sipd
            break
        }
    }
    # Mengecek config.js
    if (-Not(Test-Path "$drive\$sipd\config.js")) {
        Start-Download_configjs
    }
    else {
        Start-Git_Pull_Sipd
    }
}
else {
    Start-Git_Clone_Sipd
}

#==========================================
# 1. Menu Buka SIPD / Install Google Chrome
#==========================================

Function Install-Chrome {
    Write-Host ' '
    Write-Host 'Ketik "y" lalu tekan Enter untuk menginstall Google Chrome.'
    Write-Host ' '
    $confirm = Read-Host "Download dan install Google Chrome?"
    if ($confirm -eq "y") {
        try {
            # Perlu di ingat choco install googlechrome akan menginstall tidak peduli chrome sudah terinstall
            Start-Process powershell.exe -Verb RunAs -ArgumentList "-command choco install googlechrome --yes | Out-Host" -WindowStyle Normal
            Start-Sleep -s 10
            Wait-Process choco -Timeout 240 -ErrorAction SilentlyContinue
        }
        catch [System.InvalidOperationException] {
            Write-Warning "Klik Yes di User Access Control untuk Menginstall"
        }
        catch {
            Write-Error $_.Exception
        }
    }
}

Function Open-Sipd {
    Clear-Host
    Write-Host ' '
    Write-Host 'Ketik "y" dan tekan Enter untuk membuka SIPD.'
    Write-Host ' '
    $confirm = Read-Host "Buka SIPD?"
    if ($confirm -eq "y") {
        try {
            # Membuka SIPD dengan chrome extension sipd-chrome-extension (Bersifat tidak permanen / hilang jika ditutup)
            Start-Process chrome.exe -ArgumentList "--load-extension=$drive\$sipd", "https://madiunkab.sipd.kemendagri.go.id/daerah"
        }
        catch {
            Write-Host ' '
            Write-Warning "Google Chrome Belum terinstall."
            Write-Host ' '
            Install-Chrome
        }
    }
}

#==============================================
# 2. Menu git pull ulang sipd-chrome-extension.
#==============================================

Function Confirm-git_pull {
    Clear-Host
    Write-Host ' '
    Write-Host 'Ketik "y" dan tekan Enter untuk git pull ulang sipd-chrome-extension.'
    Write-Host ' '
    $confirm = Read-Host "git pull ulang sipd-chrome-extension?"
    if ($confirm -eq "y") {
        Start-Git_Pull_Sipd
    }
}

#===========================================
# 3. Menu Clone ulang sipd-chrome-extension.
#===========================================

Function Confirm-git_clone {
    Clear-Host
    Write-Host ' '
    Write-Host 'Ketik "y" dan tekan Enter untuk git clone ulang sipd-chrome-extension.'
    Write-Host ' '
    $confirm = Read-Host "git clone ulang sipd-chrome-extension?"
    if ($confirm -eq "y") {
        Start-Git_Clone_Sipd
    }
}

#=======================
# 4. Menu Edit config.js
#=======================

Function Edit-configjs {
    # Menampilkan pilihan tahun anggaran
    Function Show-Tahun_Anggaran {
        Clear-Host
        Write-Host "Tahun Anggaran:"
        Write-Host "1 2021"
        Write-Host "2 2022"
        Write-Host "3 2023"
        Write-Host "4 2024"
        Write-Host "5 Ketik manual."
        Write-Host "0 Kembali ke menu utama."
        Write-Host " "
    }
    
    # Menampilkan input id daerah dan url sipd lalu mereplace file config.js
    Function Show-id_url {
        Write-Host ' '
        Write-Host 'ID daerah bisa didapat dengan ketikan kode drakor di console log SIPD Merah atau cek value dari pilihan pemda di halaman login SIPD Biru.'
        Write-Host ' '
        $id_daerah = Read-Host "ID Daerah"
        Write-Host ' '
        Write-Host 'Alamat URL SIPD sesuai Kabupaten Kota masing-masing.'
        Write-Host 'Contoh: https://xxxxxxxx.sipd.kemendagri.go.id'
        Write-Host ' '
        $sipd_url = Read-Host "URL SIPD"
        Clear-Host
        Write-Host 'Perubahan config.js:'
        Write-Host ' '
        Write-Host "Tahun Anggaran: $tahun_anggaran"
        Write-Host "ID Daerah: $id_daerah"
        write-Host "URL SIPD: $sipd_url"
        Write-Host ' '
        Write-Host "Menyimpan perubahan ke $drive\$sipd\config.js"
        Start-Sleep -s 5
        $configjs = @"
var config = {
	tahun_anggaran : "$tahun_anggaran", // Tahun anggaran
	id_daerah : "$id_daerah", // ID daerah bisa didapat dengan ketikan kode drakor di console log SIPD Merah atau cek value dari pilihan pemda di halaman login SIPD Biru
	sipd_url : "$sipd_url", // alamat sipd sesuai kabupaten kota masing-masing
	jml_rincian : 500, // maksimal jumlah rincian yang dikirim ke server lokal dalam satu request
	realisasi : false, // get realisasi rekening
	url_server_lokal : "https://xxxxxxxxxxxxxxx/wp-admin/admin-ajax.php", // url server lokal
	api_key : "xxxxxxxxxxxxxxxxxxx", // api key server lokal disesuaikan dengan api dari WP plugin
	sipd_private : false, // koneksi ke plugin SIPD private
	tapd : [{
		nama: "nama tim tapd 1",
		nip: "12343464575656",
		jabatan: "Sekda",
	},{
		nama: "nama tim tapd 2",
		nip: "12343464575652",
		jabatan: "Kepala Bappeda",
	},{
		nama: "nama tim tapd 3",
		nip: "12343464575653",
		jabatan: "Kepala BPPKAD",
	}], // nama tim TAPD dalam bentuk array dan object maksimal 8 orang sesuai format SIPD
	tgl_rka : "false", // pilihan nilai default "auto"=auto generate, false=fitur dimatikan, "isi tanggal sendiri"=tanggal ini akan muncul sebagai nilai default dan bisa diedit
	nama_daerah : "Magetan", // akan tampil sebelum tgl_rka
	kepala_daerah : "Bapak / Ibu xxx xx.xx", // akan tampil di lampiran perda
	replace_logo : false, // jika nilai true maka akan mengganti logo di SIPD dengan logo di file img/logo.png
	no_perkada : 'xx/xx/xx/xx', // settingan no_perkada ini untuk edit nomor, tanggal dan keterangan perkada, setting false atau kosongkan value untuk menonaktifkan
	tampil_edit_hapus_rinci : true // Menampilkan tombol edit dan hapus di halaman Detail Rincian sub kegiatan
};
"@
        $configjs | Out-File -Encoding utf8 -LiteralPath "$drive\$sipd\config.js" -Force
    }
    # melakukan tindakan sesuai input user
    do {
    Show-Tahun_Anggaran
    $pilih_th = Read-Host "Pilih Tahun Anggaran"
    switch ($pilih_th) {
    '1' {
        $tahun_anggaran = "2021" 
        Show-id_url
        $pilih_th = '0'
    }
    '2' {
        $tahun_anggaran = "2022"
        Show-id_url
        $pilih_th = '0'
    }
    '3' {
        $tahun_anggaran = "2023"
        Show-id_url
        $pilih_th = '0'
    }
    '4' {
        $tahun_anggaran = "2024"
        Show-id_url
        $pilih_th = '0'
    }
    '5' {
        Write-Host ' '
        $tahun_anggaran = Read-Host "Tahun Anggaran"
        Show-id_url
        $pilih_th = '0'
    }
    }
    }
    until ($pilih_th -eq '0')
}

#=============================
# 5. Menu update aplikasi Git.
#=============================

Function Confirm-update_git {
    Clear-Host
    Write-Host ' '
    Write-Host 'Ketik "y" dan tekan Enter untuk update aplikasi Git.'
    Write-Host ' '
    $confirm = Read-Host "Update aplikasi Git?"
    if ($confirm -eq "y") {
        try {
            # Nama package official Git adalah "git.install" bukan "git"
            Start-Process powershell.exe -Verb RunAs -ArgumentList "-command choco upgrade git.install --yes | Out-Host" -WindowStyle Normal
            Start-Sleep -s 10
            Wait-Process choco -Timeout 240 -ErrorAction SilentlyContinue
        }
        catch [System.InvalidOperationException] {
            Write-Warning "Klik Yes di User Access Control untuk Menginstall"
        }
        catch {
            Write-Error $_.Exception
        }
    }
}

#====================================
# 6. Menu Install ulang aplikasi Git.
#====================================

Function Confirm-reinstall_git {
    Clear-Host
    Write-Host ' '
    Write-Host 'Ketik "y" dan tekan Enter untuk install ulang aplikasi Git.'
    Write-Host ' '
    $confirm = Read-Host "Install ulang aplikasi Git?"
    if ($confirm -eq "y") {
        try {
            # Nama package official Git adalah "git.install" bukan "git"
            Start-Process powershell.exe -Verb RunAs -ArgumentList "-command choco uninstall git.install --yes | Out-Host" -WindowStyle Normal
            Start-Sleep -s 10
            Wait-Process choco -Timeout 240 -ErrorAction SilentlyContinue
        }
        catch [System.InvalidOperationException] {
            Write-Warning "Klik Yes di User Access Control untuk Menginstall"
        }
        catch {
            Write-Error $_.Exception
        }
        Install-git
    }
}

#============================================
# 7. Menu Download dan install Google Chrome.
#============================================

Function Confirm-chrome {
    Clear-Host
    write-Host ' '
    write-Host 'Mengecek Google Chrome terinstall...'
    write-Host ' '
    try {
        # Perlu di ingat choco install googlechrome akan menginstall tidak peduli chrome sudah terinstall
        Start-Process chrome.exe
        Wait-Process chrome -Timeout 1 -ErrorAction SilentlyContinue
        Get-Process chrome | Stop-Process -Force
        Write-Host 'Google Chrome sudah terinstall.'
        Start-Sleep -s 5
    }
    catch {
        Install-Chrome
    }
}

#====================================
# 8. Menu Update aplikasi Chocolatey.
#====================================

Function Confirm-update_chocolatey {
    Clear-Host
    Write-Host ' '
    Write-Host 'Ketik "y" dan tekan Enter untuk update aplikasi Chocolatey.'
    Write-Host ' '
    $confirm = Read-Host "Update aplikasi Chocolatey?"
    if ($confirm -eq "y") {
        try {
            Start-Process powershell.exe -Verb RunAs -ArgumentList "-command choco upgrade chocolatey --yes | Out-Host" -WindowStyle Normal
            Start-Sleep -s 10
            Wait-Process choco -Timeout 240 -ErrorAction SilentlyContinue
        }
        catch [System.InvalidOperationException] {
            Write-Warning "Klik Yes di User Access Control untuk Menginstall"
        }
        catch {
            Write-Error $_.Exception
        }
    }
}

#=======================================
# 9. Menu Tentang sipd-chrome-extension.
#=======================================

Function Open-about_sipd_chrome_extension {
    Clear-Host
    Write-Host ' '
    Write-Host 'Ketik "y" dan tekan Enter untuk tentang sipd-chrome-extension.'
    Write-Host ' '
    $confirm = Read-Host "Buka Tentang sipd-chrome-extension?"
    if ($confirm -eq "y") {
        try {
            Start-Process chrome.exe -ArgumentList "--load-extension=$drive\$sipd", "https://github.com/agusnurwanto/sipd-chrome-extension#readme"
        }
        catch {
            Write-Host ' '
            Write-Warning "Google Chrome Belum terinstall."
            Write-Host ' '
            Install-Chrome
        }
    }
}

#===================================
# 10. Menu Administrator / Developer
#===================================

Function Start-Menu_Admin {
    Function Show-Menu_Admin {
        Param (
            [string]$title = 'Menu Administrator'
        )
        Clear-Host
        Write-Host "================ $title ================"
        Write-Host " "
        Write-Host "11 Uninstall Git."
        Write-Host "12 Uninstall Chocolatey."
        Write-Host "13 ."
        Write-Host "14 ."
        Write-Host "15 ."
        Write-Host "16 ."
        Write-Host "17 ."
        Write-Host "18 ."
        Write-Host "19 ."
        Write-Host "20 Menu Developer."
        Write-Host "0 Kembali ke Menu Utama."
        Write-Host " "
        Write-Host "Pilih lalu Enter untuk memilih."
        Write-Host " "
    }

    do {
        Show-Menu_Admin
        $pilihan = Read-Host "Pilih"
        switch ($pilihan) {
        '11' {}
        '12' {}
        '13' {}
        '14' {}
        '15' {}
        '16' {}
        '17' {}
        '18' {}
        '19' {}
        '20' {}
        }
    }
    until ($pilihan -eq 0)
}

#==============
# Menu Aplikasi
#==============

Function Start-Menu {
    Function Show-Menu {
        Param (
            [string]$title = 'Menu APPEM Chrome Extension'
        )
        Clear-Host
        Write-Host "================ $title ================"
        Write-Host " "
        Write-Host "1 Buka SIPD."
        Write-Host "2 Update ulang sipd-chrome-extension."
        Write-Host "3 Clone ulang sipd-chrome-extension."
        Write-Host "4 Edit config.js."
        Write-Host "5 Update aplikasi Git."
        Write-Host "6 Install ulang aplikasi Git."
        Write-Host "7 Download dan install Google Chrome."
        Write-Host "8 Update aplikasi Chocolatey."
        Write-Host "9 Tentang sipd-chrome-extension."
        Write-Host "10 Menu Administrator / Developer."
        Write-Host "0 Tutup aplikasi."
        Write-Host " "
        Write-Host "Pilih lalu Enter untuk memilih."
        Write-Host " "
    }

    do {
        Show-Menu
        $pilihan = Read-Host "Pilih"
        switch ($pilihan) {
        '1'  {Open-Sipd}
        '2'  {Confirm-git_pull}
        '3'  {Confirm-git_clone}
        '4'  {Edit-configjs}
        '5'  {Confirm-update_git}
        '6'  {Confirm-reinstall_git}
        '7'  {Confirm-chrome}
        '8'  {Confirm-update_chocolatey}
        '9'  {Open-about_sipd_chrome_extension}
        '10' {Start-Menu_Admin}
        }
    }
    until ($pilihan -eq 0)
}

Start-Menu