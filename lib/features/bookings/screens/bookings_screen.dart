import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/bookings_provider.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    
    // Veritabanından rezervasyonları dinliyoruz
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ÜST BAŞLIK VE YENİ REZERVASYON BUTONU ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rezervasyonlar', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -1)),
                      const SizedBox(height: 8),
                      const Text(
                        'Tur rezervasyonlarını, programları ve kapasite durumlarını yönetin.',
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
                    onPressed: () {
                      // İleride "Yeni Rezervasyon" formunu (Dialog) buraya bağlayacağız
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeni Rezervasyon Formu eklenecek.')));
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    label: const Text('Yeni Rezervasyon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- TAKVİM VE İSTATİSTİKLER (GRID YAPISI) ---
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildScheduleOverview(context)),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildCapacityStatCard(context),
                        const SizedBox(height: 24),
                        _buildPendingApprovalsCard(context),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildScheduleOverview(context),
                  const SizedBox(height: 24),
                  _buildCapacityStatCard(context),
                  const SizedBox(height: 24),
                  _buildPendingApprovalsCard(context),
                ],
              ),
            const SizedBox(height: 32),

            // --- SON REZERVASYONLAR TABLOSU (DİNAMİK VERİ) ---
            bookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Hata oluştu: $err')),
              data: (bookings) => _buildRecentReservationsTable(context, bookings),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET YARDIMCILARI ---

  Widget _buildScheduleOverview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Haftalık Program', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left, size: 20), constraints: const BoxConstraints(), padding: const EdgeInsets.all(4)),
                      const Text(' Ekim 2023 ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right, size: 20), constraints: const BoxConstraints(), padding: const EdgeInsets.all(4)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
                  .map((day) => Expanded(child: Center(child: Text(day, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)))))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCalendarDay(context, '28', true, []),
                _buildCalendarDay(context, '29', true, []),
                _buildCalendarDay(context, '1', false, [_buildCalendarEvent('Alpler Turu', '12/15', Colors.orange)]),
                _buildCalendarDay(context, '2', false, [
                  _buildCalendarEvent('Şehir Turu', 'Dolu', Theme.of(context).colorScheme.primary),
                  _buildCalendarEvent('Şarap Tadımı', '4/8', Colors.blueGrey),
                ]),
                _buildCalendarDay(context, '3', false, [_buildCalendarEvent('Nehir Turu', '20/40', Theme.of(context).colorScheme.primary)], isToday: true),
                _buildCalendarDay(context, '4', false, []),
                _buildCalendarDay(context, '5', false, [_buildCalendarEvent('Bakım', '', Colors.red)]),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDay(BuildContext context, String day, bool isFaded, List<Widget> events, {bool isToday = false}) {
    return Expanded(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isToday ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1) : (isFaded ? Colors.grey.shade50 : Colors.white),
          border: Border.all(color: isToday ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade200, width: isToday ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day, style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? Theme.of(context).colorScheme.primary : (isFaded ? Colors.grey : Colors.black87))),
            const SizedBox(height: 4),
            ...events,
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarEvent(String title, String capacity, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text('$title ${capacity.isNotEmpty ? '($capacity)' : ''}', style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildCapacityStatCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BUGÜNKÜ KAPASİTE', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('82%', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, height: 1)),
                const SizedBox(width: 8),
                const Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Dolu', style: TextStyle(color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: 0.82, backgroundColor: Colors.grey.shade200, color: Theme.of(context).colorScheme.primary, minHeight: 8, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('142 Yolcu', style: TextStyle(fontSize: 13, color: Colors.grey)), Text('3 Aktif Tur', style: TextStyle(fontSize: 13, color: Colors.grey))],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovalsCard(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Positioned(right: -20, top: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle))),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BEKLEYEN ONAYLAR', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.pending_actions, color: Colors.orange, size: 28)),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text('14', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1)), Text('İşlem Gerekiyor', style: TextStyle(fontSize: 13, color: Colors.grey))],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- DİNAMİK TABLO WIDGET'I ---
  Widget _buildRecentReservationsTable(BuildContext context, List<Map<String, dynamic>> bookings) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Son Rezervasyonlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Tümünü Gör')),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          // Tablo Başlıkları
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.grey.shade50,
            child: const Row(
              children: [
                Expanded(flex: 1, child: Text('Rez ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Müşteri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Tur', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 1, child: Text('Kişi Sayısı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 1, child: Text('Durum', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 1, child: Text('Ödeme', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          
          // Eğer veritabanı boşsa:
          if (bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('Henüz sisteme girilmiş bir rezervasyon kaydı bulunmuyor.', style: TextStyle(color: Colors.grey))),
            )
          else
            // Supabase'den gelen verileri map ile tablo satırlarına dönüştürüyoruz
            ...bookings.map((booking) {
              
              // Verileri Ayıklama (JOIN yapıldığı için müşteri ve tur adı dictionary içinde gelir)
              final String id = booking['id'].toString().substring(0, 5).toUpperCase();
              final String customerName = booking['customers'] != null ? booking['customers']['full_name'] : 'Bilinmeyen Müşteri';
              final String tourName = booking['tours'] != null ? booking['tours']['title'] : 'Bilinmeyen Tur';
              final String status = booking['status'] ?? 'Bekliyor';
              final String payment = booking['payment_status'] ?? 'Ödeme Bekliyor';
              final String pax = '${booking['pax_count']} Kişi';

              // İsim baş harflerini alma
              List<String> names = customerName.split(" ");
              String initials = names.isNotEmpty ? names[0][0].toUpperCase() : "M";
              if (names.length > 1) initials += names[names.length - 1][0].toUpperCase();

              // Duruma Göre Renk ve İkon Belirleme
              Color statusColor = Colors.orange;
              IconData paymentIcon = Icons.schedule;
              
              if (status.toLowerCase().contains('onaylandı')) {
                statusColor = Colors.green;
              } else if (status.toLowerCase().contains('iptal')) {
                statusColor = Colors.red;
              }

              if (payment.toLowerCase().contains('ödendi')) {
                paymentIcon = Icons.check_circle;
              } else if (payment.toLowerCase().contains('iade')) {
                paymentIcon = Icons.cancel;
              }

              return Column(
                children: [
                  _buildTableRow(context, '#RES-$id', customerName, initials, tourName, pax, status, statusColor, payment, paymentIcon),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, String id, String name, String initials, String tour, String pax, String status, Color statusColor, String payment, IconData paymentIcon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(id, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Text(initials, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(tour, style: const TextStyle(fontSize: 13, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 1, child: Text(pax, style: const TextStyle(fontSize: 13, color: Colors.black87))),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.2))),
                child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Icon(paymentIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(payment, style: TextStyle(fontSize: 13, color: statusColor), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}