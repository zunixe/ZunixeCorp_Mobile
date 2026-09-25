import 'package:flutter/material.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';

/// Carousel banner promo home (stateful: indikator halaman aktif).
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  static const banners = [
    'https://images.unsplash.com/photo-1603732551681-2e91159b9dc2?w=600&h=300&fit=crop',
    'https://images.unsplash.com/photo-1651231960369-3c31ab2a490c?w=600&h=300&fit=crop',
    'https://images.unsplash.com/photo-1649959265391-8a1de884248a?w=600&h=300&fit=crop',
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
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                clipBehavior: Clip.hardEdge,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: Image.network(BannerCarousel.banners[index],
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                          decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                            gradient: LinearGradient(colors: [
                              AppColors.brand,
                              AppColors.brandDark
                            ]),
                          ),
                          child: const Center(
                              child: Icon(Icons.image,
                                  color: Colors.white70, size: 48)),
                        )),
              ),
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
