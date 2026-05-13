import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/tours_provider.dart';

class ToursScreen extends ConsumerStatefulWidget {
  const ToursScreen({super.key});

  @override
  ConsumerState<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends ConsumerState<ToursScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Tüm Turlar', 'Aktif Turlar', 'Tam Dolu', 'Tamamlananlar'];

  // Eski ekleme diyaloğumuzu modern tasarıma uyarlıyoruz
  void _showAddTourDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final capacityController = TextEditingController();
    final priceController = TextEditingController();
    DateTime? selectedStartDate;
    DateTime? selectedEndDate;

    Future<void> pickDate(bool isStart, StateSetter setState) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 2),
      );
      if (picked != null) {
        setState(() {
          if (isStart) selectedStartDate = picked;
          else selectedEndDate = picked;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Yeni Tur Oluştur', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tur Adı (Örn: Kapadokya)')),
                    const SizedBox(height: 12),
                    TextField(controller: descController, decoration: const InputDecoration(labelText: 'Kısa Açıklama'), maxLines: 2),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: capacityController, decoration: const InputDecoration(labelText: 'Kontenjan'), keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Fiyat (₺)'), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, foregroundColor: Colors.black87),
                            onPressed: () => pickDate(true, setState),
                            icon: const Icon(Icons.date_range, size: 18),
                            label: Text(selectedStartDate != null ? DateFormat('dd/MM/yyyy').format(selectedStartDate!) : 'Başlangıç'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, foregroundColor: Colors.black87),
                            onPressed: () => pickDate(false, setState),
                            icon: const Icon(Icons.date_range, size: 18),
                            label: Text(selectedEndDate != null ? DateFormat('dd/MM/yyyy').format(selectedEndDate!) : 'Bitiş'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
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
    final size = MediaQuery.of(context).size;
    
    // Responsive grid ayarlaması
    int crossAxisCount = 1;
    if (size.width > 1200) crossAxisCount = 3;
    else if (size.width > 800) crossAxisCount = 2;

    return Scaffold(
      body: toursAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
        data: (tours) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(size.width > 800 ? 32.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ÜST BİLGİ VE BUTON ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tur Yönetimi', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -1)),
                          const SizedBox(height: 8),
                          const Text(
                            'Operasyonel turlarınızı, müsaitlik durumlarını ve yolcu listelerini buradan yönetin.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1CA9C9), Color(0xFF1698B5)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: const Color(0xFF1CA9C9).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                        onPressed: () => _showAddTourDialog(context),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Yeni Tur Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // --- FİLTRE BUTONLARI ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_filters.length, (index) {
                      final isSelected = _selectedFilterIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: ChoiceChip(
                          label: Text(_filters[index]),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedFilterIndex = index);
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                          labelStyle: TextStyle(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade200),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                // --- TURLAR LİSTESİ (GRID) ---
                if (tours.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 64.0),
                    child: Center(child: Text('Henüz planlanmış bir tur yok. Sağ üstten yeni tur ekleyebilirsiniz.', style: TextStyle(fontSize: 16, color: Colors.grey))),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.85, // Kartların yükseklik oranı
                    ),
                    itemCount: tours.length,
                    itemBuilder: (context, index) {
                      final tour = tours[index];
                      return _buildTourCard(context, tour);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- TUR KARTI WIDGET'I ---
  Widget _buildTourCard(BuildContext context, Map<String, dynamic> tour) {
    final startDate = DateTime.parse(tour['start_date']);
    final int capacity = tour['capacity'];
    final double price = tour['price_per_person'];
    // Şimdilik test için rastgele doluluk oranı veriyoruz. (İleride Bookings tablosundan sayacağız)
    final int currentBookings = 0; 
    final double progress = capacity > 0 ? (currentBookings / capacity) : 0;
    
    // Geçici şık bir görsel (Veritabanında image_url olana kadar)
    const fallbackImage = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1000&auto=format&fit=crop';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ÜST KISIM: GÖRSEL VE BADGE
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(fallbackImage, fit: BoxFit.cover),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text('Aktif', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          
          // ALT KISIM: DETAYLAR
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tour['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(DateFormat('dd MMM yyyy').format(startDate), style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.sell, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('₺${price.toStringAsFixed(0)} / Kişi', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // KAPASİTE ÇUBUĞU
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('DOLULUK ORANI', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      Text('$currentBookings/$capacity Dolu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    color: Theme.of(context).colorScheme.primary,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // BUTONLAR
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                            elevation: 0,
                          ),
                          onPressed: () {},
                          child: const Text('Detayları Gör'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}