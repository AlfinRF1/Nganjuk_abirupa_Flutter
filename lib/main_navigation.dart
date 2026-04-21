import 'package:flutter/material.dart';
// Import halaman-halaman kamu
import 'features/dashboard/dashboard_screen.dart';
import 'features/dashboard/riwayat_screen.dart';
import 'features/dashboard/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex; // Tambahin ini
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex; // Ubah jadi late

  @override
  void initState() {
    super.initState();
    // Set index awal sesuai kiriman (defaultnya tetap 0 kalau gak diisi)
    _selectedIndex = widget.initialIndex;
  }

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const DashboardScreen(),
    const RiwayatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack membuat semua halaman "standby", tapi hanya satu yang terlihat
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2E9FA6),
        unselectedItemColor: Colors.grey,
        // Cukup ubah state index, tampilan otomatis berubah tanpa pindah halaman (push)
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}