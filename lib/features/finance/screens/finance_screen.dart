import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/finance_provider.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 600 && size.width <= 1024;

    int kpiCrossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    // Finans verilerini dinliyoruz
    final financeAsync = ref.watch(financeProvider);

    return Scaffold(
      body: financeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Finans verileri yüklenirken hata oluştu: $err')),
        data: (financeData) {
          
          // Provider'dan gelen verileri değişkenlere alıyoruz
          final double totalRevenue = financeData['totalRevenue'];
          final double netProfit = financeData['netProfit'];
          final double averageMargin = financeData['averageMargin'];
          final List<Map<String, dynamic>> invoices = financeData['recentInvoices'];

          // Para birimi formatlayıcı (Örn: 12,450.00)
          final currencyFormat = NumberFormat.currency(symbol: '₺', decimalDigits: 2, locale: 'tr_TR');

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ÜST BAŞLIK VE RAPOR BUTONU ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Finans ve Analiz', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -1)),
                          const SizedBox(height: 8),
                          const Text(
                            'Mevcut çeyrek için gelir akışlarının, kâr marjlarının ve faturaların kapsamlı özeti.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1CA9C9), Color(0xFF1698B5)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: const Color(0xFF1CA9C9).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                        onPressed: () {},
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text('Rapor Oluştur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // --- KPI KARTLARI (GERÇEK VERİLERLE) ---
                GridView.count(
                  crossAxisCount: kpiCrossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isDesktop ? 2.2 : 2.0,
                  children: [
                    _buildKpiCard(context, 'Toplam Gelir', currencyFormat.format(totalRevenue), '+0.0%', Icons.account_balance_wallet, Theme.of(context).colorScheme.primary, true),
                    _buildKpiCard(context, 'Tahmini Net Kâr', currencyFormat.format(netProfit), '+0.0%', Icons.analytics, Colors.orange, true),
                    _buildKpiCard(context, 'Ortalama Marj', '%${averageMargin.toStringAsFixed(1)}', 'Sabit', Icons.pie_chart, Colors.redAccent, false),
                  ],
                ),
                const SizedBox(height: 24),

                // --- GRAFİKLER ---
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildMainChartCard(context)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildCategoryBarChart(context)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildMainChartCard(context),
                      const SizedBox(height: 24),
                      _buildCategoryBarChart(context),
                    ],
                  ),
                const SizedBox(height: 32),

                // --- DİNAMİK FATURALAR TABLOSU ---
                _buildInvoicesTable(context, invoices, currencyFormat),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String value, String percentage, IconData icon, Color color, bool isUp) {
    return Card(
      child: Stack(
        children: [
          Positioned(right: -20, top: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: color.withOpacity(0.05), shape: BoxShape.circle))),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: isUp ? Colors.green.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Icon(isUp ? Icons.trending_up : Icons.drag_handle, color: isUp ? Colors.green : Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text(percentage, style: TextStyle(color: isUp ? Colors.green : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    const Text('bu dönem', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text('Gelir & Gider Analizi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Aylık trend analizi', style: TextStyle(fontSize: 12, color: Colors.grey))],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                  child: const Row(children: [Text('2026', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)), Icon(Icons.arrow_drop_down, color: Colors.grey)]),
                )
              ],
            ),
            const Divider(height: 32),
            Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.insights, size: 64, color: Colors.grey.shade300), const SizedBox(height: 16), Text('Grafik entegrasyonu bekleniyor...', style: TextStyle(color: Colors.grey.shade500))]))),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBarChart(BuildContext context) {
    return Card(
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kategoriye Göre Gelir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Tur paketlerinin performansı', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 32),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCategoryBarItem('Kültür Turları', '₺0', 0.0, Theme.of(context).colorScheme.primary),
                  _buildCategoryBarItem('Doğa Yürüyüşleri', '₺0', 0.0, Colors.orange),
                  _buildCategoryBarItem('Gurme Deneyimleri', '₺0', 0.0, Colors.blueGrey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBarItem(String title, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade100, color: color, minHeight: 8, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }

  Widget _buildInvoicesTable(BuildContext context, List<Map<String, dynamic>> invoices, NumberFormat formatter) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Son İşlemler (Faturalar)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Tümünü Gör')),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.grey.shade50,
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Fatura No', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 3, child: Text('Müşteri / Kurum', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Tarih', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Tutar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Durum', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                SizedBox(width: 32),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          
          if (invoices.isEmpty)
            const Padding(padding: EdgeInsets.all(32.0), child: Center(child: Text('Henüz sistemde finansal bir kayıt bulunmuyor.', style: TextStyle(color: Colors.grey))))
          else
            ...invoices.map((inv) {
              Color statusColor = Colors.orange;
              if (inv['status'] == 'Ödendi') statusColor = Colors.green;
              if (inv['status'] == 'İptal' || inv['status'] == 'İade') statusColor = Colors.red;

              final dateStr = inv['date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(inv['date'])) : '-';

              return Column(
                children: [
                  _buildInvoiceRow(context, '#INV-${inv['id']}', inv['client'], dateStr, formatter.format(inv['amount']), inv['status'], statusColor),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(BuildContext context, String id, String client, String date, String amount, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(id, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87))),
          Expanded(flex: 3, child: Text(client, style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(date, style: const TextStyle(fontSize: 13, color: Colors.grey))),
          Expanded(flex: 2, child: Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87))),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ),
          ),
          IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20), onPressed: () {})
        ],
      ),
    );
  }
}