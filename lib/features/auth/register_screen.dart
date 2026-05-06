import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // WAJIB DITAMBAHKAN UNTUK INPUT FORMATTER
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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _checkNamaAvailability(String nama) async {
    setState(() => _nameError = null);
    if (nama.isEmpty) return;
    if (nama.length < 3) {
      setState(() => _nameError = "Minimal 3 karakter");
      return;
    }
    
    // VALIDASI REGEX: Disesuaikan agar mendeteksi jika entah bagaimana ada spasi/simbol yang lolos[cite: 8]
    if (!RegExp(r"^[a-zA-Z0-9]*$").hasMatch(nama)) {
      setState(() => _nameError = "Hanya huruf dan angka tanpa spasi!");
      return;
    }

    // MATIKAN SEMENTARA PENGECEKAN KE SERVER LAMA
    /* 
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
    */
  }

  Future<void> _handleRegister() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap lengkapi semua data!"), backgroundColor: Colors.red));
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password dan Konfirmasi tidak cocok!"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // 1. GANTI KE URL LARAVEL LOKAL LU!
      var url = Uri.parse('http://localhost:8000/api/register');
      
      var response = await http.post(
        url,
        headers: {"Accept": "application/json", "Content-Type": "application/json"},
        body: jsonEncode({
          "nama": name, // Sesuaikan sama $request->nama di Laravel
          "email": email, // Sesuaikan sama $request->email di Laravel
          "no_tlp": phone,
          "password": password, 
        }),
      );

      debugPrint("DEBUG REGISTER: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        var res = jsonDecode(response.body);
        if (!mounted) return;
        
        if (res['status'] == 'success') { // Cocokin pake 'status'
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registrasi Berhasil! Silakan Login."), backgroundColor: Colors.green));
          Navigator.pop(context); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Registrasi Gagal!")));
        }
      } else {
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
      backgroundColor: Colors.white, 
      body: Column(
        children: [
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

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
                    
                    // PERUBAHAN DISINI: Tambah inputFormatters dan ubah teks Hint
                    _buildField(
                      "Nama Pengguna", 
                      "Contoh: iqbalrakha123", 
                      _nameController, 
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), // Blokir semua spasi dan simbol
                      ],
                      onChanged: (val) => _checkNamaAvailability(val), 
                      errorText: _nameError
                    ),
                    
                    _buildField("Alamat Email", "Masukkan Email", _emailController, keyboardType: TextInputType.emailAddress),
                    
                    // PERUBAHAN DISINI: Tambah inputFormatters untuk memblokir teks, spasi, dan simbol selain angka
                    _buildField(
                      "No. Telp", 
                      "Masukkan No. Telp", 
                      _phoneController, 
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly // Hanya boleh ketik angka
                      ]
                    ),
                    
                    _buildField("Kata Sandi", "Masukkan Kata Sandi", _passwordController, 
                        isPass: true, 
                        obscureText: _obscurePassword,
                        onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword)),
                        
                    _buildField("Konfirmasi Kata Sandi", "Konfirmasi Kata Sandi", _confirmPasswordController, 
                        isPass: true,
                        obscureText: _obscureConfirmPassword,
                        onSuffixTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gradientMiddle,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), 
                        ),
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text("Buat Akun", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: const TextSpan(
                            text: "Sudah punya akun? ",
                            style: TextStyle(color: Colors.black54, fontFamily: 'Poppins', fontSize: 14),
                            children: [
                              TextSpan(
                                text: "Masuk di sini",
                                style: TextStyle(color: AppColors.gradientMiddle, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PERUBAHAN DISINI: Tambah parameter `inputFormatters` agar bisa menerima aturan filter teks
  Widget _buildField(String label, String hint, TextEditingController ctrl, 
      {bool isPass = false, 
       bool obscureText = false, 
       TextInputType keyboardType = TextInputType.text,
       List<TextInputFormatter>? inputFormatters, 
       Function(String)? onChanged, 
       VoidCallback? onSuffixTap,
       String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters, // Memasukkan filter ke dalam TextField
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
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2)),
            
            suffixIcon: isPass 
                ? IconButton(
                    icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black45),
                    onPressed: onSuffixTap,
                  ) 
                : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}