import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // Masukin API Key lu dari Google AI Studio (Gratis!)
  static const _apiKey = 'AIzaSyAam2AGk9kVl0ffynsq5Kf_qbG3p6R5DkM'; 

  static Future<String> tanyaWisata(String pertanyaan) async {
    final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: _apiKey);
    
    // Kita kasih "System Prompt" biar AI-nya gak melenceng
    final prompt = "Lu adalah asisten wisata Nganjuk Abirupa. Jawab pertanyaan user tentang wisata di Nganjuk, Jawa Timur. Jangan jawab selain itu. Pertanyaan user: $pertanyaan";
    
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? "Waduh, AI-nya lagi pusing nih, coba lagi ya!";
  }
}