import 'package:flutter/material.dart';
import 'package:sigizi/screens/edukasi_screen.dart';
import 'package:sigizi/screens/home_screen.dart';
import 'package:sigizi/screens/update_data_screen.dart';
import 'package:sigizi/screens/kalender_screen.dart';
import 'package:sigizi/screens/profil_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const EdukasiScreen(),
    const UpdateDataScreen(),
    const KalenderScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _pages[_selectedIndex],

          // NAVBAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: (index) {
                if (index == 2) return; // index 2 = tombol bulat → tidak trigger tap default
                _onItemTapped(index);
              },
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book),
                  label: "Edukasi",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.circle, color: Colors.transparent), // dummy
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: "Kalender",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profil",
                ),
              ],
            ),
          ),

          // TOMBOL BULAT TENGAH (DANA STYLE)
          Positioned(
            bottom: 26, // naik sedikit dari navbar
            child: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.data_saver_on_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
