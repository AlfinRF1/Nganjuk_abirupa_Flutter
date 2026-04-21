import 'package:flutter/material.dart';

class FilterRiwayatModal extends StatefulWidget {
  final Function(String?, String?) onApply; // callback buat kirim hasil filter
  const FilterRiwayatModal({super.key, required this.onApply});

  @override
  _FilterRiwayatModalState createState() => _FilterRiwayatModalState();
}

class _FilterRiwayatModalState extends State<FilterRiwayatModal> {
  String? _selectedStatus;
  String? _selectedWisata;

  final List<String> _statusList = ['Berhasil', 'Menunggu'];
  final List<String> _wisataList = ['Air Terjun Sedudo', 'Roro Kuning', 'Goa Margo Tresno', 'Sri Tanjung', 'Anjuk Ladang'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Filter Riwayat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          
          // Dropdown Wisata
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: "Pilih Wisata", border: OutlineInputBorder()),
            initialValue: _selectedWisata,
            items: _wisataList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _selectedWisata = val),
          ),
          const SizedBox(height: 16),
          
          // Dropdown Status
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: "Status", border: OutlineInputBorder()),
            initialValue: _selectedStatus,
            items: _statusList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _selectedStatus = val),
          ),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E9FA6)),
              onPressed: () {
                widget.onApply(_selectedWisata, _selectedStatus);
                Navigator.pop(context);
              },
              child: const Text("Terapkan Filter", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}