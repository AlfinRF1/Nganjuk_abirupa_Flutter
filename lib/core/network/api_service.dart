import 'package:dio/dio.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/wisata_model.dart';

class ApiService {
  final Dio _dio;

  // Constructor: Kita inisialisasi Dio dengan pengaturan default
  ApiService()
      : _dio = Dio(
          BaseOptions(
            // ✅ UBAH: Gunakan 10.0.2.2 jika pakai Emulator Android
            // Jika pakai HP asli via kabel/WiFi, ganti dengan IP laptop lu (misal: http://192.168.1.15:8000/api/)
            baseUrl: 'http://172.16.103.79:8000/api/', // 
            connectTimeout: const Duration(seconds: 10), 
            receiveTimeout: const Duration(seconds: 10), 
            responseType: ResponseType.json,
          ),
        );

// lib/network/api_service.dart

// Tambahkan fungsi login
Future<Map<String, dynamic>> login(String nama, String password) async {
  try {
    final response = await _dio.post("login", data: {
      "nama_customer": nama,
      "password_customer": password,
    });

    if (response.data['success'] == true) {
      // Simpan token di sini jika perlu (pakai shared_preferences)
      return response.data; 
    } else {
      throw Exception(response.data['message']);
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? "Gagal Login");
  }
}

// Fungsi Logout (Butuh Token)
Future<void> logout(String token) async {
  try {
    await _dio.post("logout", 
      options: Options(headers: {"Authorization": "Bearer $token"})
    );
  } catch (e) {
    throw Exception("Gagal Logout");
  }
}
  // ==========================================
  // 1. FITUR REGISTRASI
  // ==========================================
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      // ✅ UBAH: Hilangkan ".php". Sesuaikan dengan route di routes/api.php Laravel lu
      // Misal di Laravel: Route::post('/register', [AuthController::class, 'register']);
      final response = await _dio.post("register", data: request.toJson());
      
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception("Gagal registrasi (Jaringan): ${e.message}");
    } catch (e) {
      throw Exception("Gagal registrasi: $e");
    }
  }

  // ==========================================
  // 2. FITUR GET WISATA (Untuk Dashboard)
  // ==========================================
  Future<List<WisataModel>> getAllWisata() async {
    try {
      // ✅ UBAH: Dari "get_all_wisata.php" menjadi "wisata" aja
      final response = await _dio.get("wisata");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];
          // Mapping data jadi List of WisataModel
          return data.map((json) => WisataModel.fromJson(json)).toList();
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Gagal koneksi ke server. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Terjadi kesalahan jaringan: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}