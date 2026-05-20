import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// 👇 FIX MUTLAK: Alamat import diganti pakai path absolut package aplikasi lu biar gak nyasar
import 'package:nganjukabirupa/features/pemesanan/qr_code_screen.dart'; 

class DetailRiwayatBottomSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  final String namaCustomer;

  const DetailRiwayatBottomSheet({
    super.key,
    required this.data,
    required this.namaCustomer,
  });

  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'lunas': 
        return Colors.green;
      case 'belum lunas': 
        return const Color.fromARGB(255, 255, 0, 0);
      default: 
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);

    String rawStatus = data['status'].toString().trim();
    String finalStatus = rawStatus; 

    String tglFormatted = "-";
    try {
      DateTime dt = DateTime.parse(data['tanggal'].toString());
      tglFormatted = DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      tglFormatted = data['tanggal'].toString();
    }

    String namaDariApi = data['nama_customer']?.toString().trim() ?? '';
    String namaTampil = namaDariApi.isNotEmpty ? namaDariApi : namaCustomer;

    double screenHeight = MediaQuery.of(context).size.height;
    final bool isBelumLunas = finalStatus.toLowerCase() == 'belum lunas';

    return Container(
      height: isBelumLunas ? screenHeight * 0.78 : screenHeight * 0.72, 
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // --- HANDLE ---
          Container(width: 50, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),

          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/logotextwarna.png', height: 40, fit: BoxFit.contain),
              const Text("Riwayat Pembelian", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 20),

          // --- KONTEN TENGAH (RESI CARD) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2EA4F0), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Nama Wisata", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(data['nama_wisata'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(data['lokasi'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const Divider(height: 24),
                
                _buildRowDetail("Nama", namaTampil),
                _buildRowDetail("ID Transaksi", "#TX${data['id_transaksi'] ?? data['id_pemesanan']}"),
                _buildRowDetail("Tanggal", tglFormatted),
                
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Status", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          // 👇 FIX DEPRECATED: Menggunakan .withValues() sesuai standard Flutter SDK baru lu
                          color: _getStatusColor(finalStatus).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _getStatusColor(finalStatus)),
                        ),
                        child: Text(finalStatus.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(finalStatus))),
                      ),
                    ],
                  ),
                ),
                _buildRowDetail("Metode", data['metode_pembayaran'] ?? '-'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("Rp. ${currencyFormat.format(data['total_harga'] ?? 0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          
          // --- TOMBOL BAYAR SEKARANG ---
          if (isBelumLunas) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrCodeScreen(
                        totalHarga: int.tryParse(data['total_harga'].toString()) ?? 0,
                        idWisata: int.tryParse(data['id_wisata'].toString()) ?? 0,
                        // 👇 SEKARANG LANGSUNG NODONG KEY id_pemesanan YANG FRESH DARI LARAVEL
                        idPemesanan: int.tryParse(data['id_pemesanan']?.toString() ?? '0') ?? 0,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.payment_rounded, color: Colors.white, size: 20),
                label: const Text(
                  "Bayar Sekarang (Buka QR)",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0BB5A7), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],

          const Spacer(),

          // --- FOOTER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/dispora_logo.png', height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text("Ketentuan :", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Text("- Tunjukkan tiket saat masuk", style: TextStyle(fontSize: 9)),
                  Text("- Tiket tidak dapat di-refund", style: TextStyle(fontSize: 9)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRowDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}