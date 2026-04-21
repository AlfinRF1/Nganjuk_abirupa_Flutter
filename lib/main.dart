import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import ini wajib
import 'package:nganjukabirupa/main_navigation.dart';
import 'firebase_options.dart'; // Import ini wajib (hasil dari flutterfire configure)

// Import fitur lu
import 'features/splash/splash_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/tambah_review_screen.dart';
import 'features/dashboard/profile_screen.dart';

void main() async {
  // 1. WAJIB: Pastikan Flutter binding siap sebelum manggil Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. WAJIB: Inisialisasi Firebase dengan konfigurasi platform yang sesuai
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
      
      initialRoute: '/', // Pas app dibuka, langsung lari ke route '/' (Splash Screen)
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        
        // 👇 PENTING: '/dashboard' sekarang ngarah ke si Induk (MainNavigation)
        '/dashboard': (context) => const MainNavigation(), 
        
        '/riwayat': (context) => const MainNavigation(initialIndex: 1), // Ngarah ke tab Riwayat
        '/tambah_review': (context) => const TambahReviewScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}