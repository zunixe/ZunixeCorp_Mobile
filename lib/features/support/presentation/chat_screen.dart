import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:zunixe_corp_mobile/core/config/store.dart';
import 'package:zunixe_corp_mobile/core/ui/app_header.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';

/// Support via WhatsApp. Tidak ada backend chat: pesan yang diketik
/// diteruskan sebagai teks WhatsApp (jujur — tanpa auto-reply palsu).
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  /// Buka WhatsApp memakai pesan yang diketik (bila ada) sebagai teks awal.
  void _send() async {
    final text = _msgCtrl.text.trim();
    final uri = text.isEmpty
        ? Uri.parse(StoreConfig.waChatUrl)
        : Uri.parse(
            'https://wa.me/${StoreConfig.waNumber}?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Clipboard.setData(const ClipboardData(text: StoreConfig.waDisplay));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Nomor WhatsApp disalin: ${StoreConfig.waDisplay}'),
              backgroundColor: AppColors.success),
        );
      }
    }
  }

  void _openWhatsApp() async {
    final url = Uri.parse(StoreConfig.waChatUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      await Clipboard.setData(const ClipboardData(text: StoreConfig.waNumber));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Nomor WhatsApp disalin: ${StoreConfig.waDisplay}'),
              backgroundColor: AppColors.success),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Zunixe Support',
              subtitle: 'Chat via WhatsApp — balasan di WhatsApp',
              leading: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brand, width: 2),
                ),
                child: const Icon(Icons.headset_mic,
                    color: AppColors.brand, size: 18),
              ),
              showSearch: false,
              showCart: false,
              showProfile: false,
              trailing: [
                IconButton(
                  icon: const Icon(Icons.call,
                      color: AppColors.brand, size: 22),
                  tooltip: 'Chat WhatsApp',
                  onPressed: _openWhatsApp,
                ),
              ],
            ),
            Expanded(child: _buildIntro()),
            _buildInputBar(),
            _buildWhatsAppButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.brand,
                child: Icon(Icons.headset_mic, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 14),
              const Text(
                'Butuh bantuan?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              Text(
                'Tim support Zunixe siap membantu Anda. Ketik pesan di bawah, '
                'lalu tekan kirim — pesan akan dibuka langsung di WhatsApp.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey[600], height: 1.6),
              ),
              const SizedBox(height: 16),
              const _InfoRow(
                icon: Icons.schedule,
                text: 'Senin – Sabtu, 08.00 – 17.00 WIB',
              ),
              const SizedBox(height: 8),
              const _InfoRow(
                icon: Icons.chat_bubble_outline,
                text: 'WhatsApp ${StoreConfig.waDisplay}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warningBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warningBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pesan hanya terkirim lewat WhatsApp. Aplikasi tidak '
                  'menyimpan riwayat chat.',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[700], height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Ketik pesan…',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.whatsapp,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                tooltip: 'Kirim via WhatsApp',
                onPressed: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppButton() {
    return InkWell(
      onTap: _openWhatsApp,
      child: Container(
        color: AppColors.whatsapp,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Chat via WhatsApp  ${StoreConfig.waDisplay}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.brand),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }
}
