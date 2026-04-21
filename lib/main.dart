import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart'; 

// Import fitur-fitur lu
import 'package:nganjukabirupa/features/auth/forgot_password_success_screen.dart';
import 'package:nganjukabirupa/features/auth/set_new_password_screen.dart';
import 'package:nganjukabirupa/main_navigation.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/tambah_review_screen.dart';
import 'features/dashboard/profile_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/verify_code_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  // Langsung jalankan MyApp tanpa perlu oper routeAwal
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
        '/dashboard': (context) => const MainNavigation(), 
        '/riwayat': (context) => const MainNavigation(initialIndex: 1),
        '/tambah_review': (context) => const TambahReviewScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}