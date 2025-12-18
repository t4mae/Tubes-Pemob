// C:/Users/LENOVO/StudioProjects/SiGizi/lib/screens/add_child_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. IMPORT FIRESTORE
import 'package:intl/intl.dart'; // Untuk format tanggal

class AddChildScreen extends StatefulWidget {
  final String userId; // AddChildScreen wajib menerima userId
  const AddChildScreen({super.key, required this.userId});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  // 2. FUNGSI UNTUK MENYIMPAN DATA LANGSUNG KE FIRESTORE
  Future<void> _saveChildData() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tanggal lahir wajib diisi.')));
      return;
    }
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jenis kelamin wajib diisi.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Buat data Map untuk disimpan
      Map<String, dynamic> childData = {
        'name': _nameController.text.trim(),
        'birthDate': Timestamp.fromDate(_selectedDate!), // Gunakan Timestamp
        'gender': _selectedGender,
        'createdAt': Timestamp.now(),
      };

      // Simpan ke sub-koleksi 'children' milik pengguna yang sedang login
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId) // Gunakan userId yang diterima
          .collection('children')
          .add(childData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil anak berhasil ditambahkan!')),
        );
        // Kembali ke halaman sebelumnya dan kirim sinyal 'true' sebagai tanda sukses
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e')),
        );
      }
    } finally {
      // PASTIKAN LOADING SELALU BERHENTI
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Profil Anak"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap Anak'),
              validator: (v) =>
              v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _birthDateController,
              decoration: const InputDecoration(
                labelText: 'Tanggal Lahir',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration:
              const InputDecoration(labelText: 'Jenis Kelamin'),
              value: _selectedGender,
              items: const [
                DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                DropdownMenuItem(value: 'P', child: Text('Perempuan')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              validator: (v) =>
              v == null ? 'Jenis kelamin wajib dipilih' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChildData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
