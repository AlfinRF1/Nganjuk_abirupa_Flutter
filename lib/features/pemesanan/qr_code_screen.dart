import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QrCodeScreen extends StatelessWidget {
  final int totalHarga;
  final int idWisata;

  const QrCodeScreen({
    super.key,
    required this.totalHarga,
    required this.idWisata,
  });

  // Logika buat nentuin gambar QR Code berdasarkan ID Wisata
  String _getBarcodeImage(int idWisata) {
    switch (idWisata) {
      case 12:
        return 'assets/images/sedudo.jpeg'; // Pastikan file ini ada di folder assets
      case 13:
        return 'assets/images/tral.jpeg';
      case 14:
        return 'assets/images/goa.jpeg';
      case 15:
        return 'assets/images/sritanjung.jpeg';
      default:
        return 'assets/images/barcode_default.jpeg';
    }
  }

  // Fungsi buat balik ke halaman Riwayat (mirip FLAG_ACTIVITY_CLEAR_TOP di Java)
  void _goBackToRiwayat(BuildContext context) {
    // Kita arahin user balik ke Dashboard, dan hapus semua tumpukan layar sebelumnya
    // Nanti bisa sesuaikan rute '/dashboard' ini kalau beda namanya
    Navigator.pushNamedAndRemoveUntil(context, '/riwayat', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);

    return Scaffold(
      // Background gelap kayak di desain lu
      backgroundColor: const Color(0xFF222222),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- HEADER (Tombol Back & Judul) ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _goBackToRiwayat(context),
                        child: const Icon(Icons.arrow_back, color: Color(0xFF2E9FA6)),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Scan QR code",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "scan barcode untuk melakukan\npembayaran",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24), // Biar seimbang sama icon back
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- GAMBAR QR CODE ---
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        _getBarcodeImage(idWisata),
                        fit: BoxFit.contain,
                        // Kalo lu belum masukin gambarnya ke folder assets, pake icon default dulu:
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.qr_code_2,
                          size: 150,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- TOTAL HARGA (Kotak hijau muda) ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0F0EE), // Warna hijau muda pastel
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total :",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Rp. ${currencyFormat.format(totalHarga)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E9FA6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}