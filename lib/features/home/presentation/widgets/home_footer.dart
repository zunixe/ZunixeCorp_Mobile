import 'package:flutter/material.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:zunixe_corp_mobile/core/ui/zunixe_logo.dart';
import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';

/// Footer gelap home dengan tautan legal.
class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      color: AppColors.footer,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          const ZunixeLogo(size: 44),
          const SizedBox(height: 8),
          const Text('zunixe',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text('Mitra Terpercaya Inovasi Elektronika Anda',
              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 8),
          Text('Cibeureum | Kota Cimahi',
              style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink('Persyaratan Layanan', 'tos'),
              SizedBox(width: 12),
              _FooterLink('Kebijakan Privasi', 'privacy'),
              SizedBox(width: 12),
              _FooterLink('Kebijakan Pengiriman', 'shipping'),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink('Kebijakan Pengembalian', 'returns'),
              SizedBox(width: 12),
              _FooterLink('Kebijakan KI', 'ip'),
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
}

class _FooterLink extends StatelessWidget {
  const _FooterLink(this.text, this.slug);

  final String text;
  final String slug;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRouteNames.legal,
        pathParameters: {'slug': slug},
      ),
      child: Text(
        text,
        style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            decoration: TextDecoration.underline),
      ),
    );
  }
}
