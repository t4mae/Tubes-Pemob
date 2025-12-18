import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sigizi/screens/add_child_screen.dart';
import 'package:sigizi/widgets/bottom_nav.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SiGiziApp());
}

class SiGiziApp extends StatelessWidget {
  const SiGiziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser != null
          ? const BottomNav()
          : const LoginScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/add_child') {
          final userId = settings.arguments as String; // ambil argument
          return MaterialPageRoute(
            builder: (context) => AddChildScreen(userId: userId),
          );
        }
        return null; // route lain bisa ditambahkan di sini
      },
    );
  }
}
