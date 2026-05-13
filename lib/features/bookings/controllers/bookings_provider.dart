import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Şirket çalışanının göreceği rezervasyon listesini getiren Provider
final bookingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;

  // Supabase'in gücü: bookings (rezervasyonlar) tablosunu çekerken, 
  // o rezervasyonun ait olduğu turun adını ve müşterinin adını da otomatik birleştirerek (JOIN) çekiyoruz!
  final response = await supabase
      .from('bookings')
      .select('''
        *,
        tours (title, start_date),
        customers (full_name)
      ''')
      .order('created_at', ascending: false);
      
  return List<Map<String, dynamic>>.from(response);
});

// 2. Şirket çalışanının manuel rezervasyon gireceği aksiyon sınıfı
class BookingsNotifier {
  final Ref ref;
  BookingsNotifier(this.ref);

  Future<void> addBooking({
    required String tourId,
    required String customerId,
    required String status, // Örn: 'Onaylandı', 'Bekliyor', 'İptal'
    required String paymentStatus, // Örn: 'Ödendi', 'Kapora Alındı', 'Ödeme Bekliyor'
    required int paxCount, // Kaç kişilik yer ayrıldı (Yolcu sayısı)
  }) async {
    final supabase = Supabase.instance.client;
    
    // Çalışan yeni bir rezervasyon kaydı giriyor
    await supabase.from('bookings').insert({
      'tour_id': tourId,
      'customer_id': customerId,
      'status': status,
      'payment_status': paymentStatus,
      'pax_count': paxCount,
      // created_at veritabanında otomatik oluşur
    });
    
    // Veritabanına kayıt atıldıktan sonra arayüzdeki tabloyu anında yenile
    ref.invalidate(bookingsProvider);
  }
}

final bookingsActionProvider = Provider((ref) => BookingsNotifier(ref));