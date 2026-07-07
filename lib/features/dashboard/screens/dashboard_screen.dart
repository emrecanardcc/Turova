import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 600 && size.width <= 1024;

    int kpiCrossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);

    // Dashboard motorumuzu (Provider) dinliyoruz
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Veriler yüklenirken hata oluştu: $err')),
        data: (data) {
          // Gelen verileri alıyoruz
          final double totalRevenue = data['totalRevenue'];
          final double netProfit = data['netProfit'];
          final int activeToursCount = data['activeToursCount'];
          final int totalCustomers = data['totalCustomers'];
          final double occupancyRate = data['occupancyRate'];
          final List<dynamic> recentActivities = data['recentActivities'];
          final List<dynamic> upcomingTours = data['upcomingTours'];

          // Para birimi formatlayıcı (Örn: 124.500 ₺)
          final currencyFormat = NumberFormat.currency(
            symbol: '₺',
            decimalDigits: 0,
            locale: 'tr_TR',
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER (BAŞLIK VE FİLTRE) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genel Bakış',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tekrar hoş geldiniz. İşte operasyonlarınızın anlık durumu.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                    if (isDesktop)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildFilterButton(context, 'Bu Ay', true),
                            _buildFilterButton(context, 'Geçen Çeyrek', false),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),

                // --- KPI KARTLARI (DİNAMİK VERİLERLE) ---
                GridView.count(
                  crossAxisCount: kpiCrossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isDesktop ? 1.8 : 2.0,
                  children: [
                    _buildKpiCard(
                      context,
                      'Toplam Gelir',
                      currencyFormat.format(totalRevenue),
                      'Aktif',
                      Icons.account_balance_wallet,
                      Colors.teal,
                      true,
                    ),
                    _buildKpiCard(
                      context,
                      'Tahmini Kâr',
                      currencyFormat.format(netProfit),
                      'Aktif',
                      Icons.show_chart,
                      Colors.blueGrey,
                      true,
                    ),
                    _buildKpiCard(
                      context,
                      'Aktif Turlar',
                      activeToursCount.toString(),
                      'Planlanan',
                      Icons.tour,
                      Colors.orange,
                      false,
                    ),
                    _buildKpiCard(
                      context,
                      'Toplam Müşteri',
                      totalCustomers.toString(),
                      'Kayıtlı',
                      Icons.groups,
                      Theme.of(context).colorScheme.primary,
                      true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- BENTO GRID (GRAFİKLER VE AKTİVİTELER) ---
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildMainChartCard(context)),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildOccupancyCard(context, occupancyRate),
                            const SizedBox(height: 24),
                            _buildActivityFeed(context, recentActivities),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildMainChartCard(context),
                      const SizedBox(height: 24),
                      _buildOccupancyCard(context, occupancyRate),
                      const SizedBox(height: 24),
                      _buildActivityFeed(context, recentActivities),
                    ],
                  ),
                const SizedBox(height: 32),

                // --- YAKLAŞAN TURLAR LİSTESİ (DİNAMİK VERİ) ---
                _buildUpcomingTours(context, upcomingTours),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET YARDIMCILARI ---

  Widget _buildFilterButton(BuildContext context, String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade700,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context,
    String title,
    String value,
    String tag,
    IconData icon,
    Color color,
    bool isUp,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainChartCard(BuildContext context) {
    return Card(
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Operasyon Analizi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Analiz grafikleri eklenecek...',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupancyCard(BuildContext context, double occupancyRate) {
    final percentage = (occupancyRate * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Genel Doluluk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.info_outline, color: Colors.grey, size: 20),
              ],
            ),
            const Divider(height: 32),
            SizedBox(
              height: 160,
              width: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: occupancyRate,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '%$percentage',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Dolu Kapasite',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(Theme.of(context).colorScheme.primary, 'Dolu'),
                const SizedBox(width: 16),
                _buildLegend(Colors.grey.shade300, 'Boş'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActivityFeed(BuildContext context, List<dynamic> activities) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Son Operasyonlar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tümü',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            if (activities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Henüz işlem kaydedilmedi.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...activities.map((activity) {
                final customerName = activity['customers'] != null
                    ? activity['customers']['full_name']
                    : 'Müşteri';
                final tourName = activity['tours'] != null
                    ? activity['tours']['title']
                    : 'Tur';
                final status = activity['status'] ?? 'İşlem';
                final pax = activity['pax_count'] ?? 1;

                Color iconColor = Colors.blue;
                IconData iconData = Icons.assignment;

                if (status == 'Onaylandı') {
                  iconColor = Colors.green;
                  iconData = Icons.check_circle;
                } else if (status == 'Bekliyor') {
                  iconColor = Colors.orange;
                  iconData = Icons.schedule;
                } else if (status == 'İptal') {
                  iconColor = Colors.red;
                  iconData = Icons.cancel;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildActivityItem(
                    iconData,
                    iconColor,
                    customerName,
                    '$tourName için $pax kişilik kayıt ($status)',
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    Color color,
    String title,
    String desc,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                  children: [
                    TextSpan(
                      text: '$title ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: desc),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingTours(BuildContext context, List<dynamic> tours) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yaklaşan Turlar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            if (tours.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Yakın zamanda planlanmış aktif tur bulunmuyor.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: tours.map((tour) {
                    final String title = tour['title'] ?? 'İsimsiz Tur';
                    final String date = tour['start_date'] != null
                        ? DateFormat(
                            'dd MMM',
                            'tr_TR',
                          ).format(DateTime.parse(tour['start_date']))
                        : '-';
                    final int capacity =
                        (tour['capacity'] as num?)?.toInt() ?? 0;
                    final int current = tour['current_pax'] ?? 0;
                    const String fallbackImg =
                        'https://images.unsplash.com/photo-1505993597083-3ae1987768e8?q=80&w=600&auto=format&fit=crop';

                    return _buildTourItem(
                      context,
                      title,
                      date,
                      current,
                      capacity,
                      fallbackImg,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourItem(
    BuildContext context,
    String title,
    String date,
    int current,
    int total,
    String imgUrl,
  ) {
    double progress = total > 0 ? (current / total) : 0;

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imgUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kapasite',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      '$current/$total',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: progress >= 1.0
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
