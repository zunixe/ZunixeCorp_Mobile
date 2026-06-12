import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Color(0xFF3C3C3C), size: 20),
          ),
          const SizedBox(width: 8),
          const Text('zunixe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, size: 20, color: Color(0xFF3C3C3C)),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, size: 20, color: Color(0xFF3C3C3C)),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () {},
          ),
        ],
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
            child: Text(
              'zunixe',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC8102E),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Selamat Datang di Zunixe Store',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3C3C3C)),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3C3C3C)),
          ),
          const SizedBox(height: 8),
          _buildServiceItem('Produk berkualitas dengan harga terbaik'),
          _buildServiceItem('Pengiriman cepat & aman ke seluruh Indonesia'),
          _buildServiceItem('Dukungan teknis responsif'),
          const SizedBox(height: 20),
          const Text(
            'Hubungi Kami:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3C3C3C)),
          ),
          const SizedBox(height: 8),
          _buildContactItem(Icons.location_on, 'Alamat:', 'Jl. Mukodar Tengah No. 247, RT 05 RW 07, Cibeureum, Cimahi 40535'),
          _buildContactItem(Icons.chat, 'WhatsApp:', '0877-7771-1056'),
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
          const Icon(Icons.check_circle, size: 18, color: Color(0xFFC8102E)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFC8102E)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                children: [
                  TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF2D2D2D),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          const Text('zunixe', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Cibeureum | Kota Cimahi', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          const SizedBox(height: 12),
          Text('Powered By : CV Zunixe Berkah Jaya', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        ],
      ),
    );
  }
}
