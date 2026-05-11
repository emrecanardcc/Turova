import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_provider.dart';

// Müşterileri getiren provider
final customersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  // Giriş yapan şirketin müşterilerini tarihe göre sıralayıp çekiyoruz
  final response = await supabase
      .from('customers')
      .select()
      .order('created_at', ascending: false);
      
  return List<Map<String, dynamic>>.from(response);
});

// Müşteri ekleme vb. aksiyonları yöneten sınıf
class CustomersNotifier {
  final Ref ref;
  CustomersNotifier(this.ref);

  Future<void> addCustomer({
    required String fullName,
    required String phone,
    String? email,
    required bool isSmsAllowed,
    required bool isEmailAllowed,
  }) async {
    final supabase = ref.read(supabaseProvider);
    
    await supabase.from('customers').insert({
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'is_sms_allowed': isSmsAllowed,
      'is_email_allowed': isEmailAllowed,
    });
    
    // Veritabanına kayıt atıldıktan sonra listeyi yenile
    ref.invalidate(customersProvider);
  }
}

final customersActionProvider = Provider((ref) => CustomersNotifier(ref));