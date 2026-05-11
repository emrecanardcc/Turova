import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/companies_provider.dart';

class CompaniesScreen extends ConsumerWidget {
  const CompaniesScreen({super.key});

  void _showAddCompanyDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedColor = '#FF5733'; // Varsayılan renk

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Tur Şirketi Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Şirket Adı'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telefon Numarası'),
              keyboardType: TextInputType.phone,
            ),
            // Renk ve Logo yükleme kısımlarını daha sonra detaylı ekleyeceğiz
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await ref.read(companiesActionProvider).addCompany(
                  nameController.text,
                  phoneController.text,
                  selectedColor,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(companiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteri Şirketler'),
      ),
      body: companiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
        data: (companies) {
          if (companies.isEmpty) {
            return const Center(child: Text('Henüz kayıtlı bir şirket yok.'));
          }
          return ListView.builder(
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final comp = companies[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(int.parse(comp['theme_color'].toString().replaceFirst('#', '0xff'))),
                  child: Text(comp['name'][0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
                title: Text(comp['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(comp['owner_phone'] ?? 'Telefon yok'),
                trailing: Switch(
                  value: comp['is_active'],
                  onChanged: (val) {
                    // İleride hesabı dondurma işlemi buraya gelecek
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCompanyDialog(context, ref),
        icon: const Icon(Icons.add_business),
        label: const Text('Şirket Ekle'),
      ),
    );
  }
}