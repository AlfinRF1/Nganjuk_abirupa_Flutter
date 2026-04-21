import 'package:flutter/material.dart';
import 'package:nganjukabirupa/core/models/wisata_model.dart';
import 'package:nganjukabirupa/core/network/api_service.dart';
import 'package:nganjukabirupa/features/AI/chataimodal.dart';
import 'package:nganjukabirupa/features/dashboard/detail_wisata_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Variabel State
  List<WisataModel> _allWisata = [];
  List<WisataModel> _filteredWisata = [];
  bool _isLoading = true;
  
  // Ganti teks defaultnya jadi ini biar keliatan elegan pas lagi loading sedetik
  String _namaUser = "Memuat..."; 

  // Search Controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // <--- PANGGIL FUNGSI INI DULUAN
    _fetchWisata();
    
    _searchController.addListener(_filterWisata);
  }

  // --- TAMBAHIN FUNGSI INI DI BAWAH initState ---
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // PERHATIAN: Pastikan kata 'nama_customer' ini SAMA PERSIS 
      // dengan key yang lu pake pas nyimpen data di halaman Login lu.
      _namaUser = prefs.getString('nama_customer') ?? "Pengunjung";
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi ambil data dari API
  Future<void> _fetchWisata() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final data = await apiService.getAllWisata();
      
      setState(() {
        _allWisata = data;
        _filteredWisata = data; // Awalnya tampilkan semua
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Tampilkan error kalau gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  // Fungsi Filter Pencarian
  void _filterWisata() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredWisata = _allWisata.where((wisata) {
        return wisata.namaWisata.toLowerCase().contains(query) || 
               wisata.lokasi.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8), // Warna background dari XML lu
      
      // --- TAMBAHAN: FLOATING ACTION BUTTON AI ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context, 
          builder: (c) => ChatAiModal() // Ini modal AI yang tadi kita buat
        ),
        backgroundColor: const Color(0xFF2E9FA6),
        child: const Icon(Icons.smart_toy, color: Colors.white),
      ),
      // ------------------------------------------

      // BOTTOM NAVIGATION BAR (Pengganti Footer LinearLayout lu)
      // Note: Kalau lu pake main_navigation.dart, blok bottomNavigationBar ini bisa lu hapus nanti
      
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchWisata, // Fungsi SwipeRefreshLayout
          color: const Color(0xFF2E9FA6),
          child: Column(
            children: [
              // HEADER & SEARCH BAR (Pengganti FrameLayout XML)
              _buildHeader(),

              // KONTEN LIST (Pengganti RecyclerView)
              Expanded(
                child: _isLoading
                    ? _buildShimmerLoading() // Kalau loading tampilkan Shimmer
                    : _filteredWisata.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text("Wisata tidak ditemukan"),
                                TextButton(onPressed: _fetchWisata, child: const Text("Coba Refresh"))
                              ],
                            ),
                          )
                        : _buildWisataList(), // Kalau selesai tampilkan Data
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET HEADER & SEARCH
  // ==========================================
  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // HEADER GRADASI
        Container(
          height: 140, // Disesuaikan biar lebih lega
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient( // <-- INI YANG BIKIN GRADASI
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2E9FA6), Color(0xFF66BB6A)], 
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GANTI TEKS LOGO PAKAI IMAGE ASSET KALAU ADA
              Image.asset('assets/images/logotextputih.png', width: 120), 
              const SizedBox(height: 12),
              Text(
                "Selamat Datang, $_namaUser!",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        
        // SEARCH BAR
        Positioned(
          bottom: -25,
          left: 16,
          right: 16,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Mau Liburan Kemana?",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Color(0xFF2E9FA6)), // Ikon warna senada
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET DATA LIST WISATA
  // ==========================================
  Widget _buildWisataList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
      itemCount: _filteredWisata.length,
      itemBuilder: (context, index) {
        final wisata = _filteredWisata[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge, // <-- Tambahin ini biar efek kliknya rapi
          child: InkWell(
            onTap: () {
              // --- INI KODE BUAT PINDAH HALAMANNYA BRE ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailWisataScreen(wisata: wisata),
                ),
              );
              // -------------------------------------------
            },
            child: Row(
              children: [
                // GAMBAR WISATA
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12)),
                  child: wisata.gambar.isEmpty
                      ? Container(
                          width: 100, height: 100, color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        )
                      : wisata.isLocalImage
                          ? Image.asset(
                              wisata.gambar,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100, height: 100, color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                );
                              },
                            )
                          : CachedNetworkImage(
                              imageUrl: wisata.gambar,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey[300]),
                              errorWidget: (context, url, error) => Container(
                                width: 100, height: 100, color: Colors.grey[300],
                                child: const Icon(Icons.wifi_off, color: Colors.grey),
                              ),
                            ),
                ),
                const SizedBox(width: 12),
                
                // TEKS DETAIL
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wisata.namaWisata,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                wisata.lokasi,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // WIDGET SKELETON LOADING
  // ==========================================
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
      itemCount: 5, // Tampilkan 5 skeleton
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              children: [
                Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: double.infinity, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 150, height: 12, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 12, color: Colors.white),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}