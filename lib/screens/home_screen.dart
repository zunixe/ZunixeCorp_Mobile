import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIndex = 0;
  int _promoSeconds = 0;
  int _promoMinutes = 0;
  int _promoHours = 0;
  int _promoDays = 0;

  @override
  void initState() {
    super.initState();
    // Set countdown to end of month
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
    final diff = endOfMonth.difference(now);
    setState(() {
      _promoDays = diff.inDays;
      _promoHours = diff.inHours % 24;
      _promoMinutes = diff.inMinutes % 60;
      _promoSeconds = diff.inSeconds % 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildPromoBanner(),
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  _buildHeroSection(),
                  _buildBannerCarousel(),
                  _buildFeaturedProduct(),
                  _buildSuperPromo(),
                  _buildSection('Best Seller', dummyProducts.take(4).toList()),
                  _buildSection('Produk Terbaru', dummyProducts),
                  _buildHelpSection(),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFC8102E),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text('Z', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
                ),
                const SizedBox(height: 12),
                const Text('zunixe', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Mitra Terpercaya Inovasi Elektronika Anda', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFFC8102E)),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2, color: Color(0xFFC8102E)),
            title: const Text('Semua Produk'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Color(0xFFC8102E)),
            title: const Text('Tentang Kami'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFFC8102E)),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFC8102E),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_fire_department, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            'Get our latest products!',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 24, color: Color(0xFF3C3C3C)),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 4),
          Image.asset(
            'assets/1748664658288-Zunixe_Elctonicsv1_resized256-png.webp',
            height: 36,
            errorBuilder: (context, error, stackTrace) =>
                const Row(
                  children: [
                    CircleAvatar(radius: 14, backgroundColor: Color(0xFFC8102E), child: Text('Z', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                    SizedBox(width: 6),
                    Text('Zunixe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
                  ],
                ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, size: 22, color: Color(0xFF3C3C3C)),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 22, color: Color(0xFF3C3C3C)),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () {},
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC8102E),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '1',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        children: [
          const Text(
            'zunixe',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC8102E),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mitra Terpercaya Inovasi Elektronika Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel() {
    final banners = [
      'https://images.unsplash.com/photo-1603732551681-2e91159b9dc2?w=600&h=300&fit=crop',
      'https://images.unsplash.com/photo-1651231960369-3c31ab2a490c?w=600&h=300&fit=crop',
      'https://images.unsplash.com/photo-1649959265391-8a1de884248a?w=600&h=300&fit=crop',
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              onPageChanged: (index) => setState(() => _bannerIndex = index),
              itemCount: banners.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: Image.network(banners[index], fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      gradient: LinearGradient(colors: [Color(0xFFC8102E), Color(0xFF9E001A)]),
                    ),
                    child: const Center(child: Icon(Icons.image, color: Colors.white70, size: 48)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _bannerIndex == index ? const Color(0xFFC8102E) : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProduct() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.memory, size: 40, color: Color(0xFFC8102E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ESP32 Development Board', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Mulai proyek IoT Anda sekarang', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0C0103),
                    side: const BorderSide(color: Color(0xFF0C0103)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lihat Produk', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperPromo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFC8102E), Color(0xFF9E001A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Super Promo',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Promo terbatas hanya sampai 30 April',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCountdownBox(_promoDays.toString(), 'Hari'),
              const SizedBox(width: 8),
              const Text(':', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              _buildCountdownBox(_promoHours.toString().padLeft(2, '0'), 'Jam'),
              const SizedBox(width: 8),
              const Text(':', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              _buildCountdownBox(_promoMinutes.toString().padLeft(2, '0'), 'Menit'),
              const SizedBox(width: 8),
              const Text(':', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              _buildCountdownBox(_promoSeconds.toString().padLeft(2, '0'), 'Detik'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBox(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3C3C3C),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFFC8102E), fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) => ProductCard(product: products[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    final helpItems = [
      (
        'Mengapa membeli dari Kami',
        Icons.verified,
        'Zunixe adalah mitra terpercaya sejak 2017. Kami menyediakan komponen mikrokontroler dan elektronika berkualitas dengan harga kompetitif. Semua produk kami diuji sebelum dikirim untuk memastikan kualitas terbaik. Didukung oleh tim support yang responsif siap membantu Anda.',
      ),
      (
        'Cara Berbelanja',
        Icons.shopping_cart,
        '1. Telusuri produk di katalog kami.\n2. Klik "Beli" pada produk yang diinginkan.\n3. Masukkan jumlah dan lanjutkan ke keranjang.\n4. Isi data pengiriman dan pilih metode pembayaran.\n5. Konfirmasi pesanan dan lakukan pembayaran.\n6. Pesanan Anda akan segera diproses!',
      ),
      (
        'Melacak Order Kamu',
        Icons.local_shipping,
        'Setelah pesanan dikirim, Anda akan menerima nomor resi melalui WhatsApp atau email. Gunakan nomor resi tersebut untuk melacak status pengiriman di situs jasa ekspedisi terkait. Estimasi pengiriman 2-7 hari kerja tergantung lokasi.',
      ),
      (
        'Hubungi Dukungan',
        Icons.headset_mic,
        'Tim support kami siap membantu Anda:\n\nWhatsApp: 0877-7771-1056\nEmail: support@zunixe.com\nAlamat: Jl. Mukodar Tengah No. 247, Cibeureum, Cimahi 40535\n\nJam operasional: Senin - Sabtu, 08:00 - 17:00 WIB',
      ),
      (
        'Tips Keamanan Akun',
        Icons.security,
        '1. Gunakan password yang kuat dan unik.\n2. Jangan bagikan kode OTP ke siapa pun.\n3. Selalu periksa URL sebelum login (pastikan zunixe.com).\n4. Aktifkan verifikasi dua langkah jika tersedia.\n5. Laporkan aktivitas mencurigakan ke tim kami.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tanya Kami',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Color(0xFF3C3C3C)),
          ),
          const SizedBox(height: 12),
          ...helpItems.map((item) => _buildFaqItem(item.$1, item.$2, item.$3)),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String title, IconData icon, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: const Color(0xFFC8102E), size: 24),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      color: const Color(0xFF2D2D2D),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          const Text('zunixe', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Mitra Terpercaya Inovasi Elektronika Anda', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 8),
          Text('Cibeureum | Kota Cimahi', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _footerLink('Persyaratan Layanan'),
              const SizedBox(width: 12),
              _footerLink('Kebijakan Privasi'),
              const SizedBox(width: 12),
              _footerLink('Kebijakan Pengiriman'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _footerLink('Kebijakan Pengembalian'),
              const SizedBox(width: 12),
              _footerLink('Kebijakan KI'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Powered By : CV Zunixe Berkah Jaya',
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[400], fontSize: 12, decoration: TextDecoration.underline),
      ),
    );
  }
}
