import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:zunixe_corp_mobile/core/ui/app_header.dart';
import 'package:zunixe_corp_mobile/core/ui/zunixe_logo.dart';
import 'package:zunixe_corp_mobile/core/config/store.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Tentang Kami',
              showBack: true,
              showSearch: false,
              showCart: false,
              showProfile: false,
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildAboutContent(),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: ZunixeLogo(size: 88),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'zunixe',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.brand,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Selamat Datang di Zunixe Store',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          Text(
            'Mitra Terpercaya Inovasi Elektronika Anda Sejak 2017',
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            'Di bawah naungan CV Zunixe Berkah Jaya, kami hadir sebagai solusi utama bagi para pengembang, pelajar, dan pelaku industri yang membutuhkan komponen mikrokontroler dan elektronika berkualitas.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
          ),
          const SizedBox(height: 12),
          Text(
            'Kami percaya bahwa teknologi adalah jembatan menuju masa depan. Oleh karena itu, kami tidak hanya menjual produk, tetapi juga mendukung Anda mewujudkan ide-ide kreatif menjadi inovasi nyata. Dengan pengalaman lebih dari 7 tahun, kami berdedikasi untuk memperluas batas kemungkinan Anda dalam dunia otomasi dan robotika.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
          ),
          const SizedBox(height: 20),
          const Text(
            'Komitmen Layanan Kami:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          _buildServiceItem('Produk berkualitas dengan harga terbaik'),
          _buildServiceItem('Pengiriman cepat & aman ke seluruh Indonesia'),
          _buildServiceItem('Dukungan teknis responsif'),
          const SizedBox(height: 20),
          const Text(
            'Hubungi Kami:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          _buildContactItem(Icons.location_on, 'Alamat:', 'Jl. Mukodar Tengah No. 247, RT 05 RW 07, Cibeureum, Cimahi 40535',
              onTap: () => _openMap()),
          _buildContactItem(Icons.chat, 'WhatsApp:', '0877-7771-1056',
              onTap: () => _openWa()),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.brand),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    final row = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.brand),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                children: [
                  TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: onTap == null ? null : AppColors.brand,
                      decoration: onTap == null ? null : TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }

  Future<void> _openWa() async {
    final url = Uri.parse(StoreConfig.waChatUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMap() async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('Jl. Mukodar Tengah No. 247, Cibeureum, Cimahi 40535')}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildFooter() {
    return Container(
      color: AppColors.footer,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          const ZunixeLogo(size: 44),
          const SizedBox(height: 8),
          const Text('zunixe', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text('Cibeureum | Kota Cimahi', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          const SizedBox(height: 12),
          Text('Powered By : CV Zunixe Berkah Jaya', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        ],
      ),
    );
  }
}
