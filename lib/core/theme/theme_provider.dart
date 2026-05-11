import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/controllers/auth_provider.dart';

// Süper Admin ve Login ekranı için varsayılan renk
// Turova'nın ana rengi (Süper Admin rengi)
const defaultThemeColor = Color(0xFF1CA9C9);

final themeProvider = NotifierProvider<ThemeNotifier, Color>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<Color> {
  @override
  Color build() {
    _listenToAuthChanges();
    return defaultThemeColor; // Uygulama açılış rengi
  }

  void _listenToAuthChanges() {
    final supabase = ref.watch(supabaseProvider);
    
    // Kullanıcı giriş/çıkış yaptığında burası tetiklenir
    supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      
      if (session != null) {
        try {
          // 1. Giriş yapan kişinin profilinden company_id'sini al
          final profile = await supabase
              .from('profiles')
              .select('company_id')
              .eq('id', session.user.id)
              .maybeSingle();

          if (profile != null && profile['company_id'] != null) {
            // 2. Şirketin temasını çek
            final company = await supabase
                .from('companies')
                .select('theme_color')
                .eq('id', profile['company_id'])
                .maybeSingle();

            if (company != null && company['theme_color'] != null) {
              // 3. HEX kodunu Flutter'ın anlayacağı Color formatına çevir
              final hexCode = company['theme_color'].toString().replaceAll('#', '');
              state = Color(int.parse('FF$hexCode', radix: 16));
              return;
            }
          }
        } catch (e) {
          debugPrint('Tema çekilirken hata: $e');
        }
      }
      
      // Çıkış yapıldıysa veya şirketi yoksa (Super Admin) varsayılana dön
      state = defaultThemeColor;
    });
  }
}