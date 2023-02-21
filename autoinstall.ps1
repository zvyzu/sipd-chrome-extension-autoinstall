#=====================
# Cek Koneksi Internet
#=====================

# Cek Koneksi ke www.google.com
If (-Not (Test-Connection www.google.com -Count 1 -Quiet)) {
    Write-Host "Tidak dapat terkoneksi ke internet, Cek koneksi internet anda."
    Start-Sleep -s 5
    exit
}

#=============================
# Mengecek dan menginstall Git
#=============================

Function Install-choco {
    #Pengecekan Chocolatey sudah terinstall
    if ((Get-Command -Name choco -ErrorAction Ignore) -and ($chocoVersion = (Get-Item "$env:ChocolateyInstall\choco.exe" -ErrorAction Ignore).VersionInfo.ProductVersion)) {
        Write-Output "Chocolatey Versi $chocoVersion sudah terinstall"
    } else {
        Write-Output "Menginstall Chocolatey"
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        powershell choco feature enable -n allowGlobalConfirmation
    }
}

Function Install-git {
    #Penginstallan Git menggunakan Chocolatey
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-command choco install git.install --yes | Out-Host" -WindowStyle Normal
        Start-Sleep -s 10
        Wait-Process choco -Timeout 240 -ErrorAction SilentlyContinue
    } catch [System.InvalidOperationException] {
        Write-Warning "Klik Yes di User Access Control untuk Menginstall"
    } catch {
        Write-Error $_.Exception
    }
}

# Cek jika git sudah terinstall
if (-Not (Get-Command -Name git -ErrorAction Ignore)) {
    Install-choco
    Install-git
}

#===============================
# Melakukan git clone / git pull
#===============================

# Nama folder untuk menampung chrome extension lain
$folder = "chrome-extension"

# Pengecekan drive D:
if (Test-Path "D:\" ) {
    $drive = "D:\$folder"
} else {
    $drive = "C:\$folder"
}

Function Start-Download_configjs {
    # URL config.js
    $url_configjs = "https://github.com/evanvyz/sipd-chrome-extension-autoinstall/releases/download/v2.0/config.js"
    # Mendownload config.js
    Invoke-WebRequest -Uri $url_configjs -OutFile "$drive\sipd-chrome-extension\config.js"
}

Function Start-Git_Clone_Sipd {
    # Mengecek folder sudah ada
    if (Test-Path "$drive\sipd-chrome-extension") {
        Remove-Item -LiteralPath "$drive\sipd-chrome-extension" -Force -Recurse
    }
    # Melakukan git clone
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-command git clone https://github.com/agusnurwanto/sipd-chrome-extension.git $drive\sipd-chrome-extension | Out-Host" -WindowStyle Normal
        Start-Sleep -s 1
        Wait-Process git -Timeout 120 -ErrorAction SilentlyContinue
        Start-Download_configjs
    } catch {
        Write-Error $_.Exception
    }
}

Function Start-Git_Pull_Sipd {
    # Melakukan git pull
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-command git -C $drive\sipd-chrome-extension\ pull origin master" -WindowStyle Normal
        Start-Sleep -s 1
        Wait-Process git -Timeout 60 -ErrorAction SilentlyContinue
    } catch {
        Write-Error $_.Exception
    }
}

if (Test-Path "$drive\sipd-chrome-extension") {
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
        if (-Not (Test-Path "$drive\sipd-chrome-extension\$file")) {
            Remove-Item -LiteralPath "$drive\sipd-chrome-extension" -Force -Recurse
            Start-Git_Clone_Sipd
            break
        }
    }
    # Mengecek config.js
    if (-Not (Test-Path "$drive\sipd-chrome-extension\config.js")) {
        Start-Download_configjs
        Start-Git_Pull_Sipd
    } else {
        Start-Git_Pull_Sipd
    }
} else {
    Start-Git_Clone_Sipd
}

#==========================================
# 1. Menu Buka SIPD / Install Google Chrome
#==========================================

