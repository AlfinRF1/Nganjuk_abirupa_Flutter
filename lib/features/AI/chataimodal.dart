import 'package:flutter/material.dart';
import 'package:nganjukabirupa/features/AI/ai_services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// 1. PINDAHIN KE SINI BRE! (Di luar class apapun)
// Karena ada di luar, datanya nggak bakal keriset walaupun modalnya ditutup.
List<Map<String, String>> chatHistory = [
  {"role": "ai", "text": "Halo! Mau tanya apa soal wisata Nganjuk?"}
];

class ChatAiModal extends StatefulWidget {
  const ChatAiModal({super.key});

  @override
  _ChatAiModalState createState() => _ChatAiModalState();
}

class _ChatAiModalState extends State<ChatAiModal> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  void _kirimPesan() async {
    if (_controller.text.trim().isEmpty) return; 

    String pesanUser = _controller.text;
    _controller.clear(); 

    setState(() {
      // 2. GANTI NAMA VARIABELNYA JADI chatHistory
      chatHistory.add({"role": "user", "text": pesanUser});
      _isLoading = true;
    });
    
    String hasil = await AiService.tanyaWisata(pesanUser); // Opsional: masukin list database lu di sini kalau jadi pake teknik RAG

    if (mounted) {
      setState(() {
        // 3. GANTI NAMA VARIABELNYA JADI chatHistory
        chatHistory.add({"role": "ai", "text": hasil});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
        top: 20, left: 15, right: 15
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Asisten Wisata AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          
          // 4. KITA GANTI JADI LISTVIEW BIAR BISA SCROLL HISTORY
          Container(
            constraints: const BoxConstraints(maxHeight: 350), // Tingginya gue tambahin biar enak baca chatnya
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
            child: ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final msg = chatHistory[index];
                final isUser = msg["role"] == "user";

                // 5. BIKIN BALON CHAT (Kanan User, Kiri AI)
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal[100] : Colors.white, // Warna beda biar ketahuan siapa yang ngomong
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    // Kalau User pake Text biasa, kalau AI pake MarkdownBody
                    child: isUser 
                      ? Text(msg["text"]!, style: const TextStyle(fontSize: 15))
                      : MarkdownBody(data: msg["text"]!, selectable: true),
                  ),
                );
              },
            ),
          ),
          
          // Kalau lagi loading, kasih tulisan kecil di bawah
          if (_isLoading) 
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text("AI lagi ngetik...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ),

          const SizedBox(height: 10),
          TextField(
            controller: _controller, 
            decoration: const InputDecoration(
              hintText: "Tanya sesuatu...",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            )
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: _isLoading ? null : _kirimPesan,
              child: const Text("Kirim"),
            ),
          ),
        ],
      ),
    );
  }
}