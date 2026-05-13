import 'package:flutter/material.dart';

class FilterRiwayatModal extends StatefulWidget {
  final Function(String?, String?) onApply; // Callback buat kirim hasil filter
  const FilterRiwayatModal({super.key, required this.onApply});

  @override
  _FilterRiwayatModalState createState() => _FilterRiwayatModalState();
}

class _FilterRiwayatModalState extends State<FilterRiwayatModal> {
  String? _selectedStatus;
  String? _selectedWisata;

  // 👇 FIX MUTLAK: Disesuaikan dengan nilai asli yang keluar dari database Laravel lu
  final List<String> _statusList = ['Lunas', 'Belum Lunas'];
  
  final List<String> _wisataList = [
    'Air Terjun Sedudo', 
    'Roro Kuning', 
    'Goa Margo Tresno', 
    'Sri Tanjung', 
    'Anjuk Ladang'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Filter Riwayat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              // Tombol praktis buat reset filter ke posisi semula (tampilkan semua)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedWisata = null;
                    _selectedStatus = null;
                  });
                },
                child: const Text("Reset", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          // --- DROPDOWN WISATA ---
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Pilih Wisata", 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            value: _selectedWisata,
            items: _wisataList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _selectedWisata = val),
          ),
          const SizedBox(height: 16),
          
          // --- DROPDOWN STATUS ---
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Status", 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            value: _selectedStatus,
            items: _statusList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _selectedStatus = val),
          ),
          
          const SizedBox(height: 24),
          
          // --- TOMBOL TERAPKAN ---
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E9FA6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Lempar string yang pas ke callback utama di riwayat_screen
                widget.onApply(_selectedWisata, _selectedStatus);
                Navigator.pop(context);
              },
              child: const Text("Terapkan Filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}