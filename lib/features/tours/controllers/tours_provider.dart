import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_provider.dart';

// Turları veritabanından çeken provider
final toursProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  // Sadece giriş yapan şirketin turlarını tarihe göre sıralayarak getirir (RLS devrede!)
  final response = await supabase
      .from('tours')
      .select()
      .order('start_date', ascending: true);
      
  return List<Map<String, dynamic>>.from(response);
});

// Tur ekleme, silme gibi işlemleri yönetecek sınıf
class ToursNotifier {
  final Ref ref;
  ToursNotifier(this.ref);

  Future<void> addTour({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int capacity,
    required double price,
  }) async {
    final supabase = ref.read(supabaseProvider);
    
    await supabase.from('tours').insert({
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'capacity': capacity,
      'price_per_person': price,
      'status': 'upcoming', // Varsayılan durum: Yaklaşan
    });
    
    // İşlem bitince listeyi yenile
    ref.invalidate(toursProvider);
  }
}

final toursActionProvider = Provider((ref) => ToursNotifier(ref));