import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/customers_provider.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  
  // Müşteri Ekleme Dialogu
  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    bool smsAllowed = false;
    bool emailAllowed = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Yeni Müşteri Kartı Oluştur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Ad Soyad', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Telefon', prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'E-Posta (Opsiyonel)', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const Text('Pazarlama & İletişim İzinleri (KVKK)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                CheckboxListTile(
                  title: const Text('SMS gönderebilirsiniz', style: TextStyle(fontSize: 14)),
                  value: smsAllowed,
                  onChanged: (val) => setState(() => smsAllowed = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('E-Posta gönderebilirsiniz', style: TextStyle(fontSize: 14)),
                  value: emailAllowed,
                  onChanged: (val) => setState(() => emailAllowed = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            FilledButton(
              onPressed: () async {
                // Ad ve telefon zorunlu
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  await ref.read(customersActionProvider).addCustomer(
                    fullName: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                    isSmsAllowed: smsAllowed,
                    isEmailAllowed: emailAllowed,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteri Veritabanı (CRM)'),
      ),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(child: Text('Sistemde henüz müşteri kaydı bulunmuyor.', style: TextStyle(fontSize: 18)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    child: Text(customer['full_name'][0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer)),
                  ),
                  title: Text(customer['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(customer['phone']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // SMS İzni İkonu
                      Tooltip(
                        message: customer['is_sms_allowed'] ? 'SMS İzni Var' : 'SMS İzni Yok',
                        child: Icon(Icons.sms, color: customer['is_sms_allowed'] ? Colors.green : Colors.grey.shade300),
                      ),
                      const SizedBox(width: 12),
                      // E-Posta İzni İkonu
                      Tooltip(
                        message: customer['is_email_allowed'] ? 'E-Posta İzni Var' : 'E-Posta İzni Yok',
                        child: Icon(Icons.email, color: customer['is_email_allowed'] ? Colors.green : Colors.grey.shade300),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomerDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Yeni Müşteri'),
      ),
    );
  }
}