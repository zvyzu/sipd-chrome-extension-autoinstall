var config = {
	tahun_anggaran : "2023", // Tahun anggaran
	id_daerah : "89", // ID daerah bisa didapat dengan ketikan kode drakor di console log SIPD Merah atau cek value dari pilihan pemda di halaman login SIPD Biru
	sipd_url : "https://madiunkab.sipd.kemendagri.go.id/", // alamat sipd sesuai kabupaten kota masing-masing
	jml_rincian : 500, // maksimal jumlah rincian yang dikirim ke server lokal dalam satu request
	realisasi : false, // get realisasi rekening
	url_server_lokal : "https://xxxxxxxxxx/wp-admin/admin-ajax.php", // url server lokal
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