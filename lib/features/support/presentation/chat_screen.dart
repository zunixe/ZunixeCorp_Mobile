import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:zunixe_corp_mobile/core/ui/app_header.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _messages = <_ChatMessage>[
    _ChatMessage('Halo! Selamat datang di Zunixe Store.', false, DateTime.now().subtract(const Duration(minutes: 5))),
    _ChatMessage('Ada yang bisa kami bantu?', false, DateTime.now().subtract(const Duration(minutes: 4))),
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, true, DateTime.now()));
    });
    _msgCtrl.clear();
    // Jujur: tak ada backend chat. Auto-reply mengarahkan ke WhatsApp.
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          'Terima kasih! Pesan Anda tercatat. Kami membalas via WhatsApp '
          '0877-7771-1056 — atau ketuk tombol hijau di bawah untuk chat langsung.',
          false,
          DateTime.now(),
        ));
      });
    });
  }

  void _openWhatsApp() async {
    final url = Uri.parse('https://wa.me/6287777711056');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      await Clipboard.setData(const ClipboardData(text: '087777711056'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nomor WhatsApp disalin: 0877-7771-1056'), backgroundColor: AppColors.success),
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
                child: const Icon(Icons.headset_mic, color: AppColors.brand, size: 18),
              ),
              showSearch: false,
              showCart: false,
              showProfile: false,
              trailing: [
                IconButton(
                  icon: const Icon(Icons.call, color: AppColors.brand, size: 22),
                  tooltip: 'Chat WhatsApp',
                  onPressed: _openWhatsApp,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[_messages.length - 1 - index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),
            _buildInputBar(),
            _buildWhatsAppButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isMe ? AppColors.brand : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: msg.isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(color: msg.isMe ? Colors.white : AppColors.ink, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: msg.isMe ? Colors.white70 : Colors.grey[400], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.brand,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Chat via WhatsApp  0877-7771-1056', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;
  _ChatMessage(this.text, this.isMe, this.time);
}
