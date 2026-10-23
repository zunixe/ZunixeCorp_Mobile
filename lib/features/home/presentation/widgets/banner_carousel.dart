import 'package:flutter/material.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';

/// Carousel banner promo home. Memakai kartu lokal (bukan hotlink Unsplash)
/// agar tidak bergantung pada jaringan/gambar pihak ketiga.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  static const banners = [
    (
      title: 'Gratis Ongkir',
      subtitle: 'Ke seluruh Indonesia',
      icon: Icons.local_shipping,
      colors: [AppColors.brand, AppColors.brandDark],
    ),
    (
      title: 'Komponen IoT Pilihan',
      subtitle: 'ESP32, Arduino, sensor & modul',
      icon: Icons.memory,
      colors: [AppColors.info, Color(0xFF0B3C78)],
    ),
    (
      title: 'Butuh Bantuan?',
      subtitle: 'Chat tim support via WhatsApp',
      icon: Icons.chat,
      colors: [AppColors.whatsapp, AppColors.success],
    ),
  ];

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _bannerIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              onPageChanged: (index) => setState(() => _bannerIndex = index),
              itemCount: BannerCarousel.banners.length,
              itemBuilder: (context, index) {
                final banner = BannerCarousel.banners[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: banner.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(banner.icon, color: Colors.white, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        banner.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        banner.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              BannerCarousel.banners.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _bannerIndex == index
                      ? AppColors.brand
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
