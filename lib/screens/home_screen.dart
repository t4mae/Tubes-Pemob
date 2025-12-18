import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/who.dart';
import '../screens/add_child_screen.dart';
import '../services/who_service.dart';
import '../services/growth_service.dart';
import '../widgets/growth_chart.dart';

import '../data/child_data.dart';
import '../models/child.dart';
import '../models/growth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final Color primaryBlue = const Color(0xFF254EDB);
  final Color secondaryOrange = const Color(0xFFFFAE00);

  final GrowthService _growthService = GrowthService();

  bool _isLoadingChildren = true;
  Growth? _lastGrowth;
  List<Growth> _growthData = [];
  List<WhoData> _whoBerat = [];
  List<WhoData> _whoPanjang = [];
  List<WhoData> _whoKepala = [];

Future<void> _loadChartData(Child? child) async {
  if (ChildData.currentChild == null && child == null) return;
  
  if(child != null) {
    ChildData.currentChild = child;
  }
  final childId = ChildData.currentChild!.id;
  final gender = ChildData.currentChild!.gender;

  if (childId == null) return;

  try {
    final growths = await _growthService.getGrowths(childId);
    final whoBerat = await WhoService.loadBerat(gender);
    final whoPanjang = await WhoService.loadTinggi(gender);
    final whoKepala = await WhoService.loadKepala(gender);

    setState(() {
      _growthData = growths;
      _whoBerat = whoBerat;
      _whoPanjang = whoPanjang;
      _whoKepala = whoKepala;
    });
  } catch (e) {
    debugPrint("Error loading chart data: $e");
    // handle error or show message
  }
}

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() => _isLoadingChildren = true);
    await ChildData.loadAllChildren();
    setState(() => _isLoadingChildren = false);

    _loadChartData(null);

    if (ChildData.currentChild != null && ChildData.currentChild!.id != null) {
      _loadLastGrowth(ChildData.currentChild!.id!);
    }
  }

  Future<void> _loadLastGrowth(String childId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final result = await _growthService.getGrowths(childId);

    if (result.isNotEmpty) {
      final data = result.last;

      setState(() {
        _lastGrowth = data;
      });
    } else {
      setState(() {
        _lastGrowth = null;
      });
    }
  }

  int _usia(DateTime birth) {
    return DateTime.now().difference(birth).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final childrens = ChildData.childrenList;

    return RefreshIndicator(
      onRefresh: () async {
        await _loadChildren();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: _isLoadingChildren
            ? const Center(child: CircularProgressIndicator())
            : ValueListenableBuilder<Child?>(
                valueListenable: ChildData.currentChildNotifier,
                builder: (context, currentChild, _) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(childrens, context, currentChild),
                        const SizedBox(height: 10),
                        _buildSummaryRow(),
                        const SizedBox(height: 10),
                        _buildChartContainer(currentChild),
                        const SizedBox(height: 15),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildHeader(List<Child> children, BuildContext context, Child? currentChild) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 45, 20, 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [Color(0xFF3E5CF7), Color(0xFF254EDB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo Parents!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                  ),
                  const Text(
                    "Selamat datang di SiGizi",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Profil Anak",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (children.isNotEmpty)
                _buildChildSelector(children, currentChild),
            ],
          ),
          const SizedBox(height: 12),
          _buildProfileCard(children, context, currentChild),
        ],
      ),
    );
  }

  Widget _buildChildSelector(List<Child> children, Child? currentChild) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentChild?.id,
          dropdownColor: primaryBlue,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          items: children.map((Child child) {
            return DropdownMenuItem<String>(
              value: child.id,
              child: Text(
                child.name,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: (String? newId) {
            if (newId != null) {
              final selectedChild = children.firstWhere((c) => c.id == newId);
              ChildData.currentChild = selectedChild; // Notifier triggers update
              _loadChartData(selectedChild);
              _loadLastGrowth(selectedChild.id!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard(List<Child> children, BuildContext context, Child? activeChild) {
    if (children.isEmpty || activeChild == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.child_care, size: 40, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            const Text(
              "Belum Ada Profil Anak",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tambahkan profil anak Anda untuk mulai memantau tumbuh kembangnya.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final result = await Navigator.pushNamed(context, "/add_child", arguments: user.uid);
                    if (result == true) _loadChildren();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text("Tambah Profil Baru", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EFFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        activeChild.gender.trim().toUpperCase() == "L" 
                          ? "assets/boy.png" 
                          : "assets/girl.png",
                        key: ValueKey("${activeChild.id}_${activeChild.gender}"), 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 30),
                                Text(
                                  "Failed!",
                                  style: TextStyle(fontSize: 8, color: Colors.red.shade900),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeChild.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                          _buildBadge(
                            activeChild.gender.trim().toUpperCase() == "L" ? "Laki-laki" : "Perempuan",
                            activeChild.gender.trim().toUpperCase() == "L" ? Colors.blue : Colors.pink,
                          ),
                            const SizedBox(width: 8),
                            _buildBadge(
                                "${_usia(activeChild.birthDate)} Hari",
                                Colors.orange
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final result = await Navigator.pushNamed(context, "/add_child", arguments: user.uid);
                        if (result == true) _loadChildren();
                      }
                    },
                    icon: Icon(Icons.add_circle, color: primaryBlue, size: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _summaryCard(index: 0, label: "Berat", value: _lastGrowth != null ? "${_lastGrowth!.weight} kg" : "~ kg", icon: "assets/berat.svg"),
            const SizedBox(width: 10),
            _summaryCard(index: 1, label: "Tinggi", value: _lastGrowth != null ? "${_lastGrowth!.height} cm" : "~ cm", icon: "assets/tinggi.svg"),
            const SizedBox(width: 10),
            _summaryCard(index: 2, label: "L. Kepala", value: _lastGrowth != null ? "${_lastGrowth!.headCirc} cm" : "~ cm", icon: "assets/head.svg"),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({required int index, required String label, required String value, required String icon}) {
    final active = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        width: 115,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? secondaryOrange.withOpacity(.2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? secondaryOrange : Colors.grey.shade300, width: active ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Container(
              height: 40,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: active ? secondaryOrange.withOpacity(.6) : Colors.grey.shade100,
              ),
              child: Center(child: SvgPicture.asset(icon, height: 24)),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(value, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContainer(Child? currentChild) {
    if (currentChild == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 370,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: const Center(child: Text("Grafik WHO akan tampil di sini", style: TextStyle(color: Colors.black54))),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), 
      child: GrowthCharts(
        index: selectedIndex,
        growths: _growthData,
        whoWeight: _whoBerat,
        whoHeight: _whoPanjang,
        whoHead: _whoKepala,
        childName: currentChild?.name ?? "Anak",
        birthDate: currentChild?.birthDate ?? DateTime.now(),
      ),
    );
  }

}
