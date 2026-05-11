import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turova/features/auth/controllers/auth_provider.dart';

// Şirketleri çeken provider
final companiesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  // Supabase'den şirketleri alıyoruz
  final response = await supabase.from('companies').select().order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

// Yeni şirket ekleme fonksiyonlarını tutan sınıf
class CompaniesNotifier {
  final ref;
  CompaniesNotifier(this.ref);

  Future<void> addCompany(String name, String phone, String hexColor) async {
    final supabase = ref.read(supabaseProvider);
    await supabase.from('companies').insert({
      'name': name,
      'owner_phone': phone,
      'theme_color': hexColor,
      'is_active': true,
      // subscription_end_date şimdilik boş kalabilir, ileride detaylandırırız
    });
    
    // Listeyi yenilemek için provider'ı invalidate (iptal) ediyoruz
    ref.invalidate(companiesProvider); 
  }
}

final companiesActionProvider = Provider((ref) => CompaniesNotifier(ref));