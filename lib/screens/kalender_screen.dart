import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child.dart';
import '../models/growth.dart';
import '../services/growth_service.dart';
import '../data/child_data.dart';

class KalenderScreen extends StatefulWidget {
  const KalenderScreen({super.key});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  Child? selectedChild;
  List<Growth> _growths = [];
  final GrowthService _growthService = GrowthService();
  bool _isLoading = false;
  bool _isSyncing = false;

  final Color primaryBlue = const Color(0xFF254EDB);

  @override
  void initState() {
    super.initState();
    _initializeData();
    ChildData.currentChildNotifier.addListener(_onChildChanged);
  }

  @override
  void dispose() {
    ChildData.currentChildNotifier.removeListener(_onChildChanged);
    super.dispose();
  }

  void _onChildChanged() {
    if (mounted) {
      setState(() {
        selectedChild = ChildData.currentChild;
      });
      _fetchGrowths();
    }
  }

  Future<void> _initializeData() async {
    if (ChildData.childrenList.isEmpty) {
      setState(() => _isSyncing = true);
      await _loadChildrenFromFirestore();
    }
    
    selectedChild = ChildData.currentChild;
    if (selectedChild != null) {
      _fetchGrowths();
    }
    setState(() => _isSyncing = false);
  }

  Future<void> _loadChildrenFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('children')
          .get();

      ChildData.childrenList = snapshot.docs.map((doc) {
        return Child.fromMap(doc.data(), doc.id);
      }).toList();

      if (ChildData.childrenList.isNotEmpty && ChildData.currentChild == null) {
        ChildData.currentChild = ChildData.childrenList.first;
      }
    } catch (e) {
      debugPrint("Error loading children in Kalender: $e");
    }
  }

  Future<void> _fetchGrowths() async {
    if (selectedChild == null || selectedChild!.id == null) return;

    if (mounted) setState(() => _isLoading = true);
    try {
      final growths = await _growthService.getGrowths(selectedChild!.id!);
      if (mounted) {
        setState(() {
          _growths = growths;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching growths: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Growth? _getGrowthForMonth(int month) {
    if (selectedChild == null) return null;
    
    // Showcase Mode: Urutan input menentukan bulan (Data ke-1 = Bulan 1, dst)
    // Ini juga membuat kalender konsisten dengan grafik yang menggunakan index + 1
    if (month > 0 && month <= _growths.length) {
      return _growths[month - 1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final children = ChildData.childrenList;


    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isSyncing 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildHeader(children),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildCalendarGrid(),
              ),
            ],
          ),
    );
  }

  Widget _buildHeader(List<Child> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 45, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue.withOpacity(0.9), primaryBlue],
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
              const Text(
                "Kalender Pengukuran",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (selectedChild != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Kamu dapat klik untuk meng-edit data",
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }


  Widget _buildCalendarGrid() {
    if (selectedChild == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("Silakan pilih profil anak terlebih dahulu", style: TextStyle(color: Colors.black54)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 60,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        final month = index + 1;
        final growth = _getGrowthForMonth(month);
        final isMeasured = growth != null;

        return GestureDetector(
          onTap: () {
            if (isMeasured) {
              _showEditDialog(growth, month);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(
                color: isMeasured ? Colors.green.withOpacity(0.3) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Bulan $month",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isMeasured ? Colors.green.shade700 : Colors.black87,
                        ),
                      ),
                      if (isMeasured)
                        const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMeasured ? "Terukur pada:" : "Status:",
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                      Text(
                        isMeasured 
                            ? DateFormat('dd MMM yyyy').format(growth.date)
                            : "Belum diisi",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isMeasured ? Colors.black87 : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(Growth growth, int month) {
    final weightController = TextEditingController(text: growth.weight.toString());
    final heightController = TextEditingController(text: growth.height.toString());
    final headController = TextEditingController(text: growth.headCirc.toString());
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Data Bulan $month",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildEditField("Berat Badan (kg)", weightController),
              const SizedBox(height: 16),
              _buildEditField("Tinggi Badan (cm)", heightController),
              const SizedBox(height: 16),
              _buildEditField("Lingkar Kepala (cm)", headController),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    setModalState(() => isSaving = true);
                    
                    final updatedGrowth = Growth(
                      id: growth.id,
                      childId: growth.childId,
                      date: growth.date,
                      weight: double.tryParse(weightController.text) ?? growth.weight,
                      height: double.tryParse(heightController.text) ?? growth.height,
                      headCirc: double.tryParse(headController.text) ?? growth.headCirc,
                    );

                    try {
                      await _growthService.updateGrowth(updatedGrowth);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Data berhasil diperbarui!")),
                        );
                        _fetchGrowths();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        setModalState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gagal memperbarui: $e")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Simpan Perubahan", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
