import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nganjukabirupa/core/models/wisata_model.dart';
import 'package:nganjukabirupa/features/pemesanan/pemesanan_screen.dart';
import 'tambah_review_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 1. BERUBAH JADI STATEFUL WIDGET
class DetailWisataScreen extends StatefulWidget {
  final WisataModel wisata;
  const DetailWisataScreen({super.key, required this.wisata});

  @override
  State<DetailWisataScreen> createState() => _DetailWisataScreenState();
}

class _DetailWisataScreenState extends State<DetailWisataScreen> {
  String namaUserLogin = "Pengguna";
  List<dynamic> _listReviews = []; // Sudah dikosongkan karena nanti diisi API

bool _isLoading = true;
late WisataModel _detailWisata;

  @override
void initState() {
  super.initState();
  _detailWisata = widget.wisata; // Isi awal pakai data dari Beranda dulu
  _ambilDataUser();
  _fetchDetailWisata(); // <--- Panggil fungsi fetch detail
  _fetchReviews();
}

Future<void> _fetchDetailWisata() async {
  try {
    // 1. GANTI IP KE IP LAPTOP LU (Contoh: 192.168.1.15)
    final String ipLaptop = "172.16.103.79"; 
    
    final response = await http.get(Uri.parse(
        'http://$ipLaptop:8000/api/wisata/${widget.wisata.idWisata}'));
    
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['status'] == 'success') {
        setState(() {
          // Mapping data ke model yang baru (yang ada List<EventModel>)[cite: 5, 6]
          _detailWisata = WisataModel.fromJson(res['data']);
          _isLoading = false;
        });
      }
    }
  } catch (e) {
    debugPrint("Koneksi Error: $e");
    setState(() => _isLoading = false);
  }
}

  Future<void> _ambilDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      namaUserLogin = prefs.getString("nama_customer") ?? "Pengguna";
    });
  }

  Future<void> _fetchReviews() async {
  try {
    var response = await http.get(
      Uri.parse('http://172.16.103.79:8000/api/wisata/${widget.wisata.idWisata}'),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      
      // Masuk ke dalam 'data' dulu
      var dataUtama = res['data'] ?? {};
      
      setState(() {
        // Langsung hajar masukin ke variabel, gak perlu pakai .cast() lagi
        _listReviews = dataUtama['ulasan'] ?? []; 
      });
      
      debugPrint("JUMLAH REVIEW DITEMUKAN: ${_listReviews.length}");
    }
  } catch (e) {
    debugPrint("ERROR REFRESH REVIEWS: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0BB5A7);
    const Color bgColor = Colors.white;
    const Color cardColor = Color(0xFFF4F7F9); 
    const Color textColor = Color(0xFF4e4e4e);

    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        backgroundColor: bgColor,
        
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: ElevatedButton(
            onPressed: () {
              // UDAH DISESUAIKAN 100% SAMA WISATAMODEL
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PemesananScreen(
                    // idWisata bentuknya String, kita convert ke int
                    idWisata: int.tryParse(widget.wisata.idWisata) ?? 0, 
                    
                    // tiketDewasa & tiketAnak udah int dari sananya, jadi langsung gas
                    hargaDewasa: widget.wisata.tiketDewasa, 
                    hargaAnak: widget.wisata.tiketAnak,     
                    
                    // biayaAsuransi bentuknya String, kita convert ke int juga
                    tarifAsuransi: int.tryParse(widget.wisata.biayaAsuransi) ?? 1000, 
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text(
              "Pesan sekarang",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 16, bottom: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: primaryColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Container(
                height: 240, // Pakai yang udah digedein tadi
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildHeaderImage(),
                ),
              ),

              const SizedBox(height: 16),

              const TabBar(
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: "ABOUT"),
                  Tab(text: "EVENT"),
                  Tab(text: "REVIEWS"),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildAboutTab(cardColor, textColor),
                    _buildEventTab(),
                    _buildReviewsTab(context, cardColor, textColor), 
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab(Color cardColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(cardColor, textColor, Icons.location_on_outlined, widget.wisata.namaWisata, widget.wisata.lokasi),
        const SizedBox(height: 12),
        _buildInfoCard(cardColor, textColor, Icons.description_outlined, "Deskripsi", widget.wisata.deskripsi),
        const SizedBox(height: 12),
        _buildInfoCard(cardColor, textColor, Icons.local_activity_outlined, "Tiket Masuk", "Dewasa\t\t\t\t\t\t: Rp ${widget.wisata.tiketDewasa}\nAnak-anak <10th\t: Rp ${widget.wisata.tiketAnak}"),
        const SizedBox(height: 12),
        _buildInfoCard(cardColor, textColor, Icons.domain_verification_outlined, "Fasilitas", widget.wisata.fasilitas),
      ],
    );
  }

  Widget _buildEventTab() {
  // Pakai _detailWisata yang datanya baru saja kita ambil dari API Detail
  if (_detailWisata.events.isEmpty) {
    return const Center(
      child: Text("Belum ada event di wisata ini.", style: TextStyle(color: Colors.grey)),
    );
  }

  return ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: _detailWisata.events.length,
  itemBuilder: (context, index) {
    final event = _detailWisata.events[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Biar teks rata kiri
        children: [
          // GAMBAR POSTER (Sudah diperbaiki agar tidak kepotong)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: CachedNetworkImage(
              imageUrl: event.gambarPoster,
              width: double.infinity,
              // Hapus 'height: 180' agar mengikuti panjang asli gambar
              fit: BoxFit.fitWidth, // Menyesuaikan lebar tanpa memotong tinggi
              placeholder: (context, url) => Container(
                height: 200, // Tinggi sementara saat loading
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator(color: Color(0xFF0BB5A7))),
              ),
              errorWidget: (context, url, error) => Container(
                height: 150,
                color: Colors.grey[100],
                child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
              ),
            ),
          ),
          
          // INFO TANGGAL EVENT
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF0BB5A7)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Event: ${event.tglMulai} s/d ${event.tglSelesai}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF4e4e4e),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
);
}

  // --- 3. LOGIKA TAMBAH REVIEW OTOMATIS ---
  Widget _buildReviewsTab(BuildContext context, Color cardColor, Color textColor) { 
  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // TOMBOL TULIS REVIEW
      InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () async {
          final hasilReview = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahReviewScreen()),
          );

          if (hasilReview != null && hasilReview.toString().isNotEmpty) {
            // 1. TAMPILIN LOADING DIALOG
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(color: Color(0xFF0BB5A7)),
              ),
            );

            try {
              final prefs = await SharedPreferences.getInstance();
              String idCustomer = prefs.getString("id_customer") ?? "0";

              // 2. PINDAH KE URL LARAVEL LOKAL
              var response = await http.post(
                Uri.parse('http://172.16.103.79:8000/api/ulasan'), // Sesuaikan route di Laravel
                headers: {
                  "Content-Type": "application/json",
                  "Accept": "application/json",
                },
                body: jsonEncode({
                  "id_wisata": widget.wisata.idWisata,
                  "id_customer": idCustomer,
                  "ulasan": hasilReview // Sesuai nama kolom di DB lu
                }),
              );

              if (mounted) Navigator.pop(context); // NUTUP LOADING

              if (response.statusCode == 200 || response.statusCode == 201) {
                await _fetchReviews(); // Refresh data ulasan
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review berhasil diposting!'), backgroundColor: Colors.green),
                  );
                }
              } else {
                debugPrint("Gagal posting review: ${response.body}");
              }
            } catch (e) {
              if (mounted) Navigator.pop(context); // NUTUP LOADING JIKA ERROR
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal terhubung ke server: $e'), backgroundColor: Colors.red),
                );
              }
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(25), 
            border: Border.all(color: Colors.grey.shade300)
          ),
          child: const Text("Tulis Review di sini", style: TextStyle(color: Colors.grey)),
        ),
      ),
      const SizedBox(height: 16),

      ..._listReviews.map((review) {
  // 1. Definisikan dataReview dengan tipe yang jelas agar operator [] bisa dipakai
  final Map<String, dynamic> dataReview = review as Map<String, dynamic>; 
  
  // 2. Ambil data customer, casting juga sebagai Map
  final Map<String, dynamic> customer = (dataReview["customer"] ?? {}) as Map<String, dynamic>;
  
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: _buildReviewCard(
      cardColor, 
      textColor, 
      customer["nama_customer"]?.toString() ?? "Anonim",
      dataReview["tanggal"]?.toString() ?? "-",
      dataReview["ulasan"]?.toString() ?? "",
      customer["foto"]?.toString() ?? ""
    ),
  );
}).toList(),
    ],
  );
}


  Widget _buildInfoCard(Color bgColor, Color textColor, IconData icon, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor))),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26), 
            child: Text(content, style: TextStyle(fontSize: 12, color: textColor, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Color bgColor, Color textColor, String name, String date, String review, String avatarUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade300,
          // Kalau string gak kosong, load gambarnya. Kalau kosong, null (gak load gambar)
          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          // Kalau string kosong, tampilin icon orang warna abu-abu
          child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 20, color: Colors.grey) : null,
        ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(review, style: TextStyle(fontSize: 12, color: textColor, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
  // Cek kalau gambar kosong dari API
  if (widget.wisata.gambar.isEmpty) {
    return Container(
      color: Colors.grey[300], 
      child: const Icon(Icons.image_not_supported, size: 50)
    );
  }

  // Langsung pakai CachedNetworkImage untuk semua wisata
  return CachedNetworkImage(
    imageUrl: widget.wisata.gambar, 
    fit: BoxFit.cover, 
    width: double.infinity, 
    height: double.infinity,
    // Biar gak cuma abu-abu doang, kita kasih loading spinner pas gambar lagi didownload
    placeholder: (context, url) => Container(
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    ),
    // Tampilan kalau link gambarnya mati atau koneksi error
    errorWidget: (context, url, error) => Container(
      color: Colors.grey[300], 
      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey)
    ),
  );
}
}