class GoogleLoginRequest {
  final String namaCustomer;
  final String emailCustomer;
  final String? foto; // Boleh null

  GoogleLoginRequest({
    required this.namaCustomer,
    required this.emailCustomer,
    this.foto,
  });

  // Fungsi buat diubah jadi JSON saat dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      "nama_customer": namaCustomer,
      "email_customer": emailCustomer,
      "foto": foto ?? "", // Kalau null kirim string kosong
    };
  }
}