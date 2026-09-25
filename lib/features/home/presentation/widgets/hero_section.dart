import 'package:flutter/material.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/core/ui/zunixe_logo.dart';

/// Hero logo + tagline home.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ZunixeLogo(size: 56),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'zunixe',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brand,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Zunixe Electronics',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
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
}
