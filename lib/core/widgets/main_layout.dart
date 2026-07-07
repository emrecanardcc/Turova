import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/tours')) return 1;
    if (location.startsWith('/bookings')) return 2;
    if (location.startsWith('/customers')) return 3;
    if (location.startsWith('/finance')) return 4;
    return 0; // Dashboard varsayılan
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/tours');
        break;
      case 2:
        context.go('/bookings');
        break;
      case 3:
        context.go('/customers');
        break;
      case 4:
        context.go('/finance');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: Row(
        children: [
          // MASAÜSTÜ/TABLET İÇİN SOL MENÜ (SIDEBAR)
          if (isDesktop)
            Container(
              width: 280,
              color: Colors.white,
              child: Column(
                children: [
                  // Logo ve Marka
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.explore,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Turova',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menü Elemanları
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _SideMenuItem(
                          icon: Icons.dashboard,
                          title: 'Ana Panel',
                          isSelected: currentIndex == 0,
                          onTap: () => _onItemTapped(0, context),
                        ),
                        _SideMenuItem(
                          icon: Icons.map,
                          title: 'Turlar',
                          isSelected: currentIndex == 1,
                          onTap: () => _onItemTapped(1, context),
                        ),
                        _SideMenuItem(
                          icon: Icons.event_available,
                          title: 'Rezervasyonlar',
                          isSelected: currentIndex == 2,
                          onTap: () => _onItemTapped(2, context),
                        ),
                        _SideMenuItem(
                          icon: Icons.group,
                          title: 'Müşteriler',
                          isSelected: currentIndex == 3,
                          onTap: () => _onItemTapped(3, context),
                        ),
                        _SideMenuItem(
                          icon: Icons.payments,
                          title: 'Finans',
                          isSelected: currentIndex == 4,
                          onTap: () => _onItemTapped(4, context),
                        ),
                      ],
                    ),
                  ),

                  // Alt Kısım (Ayarlar, Çıkış)
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _SideMenuItem(
                          icon: Icons.settings,
                          title: 'Ayarlar',
                          isSelected: false,
                          onTap: () {},
                        ),
                        _SideMenuItem(
                          icon: Icons.logout,
                          title: 'Çıkış Yap',
                          isSelected: false,
                          onTap: () {
                            // Çıkış işlemi eklenecek
                            context.go('/login');
                          },
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // SAĞ TARAF (VEYA MOBİLDE TAM EKRAN) İÇERİK: Aktif olan sayfa buraya gelir
          Expanded(child: child),
        ],
      ),

      // MOBİL İÇİN ALT MENÜ (BOTTOM NAVIGATION BAR)
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => _onItemTapped(index, context),
              backgroundColor: Colors.white,
              indicatorColor: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Panel',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: 'Turlar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_available_outlined),
                  selectedIcon: Icon(Icons.event_available),
                  label: 'Kayıtlar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.group_outlined),
                  selectedIcon: Icon(Icons.group),
                  label: 'CRM',
                ),
                NavigationDestination(
                  icon: Icon(Icons.payments_outlined),
                  selectedIcon: Icon(Icons.payments),
                  label: 'Finans',
                ),
              ],
            ),
    );
  }
}

// Menü Elemanı Tasarımı
class _SideMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _SideMenuItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;
    final itemColor =
        color ?? (isSelected ? activeColor : Colors.grey.shade700);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border(right: BorderSide(color: activeColor, width: 4))
              : null, // Seçili olana sağ çizgi
        ),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: itemColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
