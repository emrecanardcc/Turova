import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turova/features/auth/controllers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Supabase client'a erişim
    final supabase = ref.watch(supabaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turova Ana Panel', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // ÇIKIŞ YAP BUTONU
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              await supabase.auth.signOut();
              // Çıkış yapınca GoRouter bizi otomatik olarak Login'e atacak!
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_customize, size: 80, color: Colors.blueGrey),
            SizedBox(height: 24),
            Text(
              'Hoş Geldin, Kurucu! 👑',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Sistemin altyapısı tıkır tıkır çalışıyor.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}