import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/controllers/auth_provider.dart';
import '../../features/auth/controllers/user_profile_provider.dart'; // EKLENDİ

// Menü öğelerimiz için basit bir sınıf
class _MenuDestination {
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool requireSuperAdmin;

  _MenuDestination({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.requireSuperAdmin = false, // Varsayılan olarak herkes görebilir
  });
}

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    // Profil yüklenirken menüyü bekletebiliriz
    if (userProfileAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = userProfileAsync.value?['role'] ?? 'staff';
    final isSuperAdmin = role == 'super_admin';

    // Tüm menü ihtimalleri
    final allDestinations = [
      _MenuDestination(path: '/dashboard', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Panel'),
      // Şirketler menüsü SADECE Süper Admin için
      _MenuDestination(path: '/companies', icon: Icons.domain, selectedIcon: Icons.business, label: 'Şirketler', requireSuperAdmin: true),
      _MenuDestination(path: '/tours', icon: Icons.map_outlined, selectedIcon: Icons.map, label: 'Turlar'),
      _MenuDestination(path: '/customers', icon: Icons.people_outline, selectedIcon: Icons.people, label: 'Müşteriler'),
    ];

    // Sadece kullanıcının yetkisi olan menüleri filtrele
    final visibleDestinations = allDestinations.where((dest) {
      if (dest.requireSuperAdmin && !isSuperAdmin) return false;
      return true;
    }).toList();

    // Hangi sayfada olduğumuzu (index) hesapla
    final currentPath = GoRouterState.of(context).matchedLocation;
    int selectedIndex = visibleDestinations.indexWhere((dest) => currentPath.startsWith(dest.path));
    if (selectedIndex == -1) selectedIndex = 0; // Bulamazsa varsayılan Panel

   return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, // Kremsi arkaplan
      body: Row(
        children: [
          // SOL MENÜ (Gölge efekti eklendi)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface, // Menü tam beyaz
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(2, 0),
                )
              ],
            ),
            child: NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (int index) {
                context.go(visibleDestinations[index].path);
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.transparent, // Arkaplanı container'dan alıyor
              indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.15), // Seçili öğe arka planı daha soft
              selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
              selectedLabelTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
              unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              leading: const Padding(
                padding: EdgeInsets.only(bottom: 30, top: 20),
                child: Icon(Icons.travel_explore, size: 44, color: Color(0xFF1CA9C9)), // Turova Logosu hep kendi renginde
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      tooltip: 'Çıkış Yap',
                      onPressed: () async {
                        await supabase.auth.signOut();
                      },
                    ),
                  ),
                ),
              ),
              destinations: visibleDestinations.map((dest) {
                return NavigationRailDestination(
                  icon: Icon(dest.icon),
                  selectedIcon: Icon(dest.selectedIcon),
                  label: Text(dest.label),
                );
              }).toList(),
            ),
          ),
          
          // SAĞ TARAFTAKİ DEĞİŞEN İÇERİK (Animasyon Eklendi)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300), // Akıcı geçiş süresi
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.02, 0), // Hafif sağdan gelme efekti
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              // Flutter'a child'ın değiştiğini anlatmak için unique key atıyoruz
              child: Container(
                key: ValueKey<String>(currentPath),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}