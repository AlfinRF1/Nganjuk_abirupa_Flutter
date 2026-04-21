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
            // Ganti 192.168.X.X dengan IP WiFi lu (jangan lupa akhiri dengan '/')
            baseUrl: 'https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/', 
            connectTimeout: const Duration(seconds: 10), // Maksimal nunggu koneksi 10 detik
            receiveTimeout: const Duration(seconds: 10), // Maksimal nunggu respon 10 detik
            responseType: ResponseType.json,
          ),
        );

  // ==========================================
  // 1. FITUR REGISTRASI (Dari kode lu sebelumnya)
  // ==========================================
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post("register.php", data: request.toJson());
      // Dio otomatis mengubah JSON jadi Map, jadi langsung masukin aja
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
      // Tinggal panggil nama filenya aja, karena baseUrl udah diset di atas
      final response = await _dio.get("get_all_wisata.php");

      if (response.statusCode == 200) {
        // Dio otomatis merubah response jadi Map<String, dynamic>
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