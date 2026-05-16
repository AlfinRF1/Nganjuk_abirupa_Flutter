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
            baseUrl: 'https://nganjukabirupa.pbltifnganjuk.com/api/', // 
            connectTimeout: const Duration(seconds: 10), 
            receiveTimeout: const Duration(seconds: 10), 
            responseType: ResponseType.json,
          ),
        );

// fungsi login
Future<Map<String, dynamic>> login(String nama, String password) async {
  try {
    final response = await _dio.post("login", data: {
      "nama_customer": nama,
      "password_customer": password,
    });

    if (response.data['success'] == true) {
      // Simpan token pakai shared_preferences
      return response.data; 
    } else {
      throw Exception(response.data['message']);
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? "Gagal Login");
  }
}

// Fungsi Logout
Future<void> logout(String token) async {
  try {
    await _dio.post("logout", 
      options: Options(headers: {"Authorization": "Bearer $token"})
    );
  } catch (e) {
    throw Exception("Gagal Logout");
  }
}

  // 1. FITUR REGISTRASI
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post("register", data: request.toJson());
      
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception("Gagal registrasi (Jaringan): ${e.message}");
    } catch (e) {
      throw Exception("Gagal registrasi: $e");
    }
  }

  // 2. FITUR GET WISATA (Untuk Dashboard)
  Future<List<WisataModel>> getAllWisata() async {
    try {
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