import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/customers_provider.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  
  // --- MÜŞTERİ EKLEME DİYALOĞU (Yenilenmiş Modern Tasarım) ---
  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    bool smsAllowed = false;
    bool emailAllowed = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Yeni Müşteri Kartı', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Ad Soyad', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Telefon', prefixIcon: Icon(Icons.phone_outlined)),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'E-Posta (Opsiyonel)', prefixIcon: Icon(Icons.mail_outline)),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                
                // KVKK İzinleri Bölümü
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pazarlama & İletişim İzinleri (KVKK)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('SMS gönderilebilir', style: TextStyle(fontSize: 14)),
                        value: smsAllowed,
                        onChanged: (val) => setState(() => smsAllowed = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      CheckboxListTile(
                        title: const Text('E-Posta gönderilebilir', style: TextStyle(fontSize: 14)),
                        value: emailAllowed,
                        onChanged: (val) => setState(() => emailAllowed = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  await ref.read(customersActionProvider).addCustomer(
                    fullName: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                    isSmsAllowed: smsAllowed,
                    isEmailAllowed: emailAllowed,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final size = MediaQuery.of(context).size;
    
    // Responsive Grid Ayarı
    int crossAxisCount = 1;
    if (size.width > 1200) crossAxisCount = 3;
    else if (size.width > 800) crossAxisCount = 2;

    return Scaffold(
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
        data: (customers) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(size.width > 800 ? 32.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ÜST BİLGİ VE ARAMA ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Müşteri Veritabanı (CRM)', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -1)),
                          const SizedBox(height: 8),
                          const Text(
                            'Yolcularınızı yönetin, geçmişlerini görüntüleyin ve iletişim izinlerini takip edin.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Sadece masaüstünde görünen arama çubuğu
                    if (size.width > 800)
                      Container(
                        width: 250,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Müşteri ara...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.grey),
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onPressed: _showAddCustomerDialog,
                      icon: const Icon(Icons.person_add, size: 20),
                      label: const Text('Yeni Müşteri'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // --- MÜŞTERİ LİSTESİ (BENTO GRID) ---
                if (customers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 64.0),
                    child: Center(child: Text('Sistemde henüz müşteri kaydı bulunmuyor.', style: TextStyle(fontSize: 16, color: Colors.grey))),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.1, // Kartın yükseklik/genişlik oranı
                    ),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return _buildCustomerCard(context, customer);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- MÜŞTERİ KARTI WIDGET'I ---
  Widget _buildCustomerCard(BuildContext context, Map<String, dynamic> customer) {
    // İsimden baş harfleri alma
    String getInitials(String name) {
      List<String> names = name.split(" ");
      String initials = "";
      int numWords = names.length > 2 ? 2 : names.length;
      for (int i = 0; i < numWords; i++) {
        if (names[i].isNotEmpty) {
          initials += names[i][0].toUpperCase();
        }
      }
      return initials;
    }

    final bool smsAllowed = customer['is_sms_allowed'] ?? false;
    final bool emailAllowed = customer['is_email_allowed'] ?? false;
    final String email = customer['email'] ?? 'E-Posta belirtilmemiş';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ÜST KISIM: Profil ve İsim
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        child: Text(
                          getInitials(customer['full_name']),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer['full_name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                              child: const Text('Standart Yolcu', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          
          // ORTA KISIM: İletişim Bilgileri
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mail_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(email, style: const TextStyle(color: Colors.black87, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.phone_iphone, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(customer['phone'], style: const TextStyle(color: Colors.black87, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  // Son Katıldığı Tur (Tasarımda vardı, şimdilik statik tutuyoruz)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Son Katıldığı Tur', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.map, size: 14, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 6),
                            const Text('Kayıt Bulunamadı', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ALT KISIM: KVKK İzinleri ve Buton
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: const Color(0xFFFBFBF9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // SMS İzni Butonu
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: smsAllowed ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sms, 
                        size: 16, 
                        color: smsAllowed ? Theme.of(context).colorScheme.primary : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Email İzni Butonu
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: emailAllowed ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.alternate_email, 
                        size: 16, 
                        color: emailAllowed ? Theme.of(context).colorScheme.primary : Colors.grey,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text('Detaylar', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}