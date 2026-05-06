import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  bool _isLoading = false;
  // 1. Bikin 5 controller buat 5 kotak
  final List<TextEditingController> _controllers = List.generate(5, (index) => TextEditingController());

  Future<void> _verifyOTP(String email) async {
    print("LOG: Tombol ditekan!"); // Cek apakah tombol jalan
    String otp = _controllers.map((controller) => controller.text).join();
    print("LOG: OTP yang diinput: $otp");

    if (otp.length < 5) {
      print("LOG: OTP kurang dari 5 digit");
      return;
    }

    setState(() => _isLoading = true);
    print("LOG: Mulai kirim data ke localhost...");

    final response = await http.post(
  Uri.parse('http://localhost:8000/api/verify-otp'), 
  headers: {
    "Content-Type": "application/json",
    "Accept": "application/json"
  },
  body: jsonEncode({
    "email": email,
    "otp": otp,
  }),
);

final data = jsonDecode(response.body);

if (data['status'] == 'success') {
  print("LOG: Verifikasi Sukses!"); // Tambahin print buat pastiin
  if (mounted) {
    Navigator.pushReplacementNamed(context, '/set-new-password', arguments: email);
  }
} else {
  print("LOG: Verifikasi Gagal: ${data['message']}");
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? "Kode salah")));
}
}

  @override
  Widget build(BuildContext context) {
    // 4. Ambil email yang dikirim dari halaman lupa password
    final String email = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E9FA6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("Cek email anda", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Kode dikirim ke: $email", style: const TextStyle(color: Colors.grey)), // Kasih liat emailnya
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) => _otpBox(context, _controllers[index])),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E9FA6)),
                onPressed: _isLoading ? null : () => _verifyOTP(email),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Verifikasi Kode", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update widget _otpBox buat nerima controller
  Widget _otpBox(BuildContext context, TextEditingController controller) {
    return SizedBox(
      height: 55, width: 50,
      child: TextField(
        controller: controller,
        onChanged: (value) {
          if (value.length == 1) FocusScope.of(context).nextFocus();
          if (value.isEmpty) FocusScope.of(context).previousFocus(); // Biar bisa backspace
        },
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [LengthLimitingTextInputFormatter(1), FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}