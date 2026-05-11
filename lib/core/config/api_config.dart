class ApiConfig {
  // 1. BASE URL (Tetap simpen di sini buat patokan utama)
  static const String baseUrl = "https://nganjukabirupa.pbltifnganjuk.com/api";

  // 2. JALUR GAMBAR (Penting! Karena folder destinasi & event jadi satu di sini)
  static const String imgUrl = "https://nganjukabirupa.pbltifnganjuk.com/images/destinasi";

  // 3. ENDPOINT KHUSUS DETAIL WISATA
  static String detailWisata(String id) => "$baseUrl/wisata/$id";
}