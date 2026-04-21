import 'package:flutter/material.dart';
import 'package:nganjukabirupa/features/AI/ai_services.dart';

class ChatAiModal extends StatefulWidget {
  const ChatAiModal({super.key});

  @override
  _ChatAiModalState createState() => _ChatAiModalState();
}

class _ChatAiModalState extends State<ChatAiModal> {
  final TextEditingController _controller = TextEditingController();
  String _jawaban = "Halo! Mau tanya apa soal wisata Nganjuk?";
  bool _isLoading = false;

  void _kirimPesan() async {
    if (_controller.text.isEmpty) return; // Mencegah kirim pesan kosong

    setState(() => _isLoading = true);
    
    try {
      // Panggil service AI
      String hasil = await AiService.tanyaWisata(_controller.text);
      if (mounted) {
        setState(() {
          _jawaban = hasil;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Tangani kalau API error
      if (mounted) {
        setState(() {
          _jawaban = "Waduh, koneksi ke AI gagal nih. Coba cek internet atau API Key ya!";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Tambahin padding bawah biar nggak ketutup keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
        top: 20, left: 20, right: 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Asisten Wisata AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          // Scrollable area buat jawaban yang panjang
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(
              child: Text(_isLoading ? "AI lagi mikir..." : _jawaban),
            ),
          ),
          TextField(controller: _controller, decoration: const InputDecoration(hintText: "Tanya sesuatu...")),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isLoading ? null : _kirimPesan, // Disable tombol saat loading
            child: const Text("Kirim"),
          ),
        ],
      ),
    );
  }
}