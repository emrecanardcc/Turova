import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tours/controllers/tours_provider.dart';
import '../../customers/controllers/customers_provider.dart';
import '../../finance/controllers/finance_provider.dart';
import '../../bookings/controllers/bookings_provider.dart';

// Dashboard için tüm verileri toplayıp özet istatistikler üreten birleştirici Provider
final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Tüm modüllerden verileri asenkron olarak çekiyoruz
  final tours = await ref.watch(toursProvider.future);
  final customers = await ref.watch(customersProvider.future);
  final finance = await ref.watch(financeProvider.future);
  final bookings = await ref.watch(bookingsProvider.future);

  final now = DateTime.now();
  
  // 1. Aktif (Gelecekteki) Turları Bulma
  final activeTours = tours.where((t) {
    final startDate = DateTime.tryParse(t['start_date'] ?? '') ?? now;
    return startDate.isAfter(now) || startDate.isAtSameMomentAs(now);
  }).toList();

  // 2. Doluluk Oranı Hesaplama (Sadece aktif turlar için)
  int totalCapacity = 0;
  int totalPax = 0;

  for (var tour in activeTours) {
    totalCapacity += (tour['capacity'] as num?)?.toInt() ?? 0;
    
    // Bu tura ait iptal edilmemiş rezervasyonlardaki yolcu sayılarını topluyoruz
    final tourBookings = bookings.where((b) => b['tour_id'] == tour['id']);
    for (var b in tourBookings) {
      if (b['status'] != 'İptal') {
         totalPax += (b['pax_count'] as num?)?.toInt() ?? 1;
      }
    }
  }

  double occupancyRate = totalCapacity > 0 ? (totalPax / totalCapacity) : 0.0;

  // 3. Yaklaşan Turlar (Mevcut doluluk durumlarıyla birlikte paketliyoruz)
  final upcomingTours = activeTours.take(3).map((tour) {
    int currentPax = 0;
    final tourBookings = bookings.where((b) => b['tour_id'] == tour['id']);
    for (var b in tourBookings) {
      if (b['status'] != 'İptal') {
         currentPax += (b['pax_count'] as num?)?.toInt() ?? 1;
      }
    }
    return {
      ...tour,
      'current_pax': currentPax,
    };
  }).toList();

  // 4. Son Aktiviteler (Son 3 operasyon kaydı)
  final recentActivities = bookings.take(3).toList();

  // Her şeyi Dashboard ekranının kullanabileceği tek bir Map içinde döndürüyoruz
  return {
    'totalRevenue': finance['totalRevenue'] ?? 0.0,
    'netProfit': finance['netProfit'] ?? 0.0,
    'totalCustomers': customers.length,
    'activeToursCount': activeTours.length,
    'occupancyRate': occupancyRate,
    'recentActivities': recentActivities,
    'upcomingTours': upcomingTours,
  };
});