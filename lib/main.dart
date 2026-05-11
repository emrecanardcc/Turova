import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/routes/app_router.dart';
import 'core/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Çevre değişkenlerini yüklüyoruz
  await dotenv.load();

  // Supabase bağlantısını başlatıyoruz
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    // Riverpod'u tüm uygulamaya enjekte ediyoruz
    const ProviderScope(
      child: TurovaApp(),
    ),
  );
}

class TurovaApp extends ConsumerWidget {
  const TurovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeColor = ref.watch(themeProvider);

    // Modern SaaS Kremsi Arka Plan Rengi
    const creamyBackground = Color(0xFFFBFBF9);
    // Yazı ve ikonlar için koyu renk (Kömür Karası)
    const onSurfaceColor = Color(0xFF2A2D34);

    return MaterialApp.router(
      title: 'Turova',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: creamyBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColor,
          surface: Colors.white,
        ),
        // Modern Tipografi (Poppins)
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: onSurfaceColor,
          displayColor: onSurfaceColor,
        ),
        // Modern AppBar Tasarımı
        appBarTheme: const AppBarTheme(
          backgroundColor: creamyBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: onSurfaceColor),
          titleTextStyle: TextStyle(
            color: onSurfaceColor,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        // Modern Kart Tasarımı
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            side: BorderSide(color: Color(0xFFE5E7EB), width: 1), // Tailwind gray-200
          ),
          margin: EdgeInsets.zero,
        ),
        // Modern Input (TextField) Tasarımı
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3F4F6), // Açık gri arkaplan
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        // Modern Buton Tasarımı
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}