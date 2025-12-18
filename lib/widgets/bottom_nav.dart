import 'package:flutter/material.dart';
import '../screens/edukasi_screen.dart';
import '../screens/home_screen.dart';
import '../screens/update_data_screen.dart';
import '../screens/kalender_screen.dart';
import '../screens/profil_screen.dart';

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
      // resizeToAvoidBottomInset false membantu menghindari overflow saat keyboard muncul
      // namun di sini kita gunakan stack, jadi halaman mungkin berada di belakang nav bar
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Padding bawah agar konten halaman tidak tertutup Nav Bar
          // Kita gunakan posisi 0 di Stack tapi bungkus halamannya
          Positioned.fill(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),

          // NAVBAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
                onTap: (index) {
                  if (index == 2) return; // index 2 = tombol bulat → tidak trigger tap default
                  _onItemTapped(index);
                },
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
                backgroundColor: Colors.white,
                elevation: 0,
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
                    icon: Icon(Icons.circle, color: Colors.transparent), // dummy spacer
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
          ),

          // TOMBOL BULAT TENGAH (DANA STYLE)
          Positioned(
            bottom: 25, // Sesuaikan agar pas dengan Nav Bar
            child: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.data_saver_on_rounded,
                  size: 40,
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