Function Install-Chrome {
    Write-Host ' '
    Write-Host 'Ketik "y" lalu tekan Enter untuk menginstall Google Chrome.'
    $confirm = Read-Host "Download dan install Google Chrome?"
    if ($confirm -eq "y") {
        try {
            Start-Process powershell.exe -Verb RunAs -ArgumentList "-command choco install googlechrome --yes | Out-Host" -WindowStyle Normal
            Start-Sleep -s 10
            Wait-Process choco -Timeout 240 -ErrorAction SilentlyContinue
        } catch [System.InvalidOperationException] {
            Write-Warning "Klik Yes di User Access Control untuk Menginstall"
        } catch {
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
            Start-Process chrome.exe -ArgumentList "--load-extension=$drive\sipd-chrome-extension", "https://madiunkab.sipd.kemendagri.go.id/daerah"
        } catch {
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
        Write-Host "Menyimpan perubahan ke $drive\sipd-chrome-extension\config.js"
        Start-Sleep -s 5
        $configjs = @"
var config = {
	tahun_anggaran : "$tahun_anggaran", // Tahun anggaran
	id_daerah : "$id_daerah", // ID daerah bisa didapat dengan ketikan kode drakor di console log SIPD Merah atau cek value dari pilihan pemda di halaman login SIPD Biru
	sipd_url : "$sipd_url", // alamat sipd sesuai kabupaten kota masing-masing
	jml_rincian : 500, // maksimal jumlah rincian yang dikirim ke server lokal dalam satu request
	realisasi : false, // get realisasi rekening
	url_server_lokal : "https://xxxxxxxxxx.com/wp-admin/admin-ajax.php", // url server lokal
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
        $configjs | Out-File -Encoding utf8 -LiteralPath "$drive\sipd-chrome-extension\config.js" -Force
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
    } until ($pilih_th -eq '0')
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
            Start-Process powershell.exe -Verb RunAs -ArgumentList "-command choco upgrade git.install --yes | Out-Host" -WindowStyle Normal
            Start-Sleep -s 10
            Wait-Process choco -Timeout 240 -ErrorAction SilentlyContinue
        } catch [System.InvalidOperationException] {
            Write-Warning "Klik Yes di User Access Control untuk Menginstall"
        } catch {
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
            Start-Process powershell.exe -Verb RunAs -ArgumentList "-command choco uninstall git.install --yes | Out-Host" -WindowStyle Normal
            Start-Sleep -s 10
            Wait-Process choco -Timeout 240 -ErrorAction SilentlyContinue
        } catch [System.InvalidOperationException] {
            Write-Warning "Klik Yes di User Access Control untuk Menginstall"
        } catch {
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
        Start-Process chrome.exe
        Wait-Process chrome -Timeout 1 -ErrorAction SilentlyContinue
        Get-Process chrome | Stop-Process -Force
        Write-Host 'Google Chrome sudah terinstall.'
        Start-Sleep -s 5
    } catch {
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
        } catch [System.InvalidOperationException] {
            Write-Warning "Klik Yes di User Access Control untuk Menginstall"
        } catch {
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
            Start-Process chrome.exe -ArgumentList "--load-extension=$drive\sipd-chrome-extension", "https://github.com/agusnurwanto/sipd-chrome-extension#readme"
        } catch {
            Write-Host ' '
            Write-Warning "Google Chrome Belum terinstall."
            Write-Host ' '
            Install-Chrome
        }
    }
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
        Write-Host "1 Buka SIPD."
        Write-Host "2 Update ulang sipd-chrome-extension."
        Write-Host "3 Clone ulang sipd-chrome-extension."
        Write-Host "4 Edit config.js."
        Write-Host "5 Update aplikasi Git."
        Write-Host "6 Install ulang aplikasi Git."
        Write-Host "7 Download dan install Google Chrome."
        Write-Host "8 Update aplikasi Chocolatey."
        Write-Host "9 Tentang sipd-chrome-extension."
        Write-Host "0 Tutup aplikasi."
        Write-Host " "
        Write-Host "Pilih lalu Enter untuk memilih."
        Write-Host " "
    }
    
    do {
        Show-Menu
        $pilihan = Read-Host "Pilih"
        switch ($pilihan) {
        '1' {Open-Sipd}
        '2' {Confirm-git_pull}
        '3' {Confirm-git_clone}
        '4' {Edit-configjs}
        '5' {Confirm-update_git}
        '6' {Confirm-reinstall_git}
        '7' {Confirm-chrome}
        '8' {Confirm-update_chocolatey}
        '9' {Open-about_sipd_chrome_extension}
        }
    } until ($pilihan -eq 0)
}

Start-Menu