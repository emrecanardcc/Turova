import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// İskeletimizi core/widgets altından çekiyoruz
import '../widgets/main_layout.dart';

// Diğer ekranlar
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/tours/screens/tours_screen.dart';
import '../../features/customers/screens/customers_screen.dart';
import '../../features/bookings/screens/bookings_screen.dart';
import '../../features/finance/screens/finance_screen.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/controllers/auth_provider.dart'; // <-- EKSİK OLAN IMPORT BURAYA EKLENDİ

final goRouterProvider = Provider<GoRouter>((ref) {
  // Kullanıcının giriş yapıp yapmadığını dinliyoruz
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    // Kullanıcı giriş yapmamışsa onu Login'e at, yapmışsa gitmek istediği yere at
    redirect: (context, state) {
      // Supabase'den gelen AuthState içinde aktif bir session (oturum) var mı kontrol ediyoruz
      final isLoggedIn = authState.value?.session != null;
      final isLoggingIn = state.uri.path == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';
      
      return null; // Her şey yolunda
    },
    routes: [
      // 1. GİRİŞ EKRANI (Menüsüz, tam ekran)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 2. ANA İSKELET (ShellRoute: Sol menü sabit kalır, içindeki ekranlar değişir)
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child); // İskeletimiz
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/tours',
            pageBuilder: (context, state) => const NoTransitionPage(child: ToursScreen()),
          ),
          GoRoute(
            path: '/bookings',
            pageBuilder: (context, state) => const NoTransitionPage(child: BookingsScreen()),
          ),
          GoRoute(
            path: '/customers',
            pageBuilder: (context, state) => const NoTransitionPage(child: CustomersScreen()),
          ),
          GoRoute(
            path: '/finance',
            pageBuilder: (context, state) => const NoTransitionPage(child: FinanceScreen()),
          ),
        ],
      ),
    ],
  );
});