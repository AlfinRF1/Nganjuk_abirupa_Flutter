import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QrCodeScreen extends StatelessWidget {
  final int totalHarga;
  final int idWisata;
  final int idPemesanan; // <--- WAJIB TAMBAHIN INI BIAR BISA DIHAPUS

  const QrCodeScreen({
    super.key,
    required this.totalHarga,
    required this.idWisata,
    required this.idPemesanan, // <--- WAJIB TAMBAHIN INI
  });

  // --- LOGIKA QR CODE SESUAI DATABASE ASLI LU ---
  String _getBarcodeImage(int idWisata) {
    switch (idWisata) {
      case 12:
        return 'assets/images/sedudo.jpeg';
      case 14:
        return 'assets/images/goa.jpeg';
      case 15:
        // Sri Tanjung dibalikin lagi gambarnya
        return 'assets/images/sri_tanjung.png';
      case 16:
        return 'assets/images/tral.jpeg';
      default:
        return 'assets/images/barcode_default.jpeg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );
    String targetAsset = _getBarcodeImage(idWisata);

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
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF2E9FA6),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Pembayaran Tiket",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              idWisata == 15
                                  ? "Konfirmasi pesanan Anda"
                                  : "scan barcode untuk melakukan\npembayaran",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- KOTAK QR CODE ATAU INFO PENGGANTI ---
                  if (idWisata != 15) ...[
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          targetAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.qr_code_2,
                                    size: 80,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "GAGAL MEMUAT ASSET:",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  Text(
                                    "$targetAsset\n(ID diterima: $idWisata)",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    // --- TAMPILAN PENGGANTI KHUSUS SRI TANJUNG (ID 15) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 50,
                            color: Color(0xFF2E9FA6),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Wisata ini tidak menggunakan\npembayaran via QR Code.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // --- TOTAL HARGA ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0F0EE),
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
                  const SizedBox(height: 24),

                  // --- TOMBOL KONFIRMASI ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/riwayat',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E9FA6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Konfirmasi Pembayaran",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- TOMBOL BATAL DENGAN API PENGHAPUS OTOMATIS ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () async {
                        try {
                          // 1. Munculkan indikator loading biar user gak nge-klik berkali-kali
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (c) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          // 2. Ambil token aman dari memori
                          final prefs = await SharedPreferences.getInstance();
                          String token = prefs.getString("token") ?? "";

                          // 3. Tembak API Batal/Hapus ke server Hostinger
                          var response = await http.post(
                            Uri.parse(
                              'https://nganjukabirupa.pbltifnganjuk.com/api/pemesanan/batal',
                            ), // URL valid sesuai file server
                            headers: {
                              'Accept': 'application/json',
                              'Authorization': 'Bearer $token',
                            },
                            body: {'id_pemesanan': idPemesanan.toString()},
                          );

                          // Tutup dialog loading
                          if (context.mounted) Navigator.pop(context);

                          var res = jsonDecode(response.body);

                          if (res['status'] == 'success') {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Pesanan berhasil dibatalkan"),
                                ),
                              );
                              // Tutup layar QR Code dan kembali ke form
                              Navigator.pop(context);
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Gagal membatalkan: ${res['message']}",
                                  ),
                                ),
                              );
                              Navigator.pop(context); // Tetap tutup layarnya
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context); // Tutup loading jika error
                            Navigator.pop(context); // Tutup layar QR
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Batalkan",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
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
