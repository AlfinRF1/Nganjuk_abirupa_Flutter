import 'package:flutter/material.dart';

class TambahReviewScreen extends StatefulWidget {
  const TambahReviewScreen({super.key});

  @override
  State<TambahReviewScreen> createState() => _TambahReviewScreenState();
}

class _TambahReviewScreenState extends State<TambahReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8), // Background persis Figma
      body: Column(
        children: [
          // HEADER GRADASI
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16, // Biar nggak ketabrak status bar HP
              left: 16,
              right: 16,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
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
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    // Pastikan path gambar logo ini sesuai sama yang lu punya
                    Image.asset('assets/images/logotextputih.png', height: 24,
                        errorBuilder: (context, error, stackTrace) => const Text("Nganjuk Abirupa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Review",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // FORM INPUT REVIEW
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Text Field Multiline
                  TextField(
                    controller: _reviewController,
                    maxLines: 8, // Bikin kotaknya tinggi
                    decoration: InputDecoration(
                      alignLabelWithHint: true, // Labelnya biar di atas kiri, bukan di tengah
                      labelText: "Review:",
                      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      hintText: "Ceritakan Pengalaman anda",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF4F7F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0BB5A7), width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TOMBOL BATAL & POSTING
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Batal
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                      ),

                      // Tombol Posting
                      // Tombol Posting
                      ElevatedButton(
                        onPressed: () {
                          // Cek kalau ketikannya nggak kosong
                          if (_reviewController.text.isNotEmpty) {
                            // Tutup layar DAN kirim teksnya ke halaman sebelumnya
                            Navigator.pop(context, _reviewController.text);
                          } else {
                            // Kalau kosong, kasih peringatan
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Review tidak boleh kosong!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          backgroundColor: const Color(0xFF0BB5A7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: const Text("Posting", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}