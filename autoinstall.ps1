#=====================
# Cek Koneksi Internet
#=====================

# Tes koneksi ke www.google.com
$net = (Test-Connection www.google.com -Count 1 -Quiet)

# Cek Koneksi Internet
If ($net -ne "True") {
    Write-Host "Tidak dapat terkoneksi ke internet, Cek koneksi internet anda."
    Start-Sleep -Seconds 5
    exit
}

#=============================
# Mengecek dan menginstall Git
#=============================

Function Install-Git {
    #Pengecekan chocolatey sudah terinstall
    if ((Get-Command -Name choco -ErrorAction Ignore) -and ($chocoVersion = (Get-Item "$env:ChocolateyInstall\choco.exe" -ErrorAction Ignore).VersionInfo.ProductVersion)) {
        Write-Output "Chocolatey Versi $chocoVersion sudah terinstall"
    } else {
        Write-Output "Menginstall Chocolatey"
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        powershell choco feature enable -n allowGlobalConfirmation
    }
    
    #Penginstallan Git menggunakan Chocolatey
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-command choco install git.install --yes | Out-Host" -WindowStyle Normal
        Start-Sleep -s 20
        Wait-Process choco -Timeout 240 -ErrorAction SilentlyContinue
    } catch [System.InvalidOperationException] {
        Write-Warning "Klik Yes di User Access Control untuk Menginstall"
    } catch {
        Write-Error $_.Exception
    }
}

# Cek jika git sudah terinstall
if (Get-Command -Name git -ErrorAction Ignore) {
    Write-Output "Git sudah terinstall"
} else {Install-Git}

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

Function GitCloneSipd {
    # Mengecek folder sudah ada
    if (Test-Path "$drive\sipd-chrome-extension") {
        Remove-Item -LiteralPath "$drive\sipd-chrome-extension" -Force -Recurse
    }
    # Melakukan git clone
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-command git clone https://github.com/agusnurwanto/sipd-chrome-extension.git $drive\sipd-chrome-extension | Out-Host" -WindowStyle Normal
        Start-Sleep -s 10
        Wait-Process git -Timeout 120 -ErrorAction SilentlyContinue
    } catch {
        Write-Error $_.Exception
    }
}

function GitPullSipd {
    # Melakukan git pull
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-command git -C $drive\sipd-chrome-extension\ pull origin master" -WindowStyle Normal
        Start-Sleep -s 1
        Wait-Process git -Timeout 60 -ErrorAction SilentlyContinue
    } catch {
        Write-Error $_.Exception
    }
}

Function configjs {
    # URL config.js
    $url_configjs = "https://github.com/evanvyz/sipd-chrome-extension-autoinstall/releases/download/v2.0/config.js"
    Write-Host "Mendownload config.js"
    # Mendownload config.js
    Invoke-WebRequest -Uri $url_configjs -OutFile "$drive\sipd-chrome-extension\config.js"
}

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

if (Test-Path "$drive\sipd-chrome-extension") {
    # Mengecek kelengkapan file sipd-chrome-extension
    foreach ($file in $files) {
        if (-Not (Test-Path "$drive\sipd-chrome-extension\$file")) {
            Remove-Item -LiteralPath "$drive\sipd-chrome-extension" -Force -Recurse
            GitCloneSipd
            break
        }
    }

    # Mengecek config.js
    if (Test-Path "$drive\sipd-chrome-extension\config.js") {
        GitPullSipd
    } else {configjs}
} else {
    GitCloneSipd
    configjs
}

#==================
# 1. Menu Buka SIPD
#==================

Function OpenSipd {
    try {
        Start-Process chrome.exe --load-extension=D:\chrome-extension\sipd-chrome-extension
    } catch {
        Write-Warning "Google Chrome Belum terinstall."
    }
}

#============================================
# 2. Menu Update ulang sipd-chrome-extension.
#============================================



#==============
# Menu Aplikasi
#==============

function Show-Menu {
    param (
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
}

do {
    Show-Menu
    $pilihan = Read-Host "Tekan 0-9 untuk memilih"
    switch ($pilihan) {
    '1' {OpenSipd}
    '2' {GitPullSipd}
    '3' {GitCloneSipd configjs}
    '4' {''}
    '5' {''}
    '6' {''}
    '7' {''}
    '8' {''}
    '9' {''}
    }
} until ($pilihan -eq 0)