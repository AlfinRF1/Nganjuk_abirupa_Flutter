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
        return 'assets/images/sedudo.jpeg'; 
      case 13:
        return 'assets/images/tral.jpeg';
      case 14:
        return 'assets/images/goa.jpeg';
      default:
        return 'assets/images/barcode_default.jpeg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);

    return Scaffold(
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
                  // --- HEADER ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context), // Balik ke halaman sebelumnya
                        child: const Icon(Icons.arrow_back, color: Color(0xFF2E9FA6)),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Scan QR code",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "scan barcode untuk melakukan\npembayaran",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
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
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.qr_code_2,
                          size: 150,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- TOTAL HARGA ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0F0EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          "Rp. ${currencyFormat.format(totalHarga)}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E9FA6)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- TOMBOL KONFIRMASI ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigasi ke halaman Riwayat & hapus stack sebelumnya
                        Navigator.pushNamedAndRemoveUntil(context, '/riwayat', (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E9FA6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Konfirmasi Pembayaran",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- TOMBOL BATAL ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        // Balik ke halaman pemesanan sebelumnya
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Batalkan",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
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