// 1. Model untuk Galeri/Event
class EventModel {
  final String gambarPoster;
  final String tglMulai;
  final String tglSelesai;

  EventModel({
    required this.gambarPoster,
    required this.tglMulai,
    required this.tglSelesai,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      gambarPoster: json['gambar_poster'] ?? '',
      tglMulai: json['tgl_mulai'] ?? '',
      tglSelesai: json['tgl_selesai'] ?? '',
    );
  }
}

// 2. TAMBAHKAN MODEL UNTUK REVIEWS (Biar sinkron sama tabel ulasan_wisata)
class ReviewModel {
  final String namaCustomer;
  final String ulasan;
  final String tanggal;
  final String foto;

  ReviewModel({
    required this.namaCustomer,
    required this.ulasan,
    required this.tanggal,
    required this.foto,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Ambil data dari relasi customer yang kita buat di Laravel
    var customer = json['customer'] ?? {};
    return ReviewModel(
      namaCustomer: customer['nama_customer'] ?? 'Anonim',
      ulasan: json['ulasan'] ?? '',
      tanggal: json['tanggal'] ?? '-',
      foto: customer['foto'] ?? '',
    );
  }
}

// 3. Update WisataModel utama
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
  final List<EventModel> events;
  final List<ReviewModel> reviews; // <--- TAMBAHKAN INI

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
    required this.events,
    required this.reviews, // <--- TAMBAHKAN INI[cite: 5]
  });

  factory WisataModel.fromJson(Map<String, dynamic> json) {
    int parseTiket(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return WisataModel(
      idWisata: json['id_wisata']?.toString() ?? '',
      namaWisata: json['nama_wisata'] ?? '',
      lokasi: json['lokasi'] ?? '',
      tiketDewasa: parseTiket(json['tiket_dewasa']),
      tiketAnak: parseTiket(json['tiket_anak']),
      biayaAsuransi: json['biaya_asuransi']?.toString() ?? '-',
      fasilitas: json['fasilitas'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      gambar: json['gambar'] ?? '',
      
      // PARSING DATA GALERI[cite: 5]
      events: (json['galeri'] as List? ?? [])
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
          
      // PARSING DATA ULASAN (Mapping dari key 'ulasan' di JSON Laravel)[cite: 5]
      reviews: (json['ulasan'] as List? ?? [])
          .map((r) => ReviewModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}