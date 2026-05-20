import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nganjukabirupa/core/models/wisata_model.dart';
import 'package:nganjukabirupa/features/pemesanan/pemesanan_screen.dart';
import 'tambah_review_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiConfig {
  static const String baseUrl = "https://nganjukabirupa.pbltifnganjuk.com/api";
  static const String imgUrl = "https://nganjukabirupa.pbltifnganjuk.com/images/destinasi";
  static String detailWisata(String id) => "$baseUrl/wisata/$id";
}

class DetailWisataScreen extends StatefulWidget {
  final WisataModel wisata;
  const DetailWisataScreen({super.key, required this.wisata});

  @override
  State<DetailWisataScreen> createState() => _DetailWisataScreenState();
}

class _DetailWisataScreenState extends State<DetailWisataScreen> {
  String namaUserLogin = "Pengguna";
  List<dynamic> _listReviews = []; 
  bool _isLoading = true;
  late WisataModel _detailWisata;

  @override
  void initState() {
    super.initState();
    _detailWisata = widget.wisata; 
    _ambilDataUser();
    _fetchSemuaData(); 
  }

  Future<void> _fetchSemuaData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String? idCustomer = prefs.getString("id_customer");
      String? token = prefs.getString("token");

      debugPrint("DEBUG: ID yang dikirim ke server adalah -> $idCustomer");
      
      final response = await http.get(
        Uri.parse(ApiConfig.detailWisata(widget.wisata.idWisata.toString())),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res['status'] == 'success' && mounted) {
          setState(() {
            _detailWisata = WisataModel.fromJson(res['data']);
            _listReviews = res['data']['ulasan'] ?? [];
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        debugPrint("ALARM: Token expired atau gak valid!");
      }
    } catch (e) {
      debugPrint("Koneksi Hostinger Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 👇 FIX MUTLAK: Sekarang fungsi refresh review dipersenjatai Token Bearer agar tidak 401!
  Future<void> _fetchReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      var response = await http.get(
        Uri.parse(ApiConfig.detailWisata(widget.wisata.idWisata.toString())),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _listReviews = res['data']['ulasan'] ?? []; 
          });
        }
      }
    } catch (e) { 
      debugPrint("Refresh Review Gagal: $e"); 
    }
  }

  Future<void> _ambilDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => namaUserLogin = prefs.getString("nama_customer") ?? "Pengguna");
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PemesananScreen(
                    idWisata: int.tryParse(widget.wisata.idWisata.toString()) ?? 0, 
                    hargaDewasa: widget.wisata.tiketDewasa, 
                    hargaAnak: widget.wisata.tiketAnak,     
                    tarifAsuransi: int.tryParse(widget.wisata.biayaAsuransi.toString()) ?? 1000, 
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
                height: 240, 
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
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: CachedNetworkImage(
                  imageUrl: event.gambarPoster,
                  width: double.infinity,
                  fit: BoxFit.fitWidth, 
                  placeholder: (context, url) => Container(
                    height: 200, 
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
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF0BB5A7)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Event: ${event.tglMulai} s/d ${event.tglSelesai}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4e4e4e)),
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
              if (!context.mounted) return;
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
                String token = prefs.getString("token") ?? "";

                var response = await http.post(
                  Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/api/ulasan'),
                  headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    "Authorization": "Bearer $token",
                  },
                  body: jsonEncode({
                    "id_wisata": widget.wisata.idWisata,
                    "id_customer": idCustomer,
                    "ulasan": hasilReview 
                  }),
                );

                if (mounted) Navigator.pop(context); 

                if (response.statusCode == 200 || response.statusCode == 201) {
                  await _fetchReviews(); 
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review berhasil diposting!'), backgroundColor: Colors.green),
                    );
                  }
                } else {
                  debugPrint("Gagal posting review: ${response.body}");
                }
              } catch (e) {
                if (mounted) Navigator.pop(context); 
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
          final Map<String, dynamic> dataReview = review as Map<String, dynamic>; 
          final Map<String, dynamic> customer = (dataReview["customer"] ?? {}) as Map<String, dynamic>;
          String fotoUrlDariApi = customer["foto"]?.toString() ?? "";
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReviewCard(
              cardColor, 
              textColor, 
              customer["nama_customer"]?.toString() ?? "Anonim",
              dataReview["tanggal"]?.toString() ?? "-",
              dataReview["ulasan"]?.toString() ?? "",
              fotoUrlDariApi 
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReviewCard(Color bgColor, Color textColor, String name, String date, String review, String avatarUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: avatarUrl.isNotEmpty && avatarUrl != "null"
                ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    width: 32, height: 32,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 32, height: 32,
                      color: Colors.grey.shade200,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0BB5A7)),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 32, height: 32,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 20, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 32, height: 32,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 20, color: Colors.grey),
                  ),
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

  Widget _buildHeaderImage() {
    if (widget.wisata.gambar.isEmpty) {
      return Container(
        color: Colors.grey[300], 
        child: const Icon(Icons.image_not_supported, size: 50)
      );
    }
    return CachedNetworkImage(
      imageUrl: widget.wisata.gambar, 
      fit: BoxFit.cover, 
      width: double.infinity, 
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator(color: Colors.green)),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300], 
        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey)
      ),
    );
  }
}