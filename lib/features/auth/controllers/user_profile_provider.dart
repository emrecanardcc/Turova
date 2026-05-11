import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

// Giriş yapmış kullanıcının profil (rol, şirket id vb.) bilgilerini tutar
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // Mevcut oturumu al
  final session = ref.watch(authStateProvider).value?.session;
  if (session == null) return null; // Giriş yapılmamışsa null dön

  final supabase = ref.watch(supabaseProvider);
  
  // Profiles tablosundan kullanıcının bilgilerini çek
  final response = await supabase
      .from('profiles')
      .select()
      .eq('id', session.user.id)
      .maybeSingle();
      
  return response;
});