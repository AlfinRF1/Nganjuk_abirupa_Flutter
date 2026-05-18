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
    String? pathDariDB = prefs.getString("foto"); 

    setState(() {
      _nameController.text = prefs.getString("nama_customer") ?? "";
      _emailController.text = prefs.getString("email") ?? ""; 

      // PENGAMAN ANTI-BADAI BUAT FOTO
      if (pathDariDB != null && pathDariDB.isNotEmpty) {
        String cleanPath = pathDariDB.trim();
        
        if (cleanPath.startsWith('http')) {
          _photoUrl = cleanPath; 
        } else {
          // FIX: Ditambahkan timestamp (?v=) di ujung URL biar Flutter dipaksa reload dari hosting, bukan cache!
          _photoUrl = "https://nganjukabirupa.pbltifnganjuk.com/profil/$cleanPath?v=${DateTime.now().millisecondsSinceEpoch}";
        }
        
        debugPrint("ALARM PROFIL: URL Foto Fix = $_photoUrl");
      } else {
        _photoUrl = null;
        debugPrint("ALARM PROFIL: pathDariDB kosong/null dari memori!");
      }
    });
  }

  // ==========================================
  // LOGIKA SISTEM FOTO PROFIL (PICK, CROP, UPLOAD)
  // ==========================================

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      
      if (pickedFile != null) {
        _cropImage(pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error milih gambar: $e")));
    }
  }

  Future<void> _cropImage(String filePath) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Foto Profil',
            toolbarColor: const Color(0xFF2E9FA6),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path); // Tampilkan lokal dulu
          _photoUrl = null; // Matiin URL server sementara
        });
        _uploadPhoto();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error crop gambar: $e")));
    }
  }

  Future<void> _uploadPhoto() async {
    if (_imageFile == null) return;

    final prefs = await SharedPreferences.getInstance();
    String idCustomer = prefs.getString("id_customer") ?? "";
    String token = prefs.getString("token") ?? "";

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/api/profile/update'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['id_customer'] = idCustomer; 

      request.files.add(
        await http.MultipartFile.fromPath('foto', _imageFile!.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var res = jsonDecode(response.body);
      
      if (res['status'] == 'success') {
        // FIX UTAMA: Simpan respon string foto baru dari Laravel ke SharedPreferences
        await prefs.setString("foto", res['foto']);
        
        setState(() {
          _imageFile = null; // Bersihkan temporary file lokal biar beralih ke NetworkImage
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto berhasil diupdate!")));
        _loadProfileData(); // Panggil ulang untuk generate URL baru + timestamp
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${res['message']}")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error koneksi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    String idCustomer = prefs.getString("id_customer") ?? "";
    String token = prefs.getString("token") ?? "";

    setState(() => _isLoading = true);

    try {
      var response = await http.post(
        Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/api/profile/hapus-foto'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {'id_customer': idCustomer},
      );

      var res = jsonDecode(response.body);

      if (res['status'] == 'success') {
        await prefs.setString("foto", ""); // Set string kosong di lokal pref, jangan di-remove total
        setState(() {
          _imageFile = null;
          _photoUrl = null;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto berhasil dihapus!")));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${res['message']}")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error server: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFotoOptionsDialog() {
    List<String> options = ["Ganti Foto", "Hapus Foto"]; 
    
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Pilihan Foto Profil", style: TextStyle(fontWeight: FontWeight.bold)),
          children: options.map((option) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
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

  void _showImagePreview() {
    if (_imageFile == null && _photoUrl == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.contain)
                      : Image.network(
                          _photoUrl!, 
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100, color: Colors.white),
                        ),
                ),
              ),
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

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    String idCustomer = prefs.getString("id_customer") ?? "";
    String token = prefs.getString("token") ?? "";

    try {
      var response = await http.post(
        Uri.parse('https://nganjukabirupa.pbltifnganjuk.com/api/profile/update'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
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
        await prefs.setString("email", _emailController.text);
        
        // FIX TAMBAHAN: Di fungsi update teks, kalau server ngasih respon data foto, ikut simpan juga biar sinkron
        if (res['data'] != null && res['data']['foto'] != null) {
          await prefs.setString("foto", res['data']['foto']);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil berhasil diupdate!")));
        _passwordController.clear();
        _loadProfileData(); // Reload data biar UI refresh total
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Gagal Update")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal koneksi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final GoogleSignIn googleSignIn = GoogleSignIn();
      bool isSignedIn = await googleSignIn.isSignedIn();
      if (isSignedIn) {
        await googleSignIn.signOut();
      }

      if (!mounted) return;
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
                              InkWell(
                                onTap: _showFotoOptionsDialog,
                                onLongPress: _showImagePreview,
                                child: Container(
                                  width: 70, height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade400, width: 2),
                                    image: _imageFile != null
                                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                                        : _photoUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(_photoUrl!), 
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                  ),
                                  child: (_imageFile == null && _photoUrl == null)
                                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
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