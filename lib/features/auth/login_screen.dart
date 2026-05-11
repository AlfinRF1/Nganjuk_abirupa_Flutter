import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nganjukabirupa/features/auth/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Fix undefined _isPasswordVisible

  // Key untuk SharedPreferences
  static const String _keyToken = "token"; // Tambahin ini bre
  static const String _keyId = "id_customer";
  static const String _keyNama = "nama_customer";
  static const String _keyEmail = "email"; // Sesuaikan sama key di Laravel
  static const String _keyFoto = "foto";

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_keyId);
    String? token = prefs.getString(_keyToken); // <-- WAJIB CEK TOKEN JUGA

    // Cuma boleh loncat ke dashboard kalau ID DAN Token-nya sama-sama terisi
    if (id != null && id.isNotEmpty && token != null && token.isNotEmpty) {
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Kalau salah satu kosong, paksa bersihin sisa memori lama biar aman
      await prefs.clear();
    }
  }

  // 1. Logic Login Manual
  Future<void> _loginManual() async {
    String emailText = _usernameController.text.trim(); 
    String password = _passwordController.text.trim();

    if (emailText.isEmpty || password.isEmpty) {
      _showSnackBar("Email dan password wajib diisi");
      return;
    }

    setState(() => _isLoading = true);

    try {
      var url = Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/api/login');
      var response = await http.post(
        url,
        headers: {"Accept": "application/json", "Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailText, 
          "password": password 
        }),
      );

      debugPrint("DEBUG LOGIN STATUS: ${response.statusCode}");
      debugPrint("DEBUG LOGIN BODY: ${response.body}");

      var res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // LOGIN BERHASIL
        if (res['status'] == 'success' || res['success'] == true) { 
          var dataUser = res['data'] ?? {};

          await _saveSession(
            res['token'] ?? "",
            (dataUser['id_customer'] ?? dataUser['id'] ?? "").toString(),
            dataUser['nama_customer'] ?? "Pengguna",
            dataUser['email'] ?? emailText, 
            dataUser['foto'] ?? "",
          );

          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          _showSnackBar(res['message'] ?? "Login Gagal");
        }
      } 
      // TANGKAP ERROR 401 ATAU 404 DARI LARAVEL
      else if (response.statusCode == 401 || response.statusCode == 404) {
        _showSnackBar(res['message'] ?? "Email atau Password salah!");
      } 
      // TANGKAP ERROR SERVER LAINNYA
      else {
        _showSnackBar("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ERROR LOGIN: $e");
      _showSnackBar("Gagal login: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // FUNGSI PEMBANTU SNACKBAR BIAR RAPI
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

// 2. Update _loginWithGoogle jadi seperti ini
Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      debugPrint("DEBUG: Memulai Google Sign-In...");
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint("DEBUG: User batal login");
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Auth Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      debugPrint("DEBUG: Firebase sukses. Tembak ke Laravel...");
      
      var url = Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/api/google-login'); // Pastikan IP Laptop bener!
      var response = await http.post(
        url,
        headers: {"Accept": "application/json", "Content-Type": "application/json"},
        body: jsonEncode({
          "email": googleUser.email,
          "nama": googleUser.displayName,
          "foto": googleUser.photoUrl,
          "google_id": googleUser.id, 
        }),
      ).timeout(const Duration(seconds: 15)); // Biar gak muter selamanya kalau koneksi jelek

      // CEK APA KATA LARAVEL DI CONSOLE
      debugPrint("DEBUG HTTP STATUS: ${response.statusCode}");
      debugPrint("DEBUG HTTP BODY: ${response.body}");

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);

        // Cek dua kemungkinan: 'status' atau 'success'
        if (res['status'] == 'success' || res['success'] == true) {
          debugPrint("DEBUG: Login Berhasil. Menjalankan navigasi..."); 
          
          // Amankan data biar gak crash kalau Laravel ngirim data kosong
          var dataUser = res['data'] ?? {};

          // SIMPEN TOKEN DARI LARAVEL
          await _saveSession(
            res['token'] ?? "", 
            (dataUser['id_customer'] ?? dataUser['id'] ?? "").toString(), 
            dataUser['nama_customer'] ?? googleUser.displayName ?? "", 
            dataUser['email'] ?? googleUser.email ?? "", 
            dataUser['foto'] ?? googleUser.photoUrl ?? ""
          );
          
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          debugPrint("DEBUG: Login Ditolak Laravel: ${res['message']}");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res['message'] ?? "Gagal Login dari server"))
            );
          }
        } 
      } else {
        // Kalau server mati atau rute gak ketemu (404/500)
        debugPrint("DEBUG: Server Error. Status: ${response.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Server bermasalah. Status: ${response.statusCode}"))
          );
        }
      }
    } catch (e) {
      debugPrint("DEBUG ERROR TOTAL: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e"))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper Simpan Sesi
  Future<void> _saveSession(String token, String id, String nama, String email, String? foto) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyToken, token); // Simpen Token sakti di sini
  await prefs.setString(_keyId, id);
  await prefs.setString(_keyNama, nama);
  await prefs.setString(_keyEmail, email);
  await prefs.setString(_keyFoto, foto ?? ""); 
  
  debugPrint("DEBUG LOGIN: Token berhasil disimpan!");
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // 1. Background Gradient Atas (Setengah layar)
          Container(
            height: size.height * 0.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.gradientStart,
                  AppColors.gradientMiddle,
                  AppColors.gradientEnd,
                ],
              ),
            ),
          ),

          // 2. Logo di bagian atas
          Positioned(
            top: 100.0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/logo_nganjuk_abirupa.png',
                width: 283.0,
                height: 191.0,
                color: Colors.white,
              ),
            ),
          ),

          // 3. Content Card Putih (Rounded Top)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      "Selamat Datang\nDi Nganjuk Abirupa !",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0,
                        color: Color(0xFF4E4E4E),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    
                    // Subtitle
                    const Text(
                      "Login atau Register sekarang! untuk menikmati semua fitur yang tersedia di Nganjuk Abirupa",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.0,
                        color: Color(0xFF616161),
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    // Label Username
                    const Text(
                    "Email Pengguna", // Tadinya "Nama Pengguna"
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                      color: Color(0xFF4E4E4E),
                    ),
                  ),
                    const SizedBox(height: 4.0),

                    // Input Username
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14.0),
                      decoration: InputDecoration(
                        hintText: "Masukkan Alamat Email",
                        hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14.0),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Label Password
                    const Text(
                      "Kata Sandi",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                        color: Color(0xFF4E4E4E),
                      ),
                    ),
                    const SizedBox(height: 4.0),

                    // Input Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14.0),
                      decoration: InputDecoration(
                        hintText: "Masukkan Kata Sandi",
                        hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14.0),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),

                    // --- TAMBAHIN BLOK INI ---
                    Align(
                      alignment: Alignment.centerRight, // Biar posisinya di kanan kayak desain lu
                      child: GestureDetector(
                        onTap: () {
                          // Ini logic buat pindah ke halaman Lupa Kata Sandi
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text(
                          "Lupa kata sandi?",
                          style: TextStyle(
                            color: Colors.grey, // Warna teksnya abu-abu
                            fontSize: 12, 
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gradientMiddle,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: _isLoading ? null : _loginManual,
                        child: _isLoading 
                            ? const SizedBox(
                                height: 20, width: 20, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Tombol Sign in with Google
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: _isLoading ? null : _loginWithGoogle,
                        icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                        label: const Text(
                          "Sign in with Google",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Teks Register
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Belum memiliki akun? ",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.0,
                              color: Color(0xFF616161), // Warna abu-abu kalem
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                            },
                            child: const Text(
                              "Registrasi",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.0,
                                color: Colors.blue, // Warna biru buat link
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ], // Penutup children dari Column
                ), // Penutup Column
              ), // Penutup SingleChildScrollView
            ), // Penutup Container Card Putih
          ), // Penutup Align
        ], // Penutup children dari Stack utama
      ), // Penutup Stack utama
    ); // Penutup Scaffold
  } // Penutup widget build
} // Penutup class _LoginScreenState