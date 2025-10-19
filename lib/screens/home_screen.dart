// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header gradien sederhana
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5E7BFF), Color(0xFF2F4BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo King!',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 12),
                    Text('Profil Anak', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.baby_changing_station, size: 40),
                          const SizedBox(width: 12),
                          const Expanded(child: Text('Kamu belum punya profil anak')),
                          FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Anak'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tiga kartu ringkas
              Row(
                children: [
                  _MetricCard(
                    label: 'Berat\n~ kg',
                    icon: Icons.image, // icon foto timbangan
                    highlighted: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  _MetricCard(
                    label: 'Tinggi\n~ cm',
                    icon: Icons.straighten,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  _MetricCard(
                    label: 'L. Kepala\n~ cm',
                    icon: Icons.hearing, // pakai icon pengganti
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // "Grafik WHO" (placeholder)
              Text('Grafik WHO', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE6D2A8)),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
                  ),
                  child: const Center(
                    child: Text('Area Grafik (placeholder)'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Konsultasi'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool highlighted;
  final VoidCallback onTap;

  const _MetricCard({
    required this.label,
    required this.icon,
    this.highlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlighted ? const Color(0xFFFFF2CF) : const Color(0xFFF5F5F5);
    final border = highlighted ? const Color(0xFFE8C472) : const Color(0xFFE0E0E0);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(alignment: Alignment.topLeft, child: Icon(icon, size: 20, color: Colors.black54)),
              const SizedBox(height: 20),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
