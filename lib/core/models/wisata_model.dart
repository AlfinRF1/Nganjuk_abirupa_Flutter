class WisataModel {
  final String idWisata;
  final String namaWisata;
  final String lokasi;
  final int tiketDewasa;
  final int tiketAnak;
  final String biayaAsuransi;
  final String fasilitas;
  final String deskripsi;
  final String gambar;
  final bool isLocalImage;

  WisataModel({
    required this.idWisata,
    required this.namaWisata,
    required this.lokasi,
    required this.tiketDewasa,
    required this.tiketAnak,
    required this.biayaAsuransi,
    required this.fasilitas,
    required this.deskripsi,
    required this.gambar,
    required this.isLocalImage,
  });

  factory WisataModel.fromJson(Map<String, dynamic> json) {
    // Fungsi parsing tiket (aman dari error String/Int)
    int parseTiket(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    // --- LOGIKA HYBRID IMAGE LOADER ---
    String namaWisataDB = (json['nama_wisata'] ?? json['namaWisata'] ?? '').toString().toLowerCase();
    String namaFileGambar = json['gambar'] ?? '';
    
    bool isLokal = false;
    String finalPathGambar = '';

    // 1. Cek apakah ini 5 Wisata "Legend" (Lokal)
    if (namaWisataDB.contains('sedudo')) {
      isLokal = true;
      finalPathGambar = 'assets/images/wisata_air_terjun_sedudo.png';
    } else if (namaWisataDB.contains('roro kuning')) {
      isLokal = true;
      finalPathGambar = 'assets/images/wisata_roro_kuning.png';
    } else if (namaWisataDB.contains('margo tresno')) {
      isLokal = true;
      finalPathGambar = 'assets/images/wisata_goa_margotresno.png';
    } else if (namaWisataDB.contains('tirta') || namaWisataDB.contains('sritanjung')) {
      isLokal = true;
      finalPathGambar = 'assets/images/wisata_sritanjung.png';
    } else if (namaWisataDB.contains('ladang') || namaWisataDB.contains('tral')) {
      isLokal = true;
      finalPathGambar = 'assets/images/wisata_tral.png';
    } 
    // 2. Kalau bukan, berarti ini Wisata Baru (Ambil dari Hostinger)
    else {
      isLokal = false;
      finalPathGambar = namaFileGambar.isNotEmpty
          ? 'https://nganjukabirupa.pbltifnganjuk.com/assets/images/destinasi/$namaFileGambar'
          : '';
    }
    // ----------------------------------

    return WisataModel(
      idWisata: json['id_wisata']?.toString() ?? json['idWisata']?.toString() ?? '',
      namaWisata: json['nama_wisata'] ?? json['namaWisata'] ?? '',
      lokasi: json['lokasi'] ?? '',
      tiketDewasa: parseTiket(json['tiket_dewasa'] ?? json['tiketDewasa']),
      tiketAnak: parseTiket(json['tiket_anak'] ?? json['tiketAnak']),
      biayaAsuransi: json['biaya_asuransi']?.toString() ?? json['biayaAsuransi']?.toString() ?? '-',
      fasilitas: json['fasilitas'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      gambar: finalPathGambar,
      isLocalImage: isLokal,
    );
  }
}