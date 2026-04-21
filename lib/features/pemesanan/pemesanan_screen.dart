import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pilih_pengunjung_bottomsheet.dart'; // Import file yang baru dibuat tadi
import 'qr_code_screen.dart'; // Akan kita buat nanti

class PemesananScreen extends StatefulWidget {
  final int idWisata;
  final int hargaDewasa;
  final int hargaAnak;
  final int tarifAsuransi;

  const PemesananScreen({
    super.key,
    required this.idWisata,
    required this.hargaDewasa,
    required this.hargaAnak,
    required this.tarifAsuransi,
  });

  @override
  _PemesananScreenState createState() => _PemesananScreenState();
}

class _PemesananScreenState extends State<PemesananScreen> {
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _tanggalController = TextEditingController();

  int jumlahDewasa = 0;
  int jumlahAnak = 0;
  bool isLoading = false;

  int get totalHargaDewasa => jumlahDewasa * widget.hargaDewasa;
  int get totalHargaAnak => jumlahAnak * widget.hargaAnak;
  int get totalAsuransi => (jumlahDewasa + jumlahAnak) * widget.tarifAsuransi;
  int get totalHarga => totalHargaDewasa + totalHargaAnak + totalAsuransi;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaController.text = prefs.getString("nama_customer") ?? "";
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E9FA6), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showPengunjungSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PilihPengunjungBottomSheet(
          initialDewasa: jumlahDewasa,
          initialAnak: jumlahAnak,
          onSimpan: (dewasa, anak) {
            setState(() {
              jumlahDewasa = dewasa;
              jumlahAnak = anak;
            });
          },
        );
      },
    );
  }

  Future<void> _prosesPembayaran() async {

    String nama = _namaController.text.trim();
    String tlp = _teleponController.text.trim();
    String tgl = _tanggalController.text.trim();

    if (_namaController.text.isEmpty || _teleponController.text.isEmpty || _tanggalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mohon lengkapi semua data")));
      return;
    }
    if (jumlahDewasa + jumlahAnak == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih pengunjung terlebih dahulu")));
      return;
    }
    
    // 1. CEK KOSONG
    if (nama.isEmpty || tlp.isEmpty || tgl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mohon lengkapi semua data")));
      return;
    }

    // 2. VALIDASI PANJANG NOMOR TELEPON (Minimal 11)
    if (tlp.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nomor telepon tidak valid! Minimal 11 digit."),
          backgroundColor: Colors.redAccent,
        )
      );
      return;
    }
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String idCustomer = prefs.getString("id_customer") ?? "";

      var response = await http.post(
        Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/insert_pemesanan.php'),
        body: {
          "nama_customer": _namaController.text,
          "tlp_costumer": _teleponController.text,
          "tanggal": _tanggalController.text,
          "jml_tiket": (jumlahDewasa + jumlahAnak).toString(),
          "harga_total": totalHarga.toString(),
          "id_wisata": widget.idWisata.toString(),
          "id_customer": idCustomer,
        },
      );

      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QrCodeScreen(
              totalHarga: totalHarga,
              idWisata: widget.idWisata,
            ),
          ),
        );
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Number format for IDR
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Detail Pesanan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FORM INPUT ---
              _buildInputLabel("Nama"),
              _buildTextField(controller: _namaController, hint: "Nama Lengkap"),
              const SizedBox(height: 16),
              
              _buildInputLabel("Nomor Telepon"),
              _buildTextField(controller: _teleponController, hint: "+62 123 123 123", isNumber: true),
              const SizedBox(height: 16),

              _buildInputLabel("Tanggal Pemesanan"),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _tanggalController,
                    hint: "YYYY-MM-DD",
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E9FA6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calendar_month, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildInputLabel("Jumlah pesanan"),
              GestureDetector(
                onTap: _showPengunjungSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          jumlahDewasa == 0 && jumlahAnak == 0 
                            ? "Pilih jumlah pengunjung" 
                            : "${jumlahDewasa.toString().padLeft(2,'0')} Dewasa, ${jumlahAnak.toString().padLeft(2,'0')} Anak",
                          style: TextStyle(color: (jumlahDewasa == 0 && jumlahAnak == 0) ? Colors.grey : Colors.black, fontSize: 14),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- RINCIAN BIAYA ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildRincianItem("Dewasa", "$jumlahDewasa x ${currencyFormat.format(widget.hargaDewasa)}", totalHargaDewasa),
                    const SizedBox(height: 8),
                    _buildRincianItem("Anak", "$jumlahAnak x ${currencyFormat.format(widget.hargaAnak)}", totalHargaAnak),
                    const SizedBox(height: 8),
                    _buildRincianItem("Asuransi", "${(jumlahDewasa + jumlahAnak)} x ${currencyFormat.format(widget.tarifAsuransi)}", totalAsuransi),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Rp ${currencyFormat.format(totalHarga)}", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E9FA6))),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- TOMBOL BAYAR ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E9FA6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading ? null : _prosesPembayaran,
                  child: isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Bayar sekarang", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, bool isNumber = false, Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E9FA6)),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildRincianItem(String label, String subLabel, int price) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);
    return Row(
      children: [
        Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.black87))),
        Expanded(flex: 3, child: Text(subLabel, style: const TextStyle(color: Colors.grey))),
        Text(price == 0 ? "-" : currencyFormat.format(price), style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}