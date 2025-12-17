// C:/Users/LENOVO/StudioProjects/SiGizi/lib/screens/profil_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sigizi/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _namaLengkap;
  String? _email;
  String? _phone;
  String? _photoURL;

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUser != null) {
      final email = _currentUser!.email;

      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (mounted && docSnapshot.exists) {
          final data = docSnapshot.data()!;
          setState(() {
            _email = email;
            _namaLengkap = data['fullName'] ?? 'Nama tidak ditemukan';
            _phone = data['phone'] ?? '';
            _photoURL = data['photoURL'];
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Profile"),
      ),
      body: _namaLengkap == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (_photoURL != null && _photoURL!.isNotEmpty)
                  ? NetworkImage(_photoURL!)
                  : null,
              child: (_photoURL == null || _photoURL!.isEmpty)
                  ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              _namaLengkap ?? "Nama Pengguna",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              _email ?? "email@example.com",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(height: 16.0 * 2),
            Info(
              infoKey: "Nama Lengkap",
              info: _namaLengkap ?? "...",
            ),
            Info(
              infoKey: "Email",
              info: _email ?? "...",
            ),
            Info(
              infoKey: "Phone",
              info: _phone != null && _phone!.isNotEmpty ? _phone! : 'Belum diatur',
            ),
            const Info(
              infoKey: "Password",
              info: "••••••••",
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 160,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
                    _loadUserData();
                  },
                  child: const Text("Edit profile"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Info extends StatelessWidget {
  const Info({
    super.key,
    required this.infoKey,
    required this.info,
  });

  final String infoKey, info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            infoKey,
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color!
                  .withOpacity(0.8),
            ),
          ),
          Text(info),
        ],
      ),
    );
  }
}
