import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

// Riverpod 2.0+ standardı olan NotifierProvider kullanımı
final authControllerProvider = NotifierProvider<AuthController, bool>(() {
  return AuthController();
});

class AuthController extends Notifier<bool> {
  @override
  bool build() {
    // Başlangıçta loading durumu 'false'
    return false; 
  }

  Future<void> login(String email, String password, BuildContext context) async {
    state = true; // Butona basıldığında loading başlat
    
    try {
      // Notifier içinde olduğumuz için 'ref' objesine doğrudan erişebiliyoruz
      await ref.read(supabaseProvider).auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Başarılı girişte GoRouter bizi otomatik olarak yakalayıp yönlendirecek.
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bilinmeyen bir hata oluştu.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      state = false; // İşlem bitince loading'i durdur
    }
  }
}