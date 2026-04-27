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
  static const String _keyId = "id_customer";
  static const String _keyNama = "nama_customer";
  static const String _keyEmail = "email_customer";
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
    if (id != null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  // 1. Logic Login Manual
  Future<void> _loginManual() async {
    String nama = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (nama.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nama dan password wajib diisi")));
      return;
    }

    setState(() => _isLoading = true);

    try {
    var url = Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/login.php');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nama_customer": nama, "password_customer": password}),
    );

    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['success'] == true) {
        // --- PERBAIKAN DI SINI ---
        await _saveSession(
          res['id_customer'].toString(),
          res['nama_customer'],
          res['email_customer'],
          res['foto'], // Pakai res['foto'], JANGAN 'null' lagi bre!
        );
        // -------------------------

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

// 2. Update _loginWithGoogle jadi seperti ini
Future<void> _loginWithGoogle() async {
  setState(() => _isLoading = true);
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );
    
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    // AuthCredential hanya butuh idToken untuk Firebase
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken, // Masih boleh disertakan, tapi opsional
    );

    // Dapatkan user dari hasil sign-in Firebase
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = userCredential.user;

    // Sekarang variabel 'user' sudah terdefinisi dan siap dipakai
    if (user != null && mounted) {
      var url = Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/google_login.php');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email_customer": user.email,
          "nama_customer": user.displayName,
          "foto": user.photoURL,
        }),
      );

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res['success'] == true) {
          await _saveSession(
            res['id_customer'].toString(), 
            res['nama_customer'], 
            res['email_customer'], 
            res['foto']
          );
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
        }
      }
    }
  } catch (e) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  // Helper Simpan Sesi
  Future<void> _saveSession(String id, String nama, String email, String? foto) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyId, id);
  await prefs.setString(_keyNama, nama);
  await prefs.setString(_keyEmail, email);
  
  // Pakai ini: Kalau foto null, simpen string kosong ("") biar foto lama kehapus
  await prefs.setString(_keyFoto, foto ?? ""); 
  
  print("DEBUG LOGIN: Berhasil simpen foto -> ${foto ?? 'Kosong'}");
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
                      "Nama Pengguna",
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
                        hintText: "Masukkan Nama Pengguna",
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