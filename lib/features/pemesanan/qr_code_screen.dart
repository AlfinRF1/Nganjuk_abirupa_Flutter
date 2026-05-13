import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QrCodeScreen extends StatefulWidget {
  final int totalHarga;
  final int idWisata;
  final int idPemesanan;

  const QrCodeScreen({
    super.key,
    required this.totalHarga,
    required this.idWisata,
    required this.idPemesanan,
  });

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  bool _isLoading = false;

  // --- LOGIKA ASSET QR CODE ---
  String _getBarcodeImage(int idWisata) {
    switch (idWisata) {
      case 12:
        return 'assets/images/sedudo.jpeg';
      case 13:
        // Roro Kuning diarahkan ke default karena QRIS belum tersedia
        return 'assets/images/barcode_default.jpeg';
      case 14:
        return 'assets/images/goa.jpeg';
      case 15:
        return 'assets/images/sri_tanjung.png';
      case 16:
        return 'assets/images/tral.jpeg';
      default:
        return 'assets/images/barcode_default.jpeg';
    }
  }

  // --- FUNGSI UPDATE STATUS PEMBAYARAN KE SERVER ---
  Future<void> _konfirmasiPembayaran() async {
    // 1. Validasi awal: Cegah eksekusi jika ID Pemesanan bernilai 0 / tidak valid
    if (widget.idPemesanan == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pemesanan tidak valid (ID: 0). Silakan kembali dan ulangi proses pesanan."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token") ?? "";

      // Tembak API Laravel untuk mengubah status database menjadi 'Lunas'
      final response = await http.post(
        Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/api/pemesanan/lunas'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'id_pemesanan': widget.idPemesanan.toString(),
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // 👇 PERBAIKAN LOGIKA: Hanya lakukan navigasi jika server sukses merespons 200 OK
        if (response.statusCode == 200) {
          debugPrint("Status sukses diubah menjadi Lunas di Database!");
          
          // Berikan jeda sejenak agar proses commit di database server tuntas sepenuhnya
          await Future.delayed(const Duration(milliseconds: 600));

          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/riwayat',
              (route) => false,
            );
          }
        } else {
          // Tampilkan error aktual dari server ke layar jika proses gagal (Mencegah navigasi paksa)
          debugPrint("Gagal update status: Code ${response.statusCode} -> ${response.body}");
          
          String pesanError = "Gagal memproses konfirmasi (Status: ${response.statusCode}).";
          try {
            final responJson = jsonDecode(response.body);
            if (responJson['message'] != null) {
              pesanError = responJson['message'];
            }
          } catch (_) {}

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Sistem Server: $pesanError"),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi gangguan koneksi: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );
    
    String targetAsset = _getBarcodeImage(widget.idWisata);
    final bool isWithoutQrCode = (widget.idWisata == 15 || widget.idWisata == 13);

    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      body: Stack(
        children: [
          Center(
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
                                  isWithoutQrCode
                                      ? "Informasi Metode Pembayaran"
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

                      // --- RENDER QR CODE ATAU INFO BOX EKSKLUSIF ---
                      if (!isWithoutQrCode) ...[
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
                                        "$targetAsset\n(ID diterima: ${widget.idWisata})",
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
                        // --- TAMPILAN PENGGANTI KHUSUS TANPA QRIS ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FBFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD0F0EE), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.qr_code_scanner,
                                size: 48,
                                color: Color(0xFF2E9FA6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.idWisata == 13
                                    ? "Pembayaran QRIS Belum Tersedia"
                                    : "Wisata Tanpa Pembayaran QRIS",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.idWisata == 13
                                    ? "Metode pembayaran via QRIS untuk destinasi ini sedang dalam tahap pengembangan.\n\nSilakan tunjukkan detail pesanan ini dan lakukan pembayaran langsung di loket tiket."
                                    : "Wisata ini tidak menggunakan sistem pembayaran QR Code.\n\nSilakan selesaikan transaksi secara tunai di loket tiket masuk.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12.5,
                                  height: 1.4,
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
                              "Rp. ${currencyFormat.format(widget.totalHarga)}",
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

                      // --- TOMBOL KONFIRMASI PEMBAYARAN ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _konfirmasiPembayaran,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E9FA6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isWithoutQrCode 
                                ? "Selesai & Lihat Riwayat" 
                                : "Konfirmasi Pembayaran",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // --- TOMBOL BATAL PESANAN ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () async {
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (c) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              final prefs = await SharedPreferences.getInstance();
                              String token = prefs.getString("token") ?? "";

                              var response = await http.post(
                                Uri.parse(
                                  'https://nganjukabirupa.pbltifnganjuk.com/api/pemesanan/batal',
                                ),
                                headers: {
                                  'Accept': 'application/json',
                                  'Authorization': 'Bearer $token',
                                },
                                body: {'id_pemesanan': widget.idPemesanan.toString()},
                              );

                              if (context.mounted) Navigator.pop(context);

                              var res = jsonDecode(response.body);

                              if (res['status'] == 'success') {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Pesanan berhasil dibatalkan"),
                                    ),
                                  );
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
                                  Navigator.pop(context);
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                Navigator.pop(context);
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

          // --- OVERLAY LOADING ---
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E9FA6)),
              ),
            ),
        ],
      ),
    );
  }
}