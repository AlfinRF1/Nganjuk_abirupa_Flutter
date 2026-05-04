import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailRiwayatBottomSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  final String namaCustomer;

  const DetailRiwayatBottomSheet({
    super.key,
    required this.data,
    required this.namaCustomer,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai': return Colors.green;
      case 'menunggu': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);

    String rawStatus = data['status'].toString();
    String finalStatus = rawStatus; 

    String tglFormatted = "-";
    try {
      DateTime dt = DateTime.parse(data['tanggal'].toString());
      tglFormatted = DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      tglFormatted = data['tanggal'].toString();
    }

    // 1. AMBIL TINGGI LAYAR HP
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      // 2. KITA SET TINGGINYA 75% DARI LAYAR (Biar langsung ngebuka tinggi!)
      height: screenHeight * 0.75, 
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // --- HANDLE ---
          Container(width: 50, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),

          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/logotextwarna.png', height: 40, fit: BoxFit.contain),
              const Text("Riwayat Pembelian", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 24),

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
                Text(data['nama_wisata'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(data['lokasi'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const Divider(height: 24),
                
                _buildRowDetail("Nama", namaCustomer),
                _buildRowDetail("ID Transaksi", "#TX${data['id_transaksi']}"),
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
                          color: _getStatusColor(finalStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _getStatusColor(finalStatus)),
                        ),
                        child: Text(finalStatus.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(finalStatus))),
                      ),
                    ],
                  ),
                ),
                _buildRowDetail("Metode", data['metode_pembayaran']),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("Rp. ${currencyFormat.format(data['total_harga'])}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          
          // 3. PENDORONG AJAIB (SPACER)
          // Ini bakal ngisi sisa ruang kosong di tengah dan ngedorong footer ke bawah!
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