// lib/screens/register_screen.dart
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: panggil API register bila ada
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil. Silakan login.')),
      );
      Navigator.pop(context); // kembali ke Login
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Daftar'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Masukkan data diri Anda!',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),

                Text('Nama Lengkap',
                    style: theme.textTheme.labelMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameC,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama lengkap',
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                Text('Email', style: theme.textTheme.labelMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan email',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email wajib diisi';
                    final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(v);
                    return ok ? null : 'Format email tidak valid';
                  },
                ),
                const SizedBox(height: 16),

                Text('Password', style: theme.textTheme.labelMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passC,
                  obscureText: _obscure1,
                  decoration: InputDecoration(
                    hintText: 'Masukkan password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'Minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text('Konfirmasi Password', style: theme.textTheme.labelMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmC,
                  obscureText: _obscure2,
                  decoration: InputDecoration(
                    hintText: 'Konfirmasi password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                  validator: (v) =>
                  v != _passC.text ? 'Password tidak sama' : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _onSubmit,
                    child: const Text('Daftar'),
                  ),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Sudah punya akun? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
