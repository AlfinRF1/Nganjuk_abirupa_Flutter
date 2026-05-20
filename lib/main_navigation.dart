import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_screen.dart'; 
import 'features/dashboard/riwayat_screen.dart';
import 'features/dashboard/profile_screen.dart'; 

// 👇 PASTIKAN NAMANYA MAPAN SEPERTI INI
class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({
    super.key, 
    this.initialIndex = 0, 
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; 
    // Hubungkan PageController dengan index awal dari rute main.dart
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          DashboardScreen(), // Index 0
          RiwayatScreen(),   // Index 1
          ProfileScreen(),   // Index 2
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2E9FA6), // Warna cyan andalan lu
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}