import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  Future<void> _updatePassword(String email) async {
    // 1. Validasi Input Dasar
    if (_passController.text.isEmpty || _confirmPassController.text.isEmpty) {
      _showSnackBar("Semua kolom harus diisi!");
      return;
    }

    if (_passController.text.length < 6) {
      _showSnackBar("Password minimal 6 karakter!");
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      _showSnackBar("Password tidak cocok!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Tembak API
      final response = await http.post(
        Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/reset_password.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "new_password": _passController.text,
        }),
      );

      print("DEBUG RESPONSE: ${response.body}");
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        if (mounted) {
          // --- KUNCI PERBAIKAN DI SINI ---
          // Gunakan pushNamedAndRemoveUntil agar tumpukan screen lama (lupa password/otp) dihapus semua.
          // Arahkan ke Success Screen, lalu pastikan di Success Screen tombolnya mengarah ke LOGIN.
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/forgot-password-success', 
            (route) => false,
          );
        }
      } else {
        _showSnackBar(data['message'] ?? "Gagal memperbarui password");
      }
    } catch (e) {
      print("KODE ERROR ASLI: $e"); 
      _showSnackBar("Kesalahan koneksi: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil email dari arguments
    final Object? args = ModalRoute.of(context)!.settings.arguments;
    final String email = args is String ? args : "";

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
      body: email.isEmpty 
      ? const Center(child: Text("Error: Email tidak ditemukan. Coba ulangi proses."))
      : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Set a new password",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create a new password. Ensure it differs from previous ones for security",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              const Text("Password", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildPasswordField(_passController, "Enter your new password"),
              
              const SizedBox(height: 20),
              
              const Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildPasswordField(_confirmPassController, "Re-enter password"),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E9FA6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : () => _updatePassword(email),
                  child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      "Perbarui Password",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: _isObscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
          onPressed: () => setState(() => _isObscure = !_isObscure),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2E9FA6))),
      ),
    );
  }
}