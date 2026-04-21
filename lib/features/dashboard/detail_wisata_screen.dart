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
  List<Map<String, String>> _listReviews = []; // Sudah dikosongkan karena nanti diisi API

  @override
  void initState() {
    super.initState();
    _ambilDataUser();
    _fetchReviews();
  }

  Future<void> _ambilDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      namaUserLogin = prefs.getString("nama_customer") ?? "Pengguna";
    });
  }

  Future<void> _fetchReviews() async {
    try {
      final response = await http.get(Uri.parse(
          'https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/get_ulasan.php?id_wisata=${widget.wisata.idWisata}'));
      
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res['success'] == true) {
          setState(() {
            _listReviews = (res['data'] as List).map((item) {
              return {
                "name": item['nama_customer'].toString(),
                "date": item['tanggal'].toString(),
                "text": item['ulasan'].toString(),
                "avatar": "https://i.pravatar.cc/100?img=1"
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      print("Error ambil review: $e");
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
              // 👇 UDAH DISESUAIKAN 100% SAMA WISATAMODEL LU
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text("Belum ada event di wisata ini.", style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }

  // --- 3. LOGIKA TAMBAH REVIEW OTOMATIS ---
  Widget _buildReviewsTab(BuildContext context, Color cardColor, Color textColor) { 
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
                barrierDismissible: false, // User nggak bisa nutup dialog dengan klik luar
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0BB5A7)),
                ),
              );

              try {
                final prefs = await SharedPreferences.getInstance();
                String idCustomer = prefs.getString("id_customer") ?? "0";

                var response = await http.post(
                  Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/ulasan_wisata.php'),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "id_wisata": widget.wisata.idWisata,
                    "id_customer": idCustomer,
                    "ulasan": hasilReview
                  }),
                );

                // 2. NUTUP LOADING DIALOG
                if (mounted) Navigator.pop(context);

                if (response.statusCode == 200) {
                  await _fetchReviews(); // Tunggu data baru kesedot
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review berhasil diposting!')),
                    );
                  }
                }
              } catch (e) {
                // 2. NUTUP LOADING DIALOG JIKA ERROR
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal posting: $e')),
                  );
                }
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.shade300)),
            child: const Text("Tulis Review di sini", style: TextStyle(color: Colors.grey)),
          ),
        ),
        const SizedBox(height: 16),
        ..._listReviews.map((review) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildReviewCard(cardColor, textColor, review["name"]!, review["date"]!, review["text"]!, review["avatar"]!),
        )),
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
          CircleAvatar(backgroundImage: NetworkImage(avatarUrl), radius: 16),
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
    // Ingat! Karena sekarang Stateful, kita panggil wisatanya pakai widget.wisata
    if (widget.wisata.gambar.isEmpty) {
      return Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported, size: 50));
    }
    if (widget.wisata.isLocalImage) {
      return Image.asset(widget.wisata.gambar, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)));
    } else {
      return CachedNetworkImage(
        imageUrl: widget.wisata.gambar, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
        placeholder: (context, url) => Container(color: Colors.grey[300]),
        errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
      );
    }
  }
}