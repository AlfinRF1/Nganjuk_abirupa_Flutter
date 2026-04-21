import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _nameError;
  Timer? _debounce;

  Future<void> _checkNamaAvailability(String nama) async {
    setState(() => _nameError = null);
    if (nama.isEmpty) return;
    if (nama.length < 3) {
      setState(() => _nameError = "Minimal 3 karakter");
      return;
    }
    if (!RegExp(r"^[a-zA-Z0-9 ]*$").hasMatch(nama)) {
      setState(() => _nameError = "Nama tidak boleh mengandung simbol!");
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        var url = Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/checkNama.php?nama_customer=$nama');
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var res = jsonDecode(response.body);
          if (mounted) {
            setState(() {
              _nameError = (res['available'] == false) ? "⚠ Nama ini telah digunakan" : null;
            });
          }
        }
      } catch (e) {
        if (mounted) setState(() => _nameError = "Koneksi ke server gagal");
      }
    });
  }

  Future<void> _handleRegister() async {
    // BARIS INI YANG TADI KEMUNGKINAN KEHAPUS
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap lengkapi semua data!"), backgroundColor: Colors.red));
      return;
    }

    if (_nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_nameError!), backgroundColor: Colors.red));
      return;
    }

    if (phone.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No. Telp minimal 13 karakter!"), backgroundColor: Colors.orange));
      return;
    }

    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Format email tidak valid!"), backgroundColor: Colors.red));
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password dan Konfirmasi tidak cocok!"), backgroundColor: Colors.orange));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password minimal 6 karakter!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      var url = Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/register.php');
      
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama_customer": name,
          "email_customer": email,
          "no_tlp": phone,
          "password_customer": password,
        }),
      );

      // --- INI PRINT BUAT NYARI TAU ERROR SERVERNYA APA ---
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");
      // ----------------------------------------------------

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (!mounted) return;
        
        if (res['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registrasi Berhasil!"), backgroundColor: Colors.green));
          Navigator.pop(context); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Registrasi Gagal!")));
        }
      } else {
        // TAMPILIN ERROR KALAU SERVER PHP NYA CRASH
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Server: ${response.statusCode}"), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal terhubung ke server! Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Scaffold background putih total biar nggak bocor
      backgroundColor: Colors.white, 
      body: Column(
        children: [
          // HEADER (Tetap putih)
          Container(
            padding: const EdgeInsets.only(top: 45, bottom: 16),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.gradientMiddle), onPressed: () => Navigator.pop(context)),
                const Expanded(child: Center(child: Text("Daftar Akun", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18)))),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // 2. REGISTER FRAME (Tanpa Radius, Full Edge)
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              // [FIX] Hapus BorderRadius, kasih background abu-abu flat
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5), 
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Daftar Akun Nganjuk Abirupa!", 
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 24),
                    
                    _buildField("Nama Lengkap", "Masukkan Nama", _nameController, onChanged: (val) => _checkNamaAvailability(val), errorText: _nameError),
                    _buildField("Alamat Email", "Masukkan Email", _emailController),
                    _buildField("No. Telp", "Masukkan No. Telp", _phoneController),
                    _buildField("Kata Sandi", "Masukkan Kata Sandi", _passwordController, isPass: true),
                    _buildField("Konfirmasi Kata Sandi", "Konfirmasi Kata Sandi", _confirmPasswordController, isPass: true),
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gradientMiddle,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // Button juga dibuat kotak tanpa radius
                        ),
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Buat Akun", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
          
          // ...

  // Refactor Field biar lebih cantik
  Widget _buildField(String label, String hint, TextEditingController ctrl, {bool isPass = false, Function(String)? onChanged, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: isPass,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Colors.black26),
            filled: true,
            fillColor: Colors.white,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gradientMiddle, width: 2)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}