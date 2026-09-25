import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/auth_providers.dart';
import 'package:zunixe_corp_mobile/features/cart/presentation/cart_providers.dart';
import 'package:zunixe_corp_mobile/features/orders/presentation/orders_providers.dart';
import 'package:zunixe_corp_mobile/core/ui/app_header.dart';
import 'package:zunixe_corp_mobile/core/ui/gradient_button.dart';
import 'package:zunixe_corp_mobile/core/utils/format.dart';
import 'package:zunixe_corp_mobile/core/config/store.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _submitting = false;
  // Unik per halaman checkout dibuka — retry key sama = order yang sama.
  late final String _idempotencyKey =
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';

  @override
  void initState() {
    super.initState();
    _prefillProfile();
  }

  /// Isi nama/telp dari profil (hemat ketik ulang tiap order).
  Future<void> _prefillProfile() async {
    final userId = ref.read(authNotifierProvider).user?.id;
    if (userId == null) return;
    final profile = await ref
        .read(authRepositoryProvider)
        .getProfile(userId);
    if (!mounted || profile == null) return;
    if (_nameCtrl.text.isEmpty) {
      _nameCtrl.text = profile.fullName;
    }
    if (_phoneCtrl.text.isEmpty) {
      _phoneCtrl.text = profile.phone;
    }
  }

  /// Simpan nama/telp ke profil untuk prefill order berikutnya.
  Future<void> _saveProfile(String? userId) async {
    if (userId == null) return;
    // Best-effort: jangan blokir alur sukses.
    unawaited(ref.read(authRepositoryProvider).saveProfile(
          userId: userId,
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        ));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    final cart = ref.read(cartNotifierProvider.notifier);
    final auth = ref.read(authNotifierProvider);

    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _submitting = true);
    final res = await ref.read(orderRepositoryProvider).placeOrder(
          shippingAddress: _addressCtrl.text.trim(),
          customerName: _nameCtrl.text.trim(),
          customerPhone: _phoneCtrl.text.trim(),
          notes:
              _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          idempotencyKey: _idempotencyKey,
        );
    await cart.fetchCart();
    // Simpan balik agar prefill berikutnya terisi (diam-diam, jangan blokir sukses).
    _saveProfile(auth.user?.id);
    if (!mounted) return;
    res.fold(
      (confirmation) {
        context.pushReplacement(
          AppRoutes.orderSuccess,
          extra: confirmation,
        );
      },
      (f) {
        // Tampilkan pesan server utuh (nama produk ikut terkirim).
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(f.message.isEmpty
                  ? 'Gagal membuat pesanan.'
                  : f.message),
              backgroundColor: Colors.red),
        );
      },
    );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Checkout',
              showBack: true,
              showSearch: false,
              showCart: false,
              showProfile: false,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Produk (${cart.itemCount})',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ...cart.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.productName} x${item.quantity}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Text(
                                      formatRupiah((item.price * item.quantity).round()),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Ongkir', style: TextStyle(fontSize: 13)),
                              Text('Rp 0 (GRATIS)',
                                  style: TextStyle(fontSize: 13, color: Colors.green[700], fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              Text(formatRupiah(cart.totalPrice),
                                  style: const TextStyle(
                                      fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.brand)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Data Penerima',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: _deco('Nama Lengkap'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: _deco('No. WhatsApp'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor wajib diisi' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _addressCtrl,
                            maxLines: 3,
                            decoration: _deco('Alamat Lengkap Pengiriman'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Alamat wajib diisi' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesCtrl,
                            maxLines: 2,
                            decoration: _deco('Catatan (opsional)'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warningBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payment, size: 20, color: AppColors.warning),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              StoreConfig.hasBank
                                  ? 'Bayar via transfer ${StoreConfig.bankName} ${StoreConfig.accountNumber} (a.n. ${StoreConfig.accountHolder}), lalu konfirmasi via WhatsApp.'
                                  : 'Bayar via transfer bank, lalu konfirmasi via WhatsApp ${StoreConfig.waDisplay}. No. rekening tertera setelah pesanan dibuat.',
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: GradientButton(
          label: 'Buat Pesanan - ${formatRupiah(cart.totalPrice)}',
          height: 50,
          fontSize: 16,
          loading: _submitting,
          onPressed: (cart.items.isEmpty || _submitting) ? null : _submit,
        ),
      ),
    );
  }

  InputDecoration _deco(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.brand, width: 2),
      ),
    );
  }

}
