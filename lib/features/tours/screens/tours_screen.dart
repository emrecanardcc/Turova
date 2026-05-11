import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için gerekli, pubspec'te yoksa hata verebilir, ekleyeceğiz
import '../controllers/tours_provider.dart';

class ToursScreen extends ConsumerStatefulWidget {
  const ToursScreen({super.key});

  @override
  ConsumerState<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends ConsumerState<ToursScreen> {
  // Yeni Tur Ekleme Dialogu
  void _showAddTourDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final capacityController = TextEditingController();
    final priceController = TextEditingController();
    DateTime? selectedStartDate;
    DateTime? selectedEndDate;

    // Tarih seçici fonksiyon
    Future<void> pickDate(bool isStart, StateSetter setState) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 2),
      );
      if (picked != null) {
        setState(() {
          if (isStart) {
            selectedStartDate = picked;
          } else {
            selectedEndDate = picked;
          }
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Yeni Tur Oluştur'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tur Adı (Örn: Kapadokya)')),
                    TextField(controller: descController, decoration: const InputDecoration(labelText: 'Kısa Açıklama'), maxLines: 2),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: capacityController, decoration: const InputDecoration(labelText: 'Kontenjan (Kişi)'), keyboardType: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Kişi Başı Fiyat (₺)'), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => pickDate(true, setState),
                          icon: const Icon(Icons.date_range),
                          label: Text(selectedStartDate != null ? DateFormat('dd/MM/yyyy').format(selectedStartDate!) : 'Başlangıç Seç'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => pickDate(false, setState),
                          icon: const Icon(Icons.date_range),
                          label: Text(selectedEndDate != null ? DateFormat('dd/MM/yyyy').format(selectedEndDate!) : 'Bitiş Seç'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
                FilledButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty && selectedStartDate != null && selectedEndDate != null && capacityController.text.isNotEmpty && priceController.text.isNotEmpty) {
                      await ref.read(toursActionProvider).addTour(
                        title: titleController.text,
                        description: descController.text,
                        startDate: selectedStartDate!,
                        endDate: selectedEndDate!,
                        capacity: int.parse(capacityController.text),
                        price: double.parse(priceController.text),
                      );
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Oluştur'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final toursAsync = ref.watch(toursProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turlar Yönetimi'),
      ),
      body: toursAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
        data: (tours) {
          if (tours.isEmpty) {
            return const Center(child: Text('Henüz planlanmış bir tur yok.', style: TextStyle(fontSize: 18)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = tours[index];
              final startDate = DateTime.parse(tour['start_date']);
              final endDate = DateTime.parse(tour['end_date']);
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.map, size: 30),
                  ),
                  title: Text(tour['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Tarih: ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}'),
                      Text('Kontenjan: 0 / ${tour['capacity']} Kişi'), // İleride dolan kontenjanı buraya bağlayacağız
                    ],
                  ),
                  trailing: Text(
                    '₺${tour['price_per_person']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                  ),
                  onTap: () {
                    // İleride tur detay sayfasına gidecek
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTourDialog(context),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Yeni Tur Planla'),
      ),
    );
  }
}