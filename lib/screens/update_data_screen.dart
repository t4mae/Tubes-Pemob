import 'package:flutter/material.dart';
import '../models/growth.dart';
import '../data/growth_data.dart';

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

  final Color primaryBlue = const Color(0xFF2196F3);
  final Color secondaryOrange = const Color(0xFFFFAE00);

  void _saveData() {
    if (!_formKey.currentState!.validate()) return;

    final growth = Growth(
      date: DateTime.now(),
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      headCirc: double.parse(_headController.text),
    );

    GrowthData.logs.add(growth);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: primaryBlue,
        content: const Text("Data perkembangan berhasil disimpan!"),
      ),
    );

    _weightController.clear();
    _heightController.clear();
    _headController.clear();
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text("Update Perkembangan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              _buildField("Berat Badan (kg)", _weightController),
              const SizedBox(height: 20),
              _buildField("Tinggi/Panjang Badan (cm)", _heightController),
              const SizedBox(height: 20),
              _buildField("Lingkar Kepala (cm)", _headController),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
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
