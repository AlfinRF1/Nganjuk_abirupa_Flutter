import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart'; 

// Import fitur-fitur lu
import 'package:nganjukabirupa/features/auth/forgot_password_success_screen.dart';
import 'package:nganjukabirupa/features/auth/set_new_password_screen.dart';
import 'package:nganjukabirupa/main_navigation.dart'; // Pondasi wadah PageView lu
import 'features/splash/splash_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/tambah_review_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/verify_code_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("DEBUG: .env berhasil di-load!");
  } catch (e) {
    debugPrint("DEBUG: Gagal load .env -> $e");
  }
  
  // 1. Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nganjuk Abirupa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      
      // SELALU mulai dari Splash Screen
      initialRoute: '/', 
      
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/verify-code': (context) => const VerifyCodeScreen(),
        '/set-new-password': (context) => const SetNewPasswordScreen(),
        '/forgot-password-success': (context) => const ForgotPasswordSuccessScreen(),
        '/tambah_review': (context) => const TambahReviewScreen(),
        
        // 👇 LOGIKA RUTE DINAMIS (Wajib arahkan semua ke wadah MainNavigation)
        '/dashboard': (context) => const MainNavigation(initialIndex: 0), // Default index 0 (Dashboard)
        '/riwayat': (context) => const MainNavigation(initialIndex: 1),   // Lompat ke index 1 (Riwayat)
        '/profile': (context) => const MainNavigation(initialIndex: 2),   // Lompat ke index 2 (Profile)
      },
    );
  }
}