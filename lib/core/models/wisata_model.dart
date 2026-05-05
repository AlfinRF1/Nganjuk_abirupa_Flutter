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
  });

  factory WisataModel.fromJson(Map<String, dynamic> json) {
    // Fungsi parsing tiket (aman dari error String/Int)
    int parseTiket(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return WisataModel(
      idWisata: json['id_wisata']?.toString() ?? json['idWisata']?.toString() ?? '',
      namaWisata: json['nama_wisata'] ?? json['namaWisata'] ?? '',
      lokasi: json['lokasi'] ?? '',
      tiketDewasa: parseTiket(json['tiket_dewasa'] ?? json['tiketDewasa']),
      tiketAnak: parseTiket(json['tiket_anak'] ?? json['tiketAnak']),
      biayaAsuransi: json['biaya_asuransi']?.toString() ?? json['biayaAsuransi']?.toString() ?? '-',
      fasilitas: json['fasilitas'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      // Karena Laravel udah ngirim URL lengkap (http://...), kita tinggal panggil aja
      gambar: json['gambar'] ?? '', 
    );
  }
}