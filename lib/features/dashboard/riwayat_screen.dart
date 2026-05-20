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
    debugPrint("ALARM: initState Riwayat Berjalan!");
    _loadRiwayat();
  }

  // 👇 JURUS PENGAMAN: Pemicu refresh otomatis pas user buka via geser layar PageView
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRiwayat(); // Otomatis nembak API biar status 'Lunas' langsung ke-render tanpa delay!
  }

  Future<void> _loadRiwayat() async {
    if (!mounted) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String idCustomer = prefs.getString("id_customer") ?? "";
      String token = prefs.getString("token") ?? ""; 
      
      if (mounted) {
        setState(() {
          _namaCustomer = prefs.getString("nama_customer") ?? "Pengguna";
        });
      }
      
      if (idCustomer.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      var url = 'https://nganjukabirupa.pbltifnganjuk.com/api/riwayat?id_customer=$idCustomer';
      
      final response = await http.get(
        Uri.parse(url), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', 
          'Authorization': 'Bearer $token', 
        },
      );
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> list = [];

        if (data is List) {
          list = data; 
        } else if (data is Map && data['data'] != null) {
          list = data['data'];
        }

        // Urutkan ID Transaksi paling gede di posisi paling atas
        list.sort((a, b) {
          int idA = int.tryParse(a['id_transaksi'].toString()) ?? 0;
          int idB = int.tryParse(b['id_transaksi'].toString()) ?? 0;
          return idB.compareTo(idA);
        });

        for (var item in list) {
          try {
            DateTime tglPesanan = DateTime.parse(item['tanggal'].toString());
            DateTime hariIni = DateTime.now();

            if (item['status'] == "Menunggu" && tglPesanan.isBefore(hariIni)) {
              item['status'] = "Selesai";
            }
          } catch(_) {}
        }

        if (mounted) {
          setState(() {
            _riwayatList = list;
            _filteredList = list; 
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("ALARM ERROR RIWAYAT: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterData(String? wisata, String? status) {
    setState(() {
      _filteredList = _riwayatList.where((item) {
        String namaWisataItem = item['nama_wisata'].toString().toLowerCase();
        String statusItem = item['status'].toString().toLowerCase();

        bool matchWisata = (wisata == null || namaWisataItem.contains(wisata.toLowerCase()));
        bool matchStatus = (status == null || statusItem == status.toLowerCase());
        
        return matchWisata && matchStatus;
      }).toList();
    });
  }

  Widget _buildWisataImage(String namaWisata, String urlGambar) {
    String finalUrl = urlGambar.startsWith('http') 
        ? urlGambar 
        : 'https://nganjukabirupa.pbltifnganjuk.com/images/destinasi/$urlGambar';
        
    return Image.network(
      finalUrl, 
      fit: BoxFit.cover, 
      errorBuilder: (c, e, s) {
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
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white, size: 28),
                    onPressed: () {
                      List<String> wisataUnik = _riwayatList.map((e) => e['nama_wisata'].toString()).toSet().toList();
                      List<String> statusUnik = _riwayatList.map((e) => e['status'].toString()).toSet().toList();

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (c) => FilterModal(
                          onApply: _filterData,
                          daftarWisata: wisataUnik,
                          daftarStatus: statusUnik, 
                        ),
                      );
                    },
                  )
                ],              
              ),
            ),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E9FA6))) 
                : RefreshIndicator(
                    onRefresh: _loadRiwayat, 
                    color: const Color(0xFF2E9FA6),
                    child: _filteredList.isEmpty
                        ? const Center(child: Text("Tidak ada data riwayat pesanan.", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredList.length,
                            physics: const AlwaysScrollableScrollPhysics(), 
                            itemBuilder: (c, i) {
                              var item = _filteredList[i];
                              String tglFormatted = "-";
                              try {
                                DateTime dt = DateTime.parse(item['tanggal'].toString());
                                tglFormatted = DateFormat('dd/MM/yyyy').format(dt);
                              } catch (_) { tglFormatted = item['tanggal'].toString(); }

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
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8), 
                                        child: SizedBox(width: 100, height: 100, child: _buildWisataImage(item['nama_wisata'], item['gambar'] ?? ''))
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const SizedBox(), 
                                                Text(tglFormatted, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            Text(item['nama_wisata'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            Text(item['lokasi'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                            const SizedBox(height: 20),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                "Total : Rp.${currencyFormat.format(item['total_harga'])}", 
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
            ),
          ],
        ),
      ),
    );
  }
}

class FilterModal extends StatefulWidget {
  final List<String> daftarWisata;
  final List<String> daftarStatus; 
  final Function(String?, String?) onApply;
  
  const FilterModal({
    super.key, 
    required this.onApply, 
    required this.daftarWisata,
    required this.daftarStatus, 
  });
  
  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String? _status, _wisata;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24), 
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          const Text("Filter Data", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: "Wisata"), 
            items: widget.daftarWisata.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
            onChanged: (v) => _wisata = v
          ),
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
        ]
      )
    );
  }
}