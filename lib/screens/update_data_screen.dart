import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/child.dart';
import '../models/growth.dart';
import '../services/growth_service.dart';
import '../data/child_data.dart';

class UpdateDataScreen extends StatefulWidget {
  const UpdateDataScreen({super.key});

  @override
  State<UpdateDataScreen> createState() => _UpdateDataScreenState();
}

class _UpdateDataScreenState extends State<UpdateDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headController = TextEditingController();

  final Color primaryBlue = const Color(0xFF254EDB);
  final Color secondaryOrange = const Color(0xFFFFAE00);

  final GrowthService _growthService = GrowthService();

  Child? _selectedChild;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedChild = ChildData.currentChild;
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
        _selectedChild = ChildData.currentChild;
      });
    }
  }

  void _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChild == null) return;
    if (_selectedChild!.id == null) return;

    setState(() => _isLoading = true);

    final growth = Growth(
      childId: _selectedChild!.id,
      date: DateTime.now(),
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      headCirc: double.parse(_headController.text),
    );

    try {
      await _growthService.addGrowth(_selectedChild!.id!, growth);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: primaryBlue,
            content: const Text("Data perkembangan berhasil disimpan!"),
          ),
        );
      }

      _weightController.clear();
      _heightController.clear();
      _headController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Gagal menyimpan: $e"),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryBlue),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryBlue),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "$label tidak boleh kosong";
        if (double.tryParse(v) == null) return "Masukkan angka yang valid";
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var children = ChildData.childrenList;


    // Safety check for dropdown value existence
    String? currentId = _selectedChild?.id;
    final bool valueExists = children.any((c) => c.id == currentId);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Update Perkembangan"),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tampilan Profil Anak Aktif (Read-only)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: primaryBlue.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.child_care, color: primaryBlue, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Mengupdate Data Untuk:",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            _selectedChild?.name ?? "Pilih Anak di Home",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildField("Berat Badan (kg)", _weightController),
              const SizedBox(height: 20),
              _buildField("Tinggi/Panjang Badan (cm)", _heightController),
              const SizedBox(height: 20),
              _buildField("Lingkar Kepala (cm)", _headController),
              const SizedBox(height: 40),
              SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Simpan Perkembangan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
