import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- WAJIB IMPORT FIREBASE AUTH
import '../../core/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // --- HAPUS KATA 'final' DISINI ---
  // Biar nilainya bisa kita update setelah ngecek ke Firebase
  bool _isLoggedIn = false; 
  bool _isVisible = false;

  static const _splashDurationMs = 2000;
  static const _fadeInDurationMs = _splashDurationMs ~/ 2;
  // -------------------------------------------

  @override
  void initState() {
    super.initState();
    _startSplashLogic();
  }

  Future<void> _startSplashLogic() async {
    // 1. Mulai animasi fade-in
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() {
        _isVisible = true; // Mengubah opacity jadi 1.0
      });
    }

    // 2. CEK SESSION LOGIN DI FIREBASE
    // Kita cek apakah ada user yang sedang nyantol di HP ini
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _isLoggedIn = true; // Kalau ada, set true
    } else {
      _isLoggedIn = false; // Kalau kosong, set false
    }

    // 3. Tunggu sisa durasi splash screen (2 detik) biar logo tetap nongol
    await Future.delayed(const Duration(milliseconds: _splashDurationMs));

    // 4. Navigasi
    if (!mounted) return;

    if (_isLoggedIn) {
      // Langsung gas ke Dashboard kalau udah login
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Lempar ke Login kalau belum
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(32.0),
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
        child: Stack(
          children: [
            // Logo Tengah
            Align(
              alignment: Alignment.center,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: _fadeInDurationMs),
                opacity: _isVisible ? 1.0 : 0.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 250.0,
                    maxHeight: 250.0,
                  ),
                  child: Image.asset(
                    'assets/images/logo_awal.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Teks Branding Bawah
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: _fadeInDurationMs),
                opacity: _isVisible ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 300.0,
                      maxHeight: 80.0,
                    ),
                    child: Image.asset(
                      'assets/images/logo_awal2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}