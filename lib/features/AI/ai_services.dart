import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

  static Future<String> tanyaWisata(String pertanyaan) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash', // FOKUS DISINI, JANGAN DIGANTI LAGI
        apiKey: _apiKey,
      );
      
      // Tambahin timeout biar dia gak panik kalau server agak lemot
      final response = await model.generateContent([
        Content.text("Lu adalah asisten wisata Nganjuk Abirupa. User tanya: $pertanyaan")
      ]).timeout(const Duration(seconds: 15)); // Sabar nunggu 15 detik
      
      return response.text ?? "AI-nya lagi bengong...";
    } catch (e) {
      print("ERROR DETAILED: $e");
      // Kalau 503 (High Demand), kasih tau user buat coba lagi
      if (e.toString().contains('503')) {
        return "Server AI lagi penuh banget nih bre, coba klik Kirim sekali lagi ya!";
      }
      return "Koneksi gagal. Cek internet lu atau coba lagi bentar lagi.";
    }
  }
}