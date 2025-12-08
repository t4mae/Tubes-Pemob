import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/child_data.dart';
import '../models/child.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final Color primaryBlue = const Color(0xFF254EDB);
  final Color secondaryOrange = const Color(0xFFFFAE00);

  @override
  Widget build(BuildContext context) {
    final child = ChildData.currentChild;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(child, context),
            const SizedBox(height: 18),
            _buildSummaryRow(),
            const SizedBox(height: 25),
            _buildChartContainer(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER (Sudah diperkecil & dibuat mirip Figma)
  // ------------------------------------------------------------
  Widget _buildHeader(Child? child, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 45, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [
            Color(0xFF3E5CF7),
            Color(0xFF254EDB),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Halo King!",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            "Profil Anak",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          _buildProfileCard(child, context)
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PROFILE CARD (diperkecil, dibuat layaknya Figma)
  // ------------------------------------------------------------
  Widget _buildProfileCard(Child? child, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // BAYI ICON
          Image.asset(
            "assets/bayi_home.jpg",
            height: 70,
          ),
          const SizedBox(width: 14),

          // TEXT & BUTTON
          Expanded(
            child: child == null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Geser teks lebih ke kanan → pakai padding kiri sedikit
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: const Text(
                    "Kamu belum punya profil anak",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // BUTTON DIPERKECIL
                // BUTTON DIPERBAIKI AGAR PANJANG DAN RATA KIRI
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55, // ← tombol lebih panjang
                    height: 30, // ← kecil elegan seperti Figma
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, "/add_child"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Tambah Anak",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(child.gender == "L" ? "Laki-laki" : "Perempuan"),
                Text("Usia: ${_usia(child.birthDate)} hari"),
              ],
            ),
          ),
        ],
      ),
    );
  }


  int _usia(DateTime birth) {
    return DateTime.now().difference(birth).inDays;
  }

  // ------------------------------------------------------------
  // SUMMARY ROW (LATAR PANJANG DI BELAKANG ICON)
  // ------------------------------------------------------------
  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _summaryCard(
            index: 0,
            label: "Berat",
            value: "~ kg",
            icon: "assets/berat.svg",
          ),
          _summaryCard(
            index: 1,
            label: "Tinggi",
            value: "~ cm",
            icon: "assets/tinggi.svg",
          ),
          _summaryCard(
            index: 2,
            label: "L. Kepala",
            value: "~ cm",
            icon: "assets/head.svg",
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SUMMARY ITEM (FULL Figma Style)
  // ------------------------------------------------------------
  Widget _summaryCard({
    required int index,
    required String label,
    required String value,
    required String icon,
  }) {
    final active = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        width: 115,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? secondaryOrange.withOpacity(.2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? secondaryOrange : Colors.grey.shade300,
            width: active ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          children: [
            // Icon background panjang horizontal
            Container(
              height: 40,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: active
                    ? secondaryOrange.withOpacity(.6)
                    : Colors.grey.shade100,
              ),
              child: Center(
                child: SvgPicture.asset(icon, height: 24),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CHART CONTAINER
  // ------------------------------------------------------------
  Widget _buildChartContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 370,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: const Center(
          child: Text(
            "Grafik WHO akan tampil di sini",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
