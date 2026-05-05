import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'detail_riwayat_bottomsheet.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  _RiwayatScreenState createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  List<dynamic> _riwayatList = [];
  List<dynamic> _filteredList = [];
  bool _isLoading = true;
  String _namaCustomer = "Pengguna";

  @override
  void initState() {
    super.initState();
    print("ALARM: initState berjalan!"); // Tambahin ini
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
  print("ALARM: _loadRiwayat dipanggil!");
  setState(() => _isLoading = true);
  
  try {
    final prefs = await SharedPreferences.getInstance();
    String idCustomer = prefs.getString("id_customer") ?? "";
    String token = prefs.getString("token") ?? ""; // WAJIB AMBIL TOKEN
    
    setState(() {
      _namaCustomer = prefs.getString("nama_customer") ?? "Pengguna";
    });
    
    if (idCustomer.isEmpty) {
      print("ALARM: ID Customer kosong!");
      setState(() => _isLoading = false);
      return;
    }

    // GANTI KE IP LAPTOP LU![cite: 4]
    var url = 'http://172.16.103.79:8000/api/riwayat?id_customer=$idCustomer';
    
    var response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token", // TEMPEL TOKEN DI SINI
      }
    );
    
    debugPrint("DEBUG RIWAYAT STATUS: ${response.statusCode}");
    debugPrint("DEBUG RIWAYAT BODY: ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> list = [];

      // Laravel lu nge-return langsung array [ ... ], bukan objek { status: success, data: [ ... ] }[cite: 5]
      // Jadi kita handle biar Flutter nggak bingung.
      if (data is List) {
        list = data; 
      } else if (data is Map && data['data'] != null) {
        list = data['data'];
      }

      // Sort data id terbesar di atas
      list.sort((a, b) {
        int idA = int.tryParse(a['id_transaksi'].toString()) ?? 0;
        int idB = int.tryParse(b['id_transaksi'].toString()) ?? 0;
        return idB.compareTo(idA);
      });

      setState(() {
        _riwayatList = list;
        _filteredList = list; // INI YANG MUNCULIN DATA KE LAYAR[cite: 4]
      });

      for (var item in list) {
        try {
          DateTime tglPesanan = DateTime.parse(item['tanggal'].toString());
          DateTime hariIni = DateTime.now();

          if (item['status'] == "Menunggu" && tglPesanan.isBefore(hariIni)) {
            item['status'] = "Selesai";
          }
        } catch(e) {
          // Abaikan kalau tanggalnya format aneh
        }
      }
      print("ALARM: Data berhasil dimuat: ${list.length} item");
    } else {
      print("ALARM: Server nolak. Status: ${response.statusCode}");
    }
  } catch (e) {
    print("ALARM: ERROR PARAH: $e");
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  void _filterData(String? wisata, String? status) {
    print("Filter: Wisata=$wisata, Status=$status");
    
    setState(() {
      _filteredList = _riwayatList.where((item) {
        // Ambil string dari item, pastiin jadi lowerCase
        String namaWisataItem = item['nama_wisata'].toString().toLowerCase();
        String statusItem = item['status'].toString().toLowerCase();

        // Bandingin pake lowerCase juga
        bool matchWisata = (wisata == null || namaWisataItem.contains(wisata.toLowerCase()));
        
        // PENTING: Bandingin status pake lowerCase
        // Di RiwayatScreen, fungsi _filterData
        bool matchStatus = (status == null || statusItem.toLowerCase() == status.toLowerCase());
        
        return matchWisata && matchStatus;
      }).toList();
    });
  }

  Widget _buildWisataImage(String namaWisata, String urlGambar) {
    debugPrint("DEBUG GAMBAR: Nama='$namaWisata', URL='$urlGambar'"); // Biar ketahuan isinya kosong atau nggak

    String lower = namaWisata.toLowerCase();
    String localAsset = '';
    
    // KALAU GAK ADA DI LOKAL, TARIK DARI SERVER LAPTOP LU
    // Pastikan path foldernya sesuai dengan struktur folder 'public' di Laravel lu
    String finalUrl = urlGambar.startsWith('http') 
        ? urlGambar 
        : 'http://172.16.103.79:8000/images/destinasi/$urlGambar'; // Ganti ke IP[cite: 4]
        
    return Image.network(
      finalUrl, 
      fit: BoxFit.cover, 
      errorBuilder: (c, e, s) {
        debugPrint("GAGAL LOAD GAMBAR DARI: $finalUrl"); // Lacak URL errornya
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF2E9FA6), Color(0xFF66BB6A)]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/logotextputih.png', width: 100),
                      const SizedBox(height: 8),
                      const Text("Riwayat Pesanan", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  // Ganti IconButton di dalam Header lu dengan ini:
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white, size: 28),
                    onPressed: () {
                      // 1. Ambil semua nama wisata dari riwayat
                      // 2. .toSet() buat ngilangin nama wisata yang double
                      // 3. .toList() buat balikin lagi jadi list
                      // Di dalam onPressed: () {...} IconButton filter:
                      List<String> wisataUnik = _riwayatList.map((e) => e['nama_wisata'].toString()).toSet().toList();
                      List<String> statusUnik = _riwayatList.map((e) => e['status'].toString()).toSet().toList();

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (c) => FilterModal(
                          onApply: _filterData,
                          daftarWisata: wisataUnik,
                          daftarStatus: statusUnik, // <--- Kirim status uniknya
                        ),
                      );
                    },
                  )
                ],              
                ),
              ),

            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredList.length,
                itemBuilder: (c, i) {
  var item = _filteredList[i];
  // Parsing Tanggal (biar gak nampilin DD/MM/YYYY lagi)
  String tglFormatted = "-";
  try {
    DateTime dt = DateTime.parse(item['tanggal'].toString());
    tglFormatted = DateFormat('dd/MM/yyyy').format(dt);
  } catch (e) { tglFormatted = item['tanggal'].toString(); }

  return GestureDetector(
    onTap: () => showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent, 
      builder: (c) => DetailRiwayatBottomSheet(data: item, namaCustomer: _namaCustomer)
    ),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Wisata
          ClipRRect(
            borderRadius: BorderRadius.circular(8), 
            child: SizedBox(width: 100, height: 100, child: _buildWisataImage(item['nama_wisata'], item['gambar'] ?? ''))
          ),
          const SizedBox(width: 12),
          // Info Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(), // Spacer
                    Text(tglFormatted, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(item['nama_wisata'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(item['lokasi'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "Total 1 tiket : Rp.${currencyFormat.format(item['total_harga'])}", 
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)
                    ),
                    ),
                    ],
                    ),
                    ),
                    ],
                  ),
                ),
              );
            },
            ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterModal extends StatefulWidget {
  final List<String> daftarWisata;
  final List<String> daftarStatus; // <--- Tambahin ini
  final Function(String?, String?) onApply;
  
  const FilterModal({
    super.key, 
    required this.onApply, 
    required this.daftarWisata,
    required this.daftarStatus, // <--- Tambahin ini
  });
  
  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String? _status, _wisata;
  
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text("Filter Data", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      
      // Dropdown Wisata
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: "Wisata"), 
        items: widget.daftarWisata.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
        onChanged: (v) => _wisata = v
      ),
      
      // Dropdown Status DYNAMIC
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: "Status"), 
        items: widget.daftarStatus.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
        onChanged: (v) => _status = v
      ),
      
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () { widget.onApply(_wisata, _status); Navigator.pop(context); }, 
        child: const Text("Terapkan")
      )
    ]));
  }
}