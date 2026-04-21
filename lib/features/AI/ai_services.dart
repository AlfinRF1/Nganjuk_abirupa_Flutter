import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Wajib import ini

class AiService {
  // Ambil API Key dari file .env (Biar gak bocor ke GitHub)
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

  static Future<String> tanyaWisata(String pertanyaan) async {
    // Cek dulu kuncinya ada gak
    if (_apiKey.isEmpty) {
      return "Waduh bre, API Key belum dipasang di file .env!";
    }

    try {
      // Inisialisasi model
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest', 
        apiKey: _apiKey,
      );
      
      // System Prompt biar AI-nya fokus jadi Guide Nganjuk
      final systemPrompt = "Lu adalah asisten wisata Nganjuk Abirupa. "
          "Jawab pertanyaan user tentang wisata, kuliner, dan budaya di Nganjuk, Jawa Timur secara santai dan informatif. "
          "Jangan jawab pertanyaan di luar topik Nganjuk. "
          "Pertanyaan user: $pertanyaan";
      
      final content = [Content.text(systemPrompt)];
      final response = await model.generateContent(content);

      // Kembalikan teks respon
      return response.text ?? "AI-nya lagi gak mau ngomong nih, coba lagi ya.";

    } catch (e) {
      // Ini buat nangkep error koneksi atau limit API
      print("ERROR AI SERVICE: $e");
      return "Koneksi ke AI gagal bre. Pastikan internet lu lancar atau kuota API belum abis!";
    }
  }
}