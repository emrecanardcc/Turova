import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Finans ekranındaki tüm verileri (Gelir, Kâr, Faturalar) toparlayıp tek seferde arayüze sunan Provider
final financeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final supabase = Supabase.instance.client;

  // 1. Veritabanından fiyat ve yolcu bilgileriyle birlikte onaylı/ödenmiş rezervasyonları çekelim
  final bookingsResponse = await supabase
      .from('bookings')
      .select('''
        id,
        created_at,
        payment_status,
        pax_count,
        tours (price_per_person),
        customers (full_name)
      ''')
      .order('created_at', ascending: false);

  double totalRevenue = 0.0;
  List<Map<String, dynamic>> recentInvoices = [];

  for (var booking in bookingsResponse) {
    // Toplam geliri hesaplıyoruz (Sadece 'Ödendi' olanları gelire ekleyelim)
    final int pax = booking['pax_count'] ?? 1;
    final double price = (booking['tours'] != null && booking['tours']['price_per_person'] != null) 
        ? (booking['tours']['price_per_person'] as num).toDouble() 
        : 0.0;
    
    final double amount = pax * price;

    if (booking['payment_status'] == 'Ödendi') {
      totalRevenue += amount;
    }

    // Fatura tablosu için veriyi formatlıyoruz
    recentInvoices.add({
      'id': booking['id'].toString().substring(0, 5).toUpperCase(),
      'client': booking['customers'] != null ? booking['customers']['full_name'] : 'Bilinmeyen',
      'date': booking['created_at'],
      'amount': amount,
      'status': booking['payment_status'] ?? 'Bekliyor',
    });
  }

  // Turizm sektöründe varsayılan net kâr marjını şimdilik %25 olarak alıyoruz (İleride giderler tablosu eklenince dinamik olacak)
  double netProfit = totalRevenue * 0.25;

  return {
    'totalRevenue': totalRevenue,
    'netProfit': netProfit,
    'averageMargin': 25.0,
    'recentInvoices': recentInvoices.take(5).toList(), // Sadece son 5 faturayı al
  };
});