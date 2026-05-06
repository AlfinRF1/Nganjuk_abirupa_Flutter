import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
            const Text(
              "Lupa kata sandi",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              "Mohon masukkan email untuk mengganti password",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const Text(
              "Email Anda",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Masukkan email anda",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E9FA6)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E9FA6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : () async {
                  if (_emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Email tidak boleh kosong!"),
                        backgroundColor: Colors.redAccent,
                      )
                    );
                    return;
                  }
                  
                  setState(() => _isLoading = true);
          
                  try {
                    // 1. NEMBAK KE API LARAVEL LOKAL[cite: 5]
                    final response = await http.post(
                    Uri.parse('http://localhost:8000/api/forgot-password'), // Ganti jadi localhost
                    headers: {
                      "Content-Type": "application/json",
                      "Accept": "application/json" // Penting buat Laravel[cite: 1]
                    },
                    body: jsonEncode({"email": _emailController.text}),
                  );

                    debugPrint("STATUS CODE: ${response.statusCode}");
                    debugPrint("RESPONSE BODY: ${response.body}");

                    if (response.statusCode == 200) {
                      var res = jsonDecode(response.body);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res['message'] ?? "Kode OTP terkirim!"),
                            backgroundColor: Colors.green,
                          )
                        );
                        // Lempar email ke halaman verifikasi biar nggak usah ngetik lagi
                        Navigator.pushNamed(context, '/verify-code', arguments: _emailController.text);
                      }
                    } else {
                      // 2. NANGKAP ERROR DARI LARAVEL (Misal: Email tidak terdaftar)
                      var res = jsonDecode(response.body);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res['message'] ?? "Gagal mengirim OTP"),
                            backgroundColor: Colors.redAccent,
                          )
                        );
                      }
                    }
                    
                  } catch (e) {
                    debugPrint("ERROR KONEKSI: $e");
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Koneksi bermasalah: $e"),
                          backgroundColor: Colors.red,
                        )
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Kirim Kode OTP", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}