import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Buat nanganin file gambar
import 'package:image_picker/image_picker.dart'; // Buat milih gambar
import 'package:image_cropper/image_cropper.dart'; // Buat nge-crop gambar
import 'package:google_sign_in/google_sign_in.dart'; // Tambahin ini di atas

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  File? _imageFile; // Penampung foto lokal sementara
  String? _photoUrl; // Penampung URL foto dari server
  final ImagePicker _picker = ImagePicker(); // Inisialisasi Picker

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Ambil apa adanya dari SharedPreferences
  String? pathDariDB = prefs.getString("foto"); 

  setState(() {
    _nameController.text = prefs.getString("nama_customer") ?? "";
    _emailController.text = prefs.getString("email_customer") ?? "";

    if (pathDariDB != null && pathDariDB.isNotEmpty) {
      if (pathDariDB.startsWith('http')) {
        _photoUrl = pathDariDB; 
      } else {
        // PERHATIKAN: Langsung tempel domain + pathDariDB
        // Karena pathDariDB isinya udah "uploads/1776676472_..."
        _photoUrl = "https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/$pathDariDB";
      }
      print("HASIL URL FINAL: $_photoUrl"); // Cek link ini di console VS Code
    } else {
      _photoUrl = null;
    }
  });
}

  // ==========================================
  // LOGIKA SISTEM FOTO PROFIL (PICK, CROP, UPLOAD)
  // ==========================================

  // 1. Fungsi buat milih gambar dari Galeri
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, // Bisa diganti kamera kalau mau
        maxWidth: 1000,
        maxHeight: 1000,
      );
      
      if (pickedFile != null) {
        // Kalau dapet gambarnya, langsung suruh crop
        _cropImage(pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error milih gambar: $e")));
    }
  }

  // 2. Fungsi buat nge-crop gambar (Sistem Crop)
  Future<void> _cropImage(String filePath) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Paksa Kotak (1:1)
        compressQuality: 80, // Kompres biar nggak kegedean
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Foto Profil',
            toolbarColor: const Color(0xFF2E9FA6),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true, // Kunci rasionya
          ),
          // iOSUiSettings(title: 'Potong Foto Profil'), // Tambahin kalau tes di iOS
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path); // Tampilkan lokal dulu
          _photoUrl = null; // Matiin URL server sementara
        });
        // Langsung upload ke server
        _uploadPhoto();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error crop gambar: $e")));
    }
  }

  // 3. Fungsi buat upload foto (Multipart) ke update_profile.php
  Future<void> _uploadPhoto() async {
    if (_imageFile == null) return;

    final prefs = await SharedPreferences.getInstance();
    String idCustomer = prefs.getString("id_customer") ?? "";

    // 1. CEK: ID Customer-nya beneran ada isinya gak?
    print("DEBUG: ID Customer = $idCustomer");
    print("DEBUG: File Path = ${_imageFile!.path}");

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/update_foto.php'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
      });

      // 2. PASTIIN KEY-NYA SAMA PERSIS DENGAN PHP LU
      request.fields['id_customer'] = idCustomer; 

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto', // <-- CEK: Apakah di PHP lu pakenya 'foto' atau 'gambar' atau 'image'?
          _imageFile!.path,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print("=== DEBUG RESPONSE SERVER ===");
      print(response.body); 
      print("=============================");
      var res = jsonDecode(response.body);
      
      if (res['status'] == 'success') {
        // Update prefs lokal dengan path relatif baru dari server
        await prefs.setString("foto", res['foto']);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto berhasil diupdate!")));
        _loadProfileData(); // Reload biar URL server sinkron
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal upload: ${res['message']}")));
        _loadProfileData(); // Balikin foto lama
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error koneksi server: $e")));
      _loadProfileData(); // Balikin foto lama
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 4. Fungsi buat hapus foto ke delete_foto.php
  Future<void> _deletePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    String idCustomer = prefs.getString("id_customer") ?? "";

    setState(() => _isLoading = true);

    try {
      // delete_foto.php lu minta POST, jadi kita kirim body
      var response = await http.post(
        Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/delete_foto.php'),
        body: {'id_customer': idCustomer}, // Sesuai $_POST['id_customer'] di PHP lu
      );

      var res = jsonDecode(response.body);

      if (res['status'] == 'success') {
        // Hapus path foto di prefs lokal
        await prefs.remove("foto");
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto berhasil dihapus!")));
        _loadProfileData(); // Reload biar avatar balik default
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal hapus: ${res['message']}")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error koneksi server: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 5. Fungsi buat nampilin Dialog Opsi (Ganti/Hapus)
  void _showFotoOptionsDialog() {
    // FIX: Pakai List<String>, bukan String[]
    List<String> options = ["Ganti Foto", "Hapus Foto"]; 
    
    showDialog(
      context: context,
      builder: (context) {
        // FIX: Pakai SimpleDialog biar gampang nampilin list pilihan
        return SimpleDialog(
          title: const Text("Pilihan Foto Profil", style: TextStyle(fontWeight: FontWeight.bold)),
          children: options.map((option) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                if (option == "Ganti Foto") {
                  _pickImage();
                } else if (option == "Hapus Foto") {
                  _deletePhoto();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  option,
                  style: TextStyle(
                    color: option == "Hapus Foto" ? Colors.red : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ==========================================
  // LOGIKA PREVIEW FOTO (FULL SCREEN & BISA DI-ZOOM)
  // ==========================================
  void _showImagePreview() {
    // Kalau avatarnya masih kosong (belum ada foto lokal & server), gak usah preview
    if (_imageFile == null && _photoUrl == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Background tembus pandang (gelap)
          insetPadding: const EdgeInsets.all(16), // Jarak dari pinggir HP
          child: Stack(
            alignment: Alignment.center,
            children: [
              // InteractiveViewer = Biar fotonya bisa di cubit (Zoom In/Out)
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0, // Maksimal zoom 4x
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16), // Bikin ujungnya agak tumpul dikit
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.contain)
                      : Image.network(_photoUrl!, fit: BoxFit.contain),
                ),
              ),
              
              // Tombol Silang (Close) di pojok kanan atas
              Positioned(
                top: -10,
                right: -10,
                child: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.white, size: 36),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // LOGIKA UPDATE DATA TEKS (NAMA & EMAIL)
  // ==========================================
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    String idCustomer = prefs.getString("id_customer") ?? "";

    try {
      // Panggil updateProfile.php (yang khusus teks)
      var response = await http.post(
        Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/updateProfile.php'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
        },
        body: {
          "id_customer": idCustomer,
          "nama_customer": _nameController.text,
          "email_customer": _emailController.text,
          "password": _passwordController.text,
        },
      );

      var res = jsonDecode(response.body);

      if (res['status'] == 'success') {
        await prefs.setString("nama_customer", _nameController.text);
        await prefs.setString("email_customer", _emailController.text);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil berhasil diupdate!")));
        _passwordController.clear();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal koneksi server: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true); // Biar tombolnya muter (opsional)

    try {
      // 1. Hapus Sesi Aplikasi (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 2. Hapus Sesi Google (Biar nanya akun lagi pas login)
      final GoogleSignIn googleSignIn = GoogleSignIn();
      bool isSignedIn = await googleSignIn.isSignedIn();
      if (isSignedIn) {
        await googleSignIn.signOut();
        // Kalau lu mau bener-bener "lupa" hapus aksesnya, bisa tambah ini:
        // await googleSignIn.disconnect(); 
      }

      if (!mounted) return;
      // 3. Pindah ke Login dan hapus riwayat halaman
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error logout: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E9FA6);
    const bgColor = Color(0xFFF5F5F5);

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: bgColor,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                // HEADER
                Container(
                  height: 180,
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF2E9FA6), Color(0xFF66BB6A)]),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/logotextputih.png', width: 100),
                      const SizedBox(height: 16),
                      const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // KONTEN UTAMA
                Padding(
                  padding: const EdgeInsets.only(top: 120, left: 16, right: 16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              // ==========================================
                              // LOGIKA AVATAR PROFIL (Tampil Gambar)
                              // ==========================================
                              InkWell(
                                onTap: _showFotoOptionsDialog, // DI KLIK MUNCUL OPSI
                                onLongPress: _showImagePreview, // DI TEKAN LAMA MUNCUL PREVIEW
                                child: Container(
                                  width: 70, height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade400, width: 2),
                                    
                                    // Logika prioritas nampilin gambar
                                    image: _imageFile != null
                                        // 1. Tampilkan lokal dulu kalau habis milih
                                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                                        : _photoUrl != null
                                            // 2. Kalau gak ada lokal, tampilkan URL server
                                            ? DecorationImage(image: NetworkImage(_photoUrl!), fit: BoxFit.cover)
                                            // 3. Kalau gak ada dua-duanya, kosong
                                            : null,
                                  ),
                                  // 4. Kalau kosong, tampilkan ikon default
                                  child: (_imageFile == null && _photoUrl == null)
                                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // FORM INPUT (Sama kayak kodingan lu)
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildTextField("Nama Kamu", _nameController, false),
                                    const SizedBox(height: 12),
                                    _buildTextField("example@gmail.com", _emailController, false),
                                    const SizedBox(height: 12),
                                    _buildTextField("Password Baru", _passwordController, true),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _updateProfile,
                                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                        child: _isLoading
                                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                            : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // TOMBOL LOGOUT
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text("Versi 1.0.0\nCopyright © 2025 Nganjuk Abirupa.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
      decoration: InputDecoration(hintText: hint, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 8), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2E9FA6), width: 2))),
    );
  }
}