import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Controller'dan loading durumunu dinliyoruz
    final isLoading = ref.watch(authControllerProvider);

    // Ekran genişliğini alarak mobil/masaüstü ayrımı yapıyoruz
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      // Arka plan rengini temadan (kremsi beyaz) alıyor
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: 1200, // Maksimum genişlik (Çok büyük ekranlarda yayılmasın diye)
            height: isDesktop ? 700 : null, // Masaüstünde sabit yükseklik, mobilde içeriğe göre
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8), // Cam efekti zemini
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
              border: Border.all(color: Colors.white, width: 2), // İnce beyaz çerçeve (Glassmorphism)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Row(
                children: [
                  // SOL TARAF: Görsel ve Marka (Sadece masaüstünde görünür)
                  if (isDesktop)
                    Expanded(
                      flex: 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Geçici bir Unsplash seyahat görseli
                          Image.network(
                            'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?q=80&w=2021&auto=format&fit=crop',
                            fit: BoxFit.cover,
                          ),
                          // Görselin üzerine karartma (Overlay)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  const Color(0xFF171C1E).withOpacity(0.9),
                                  const Color(0xFF171C1E).withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                          // Sol Taraf İçerik
                          Padding(
                            padding: const EdgeInsets.all(48.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Logo
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.explore, color: Colors.white, size: 28),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Turova',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  ],
                                ),
                                // Slogan
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Operasyonlarınızı\nkusursuz yönetin.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        height: 1.1,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Modern tur operatörleri için tasarlanmış kapsamlı yönetim paneli. Lojistiği basitleştirin, müşterileri mutlu edin.',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // SAĞ TARAF: Giriş Formu
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 64.0 : 32.0,
                        vertical: 48.0,
                      ),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Sadece mobilde görünen logo
                              if (!isDesktop) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.explore, color: Theme.of(context).colorScheme.primary, size: 28),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Turova',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                              ],

                              const Text(
                                'Tekrar Hoş Geldiniz',
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Turlarınızı yönetmek için panelinize giriş yapın.',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),

                              // E-Posta
                              const Text('E-Posta Adresi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  hintText: 'ornek@turova.com',
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Şifre
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Şifre', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                    child: const Text('Şifremi unuttum?', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Beni Hatırla
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (val) => setState(() => _rememberMe = val!),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('30 gün boyunca beni hatırla', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Özel Gradyanlı Giriş Butonu
                              Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF1CA9C9), Color(0xFF1698B5)], // Senin attığın tasarım renkleri
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1CA9C9).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          final email = _emailController.text.trim();
                                          final password = _passwordController.text.trim();
                                          if (email.isNotEmpty && password.isNotEmpty) {
                                            ref.read(authControllerProvider.notifier).login(email, password, context);
                                          }
                                        },
                                  child: isLoading
                                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Giriş Yap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}