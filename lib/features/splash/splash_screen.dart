import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart'; // Pastikan path ini bener sesuai folder lu

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Variabel buat animasi fade-in
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _startSplashLogic();
  }

  Future<void> _startSplashLogic() async {
    // 1. Kasih jeda dikit biar build selesai baru animasi jalan
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() {
        _isVisible = true; // Jalankan animasi logo muncul
      });
    }

    // 2. Tunggu logo mejeng sebentar (misal total 3 detik dari awal)
    await Future.delayed(const Duration(seconds: 3));

    // 3. CEK SESSION (Logika paling sakti biar gak kedap-kedip)
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil email_customer (kunci yang lu pake di LoginScreen)
    String? email = prefs.getString('email_customer');

    if (!mounted) return;

    // 4. Navigasi Final
    if (email != null && email.isNotEmpty) {
      // Kalau ada data email, berarti user sudah login (Manual/Google)
      // Gunakan pushReplacementNamed biar halaman Splash dihapus dari memory
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Kalau data kosong, lempar ke Login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          alignment: Alignment.center,
          children: [
            // Logo Utama (Tengah)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 1200),
              opacity: _isVisible ? 1.0 : 0.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo_awal.png',
                    width: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  // Opsional: Tambahin loading indicator kecil biar estetik
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
            ),
            // Logo Branding (Bawah)
            Positioned(
              bottom: 40,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1500),
                opacity: _isVisible ? 1.0 : 0.0,
                child: Image.asset(
                  'assets/images/logo_awal2.png',
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}