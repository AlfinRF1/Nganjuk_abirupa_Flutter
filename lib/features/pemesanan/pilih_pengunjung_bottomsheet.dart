import 'package:flutter/material.dart';

class PilihPengunjungBottomSheet extends StatefulWidget {
  final int initialDewasa;
  final int initialAnak;
  final Function(int dewasa, int anak) onSimpan;

  const PilihPengunjungBottomSheet({
    super.key,
    required this.initialDewasa,
    required this.initialAnak,
    required this.onSimpan,
  });

  @override
  _PilihPengunjungBottomSheetState createState() => _PilihPengunjungBottomSheetState();
}

class _PilihPengunjungBottomSheetState extends State<PilihPengunjungBottomSheet> {
  late int countDewasa;
  late int countAnak;

  @override
  void initState() {
    super.initState();
    countDewasa = widget.initialDewasa;
    countAnak = widget.initialAnak;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF2E9FA6)),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  "Pilih Pengunjung",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 48), // Balancing spacer
            ],
          ),
          const SizedBox(height: 24),

          // Item Dewasa
          _buildCounterRow(
            title: "Dewasa",
            subtitle: "10 tahun ke atas",
            count: countDewasa,
            onMin: () {
              if (countDewasa > 0) setState(() => countDewasa--);
            },
            onPlus: () => setState(() => countDewasa++),
          ),
          const Divider(height: 32),

          // Item Anak
          _buildCounterRow(
            title: "Anak Anak",
            subtitle: "Anak dibawah 10 tahun",
            count: countAnak,
            onMin: () {
              if (countAnak > 0) setState(() => countAnak--);
            },
            onPlus: () => setState(() => countAnak++),
          ),
          const SizedBox(height: 32),

          // Info Box (Sesuai gambar lu)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.info_outline, color: Color(0xFF2E9FA6), size: 20),
                    SizedBox(width: 8),
                    Text("Ketentuan Pemesanan Tiket", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem("Validitas Tiket: Hanya berlaku untuk tanggal kunjungan yang dipilih."),
                _buildInfoItem("Pembatalan: Tiket yang sudah dibeli tidak dapat dibatalkan, diubah tanggal, atau diuangkan kembali (non-refundable)."),
                _buildInfoItem("Usia Pengunjung:\n• Dewasa: 10 tahun ke atas.\n• Anak-anak: di bawah 10 tahun."),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E9FA6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (countDewasa == 0 && countAnak == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Minimal pilih 1 pengunjung")),
                  );
                  return;
                }
                widget.onSimpan(countDewasa, countAnak);
                Navigator.pop(context);
              },
              child: const Text("Simpan", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow({required String title, required String subtitle, required int count, required VoidCallback onMin, required VoidCallback onPlus}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
              onPressed: onMin,
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(count.toString().padLeft(2, '0'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF2E9FA6)),
              onPressed: onPlus,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 14)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
        ],
      ),
    );
  }
}