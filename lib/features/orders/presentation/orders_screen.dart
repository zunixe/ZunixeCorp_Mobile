import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/features/orders/orders.dart';
import 'package:zunixe_corp_mobile/core/ui/app_header.dart';
import 'package:zunixe_corp_mobile/features/checkout/checkout.dart';
import 'package:zunixe_corp_mobile/core/utils/format.dart';
import 'package:zunixe_corp_mobile/features/auth/auth.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';

/// Warna badge status pesanan — fungsi murni agar dapat di-unit-test.
Color orderStatusColor(String status) {
  switch (status) {
    case 'processing':
      return AppColors.warning;
    case 'shipped':
      return AppColors.info;
    case 'completed':
      return AppColors.success;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.grey[600]!;
  }
}

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  OrderRepository get _repository => ref.read(orderRepositoryProvider);
  List<Order> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = ref.read(authNotifierProvider).user?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final res = await _repository.getMyOrders(userId);
    if (!mounted) return;
    res.fold(
      (orders) => setState(() {
        _orders = orders;
        _error = null;
        _loading = false;
      }),
      (_) => setState(() {
        _error = 'Gagal memuat pesanan';
        _loading = false;
      }),
    );
  }

  Future<void> _cancel(String orderId, String orderCode) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan pesanan?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text('Pesanan $orderCode dibatalkan dan stok dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak',
                style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final res = await _repository.cancelOrder(orderId);
    if (!mounted) return;
    res.fold(
      (_) {
        messenger.showSnackBar(
          SnackBar(
              content: Text('Pesanan $orderCode dibatalkan.'),
              backgroundColor: AppColors.success),
        );
        _load();
      },
      (f) => messenger.showSnackBar(
        SnackBar(
            content: Text(f.message.isEmpty ? 'Gagal membatalkan.' : f.message),
            backgroundColor: Colors.red),
      ),
    );
  }

  Color _statusColor(String status) => orderStatusColor(status);

  String _statusLabel(String status) => orderStatusLabel(status);

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(
      authNotifierProvider.select((s) => s.isLoggedIn),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Pesanan Saya',
              showBack: true,
              showSearch: false,
              showCart: false,
              showProfile: false,
            ),
            Expanded(
              child: !isLoggedIn
                  ? _buildNeedLogin(context)
                  : _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
                      : _error != null
                          ? _buildError(context)
                          : _orders.isEmpty
                              ? _buildEmpty(context)
                              : _buildOrders(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedLogin(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Login untuk melihat pesanan', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              context.push(AppRoutes.login);
              _load();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Masuk'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, foregroundColor: Colors.white),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Belum ada pesanan', style: TextStyle(fontSize: 15, color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _buildOrders() {
    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final items = order.items;
          final total = order.total;
          final status = order.status;
          final createdAt = order.createdAt;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderCode,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          if (createdAt != null)
                            Text(
                              '${createdAt.day}/${createdAt.month}/${createdAt.year} '
                              '${createdAt.hour.toString().padLeft(2, '0')}:'
                              '${createdAt.minute.toString().padLeft(2, '0')}'
                              '${order.isPaid ? '' : ' • Belum bayar'}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(status),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(status)),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  '${items.length} item - ${formatRupiah(total)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                      '${item.productName} x${item.quantity}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13)),
                                ),
                                Text(formatRupiah(item.subtotal),
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          );
                        }),
                        const Divider(),
                        _infoRow('Alamat',
                            order.shippingAddress.isEmpty ? '-' : order.shippingAddress),
                        if (order.customerPhone.isNotEmpty)
                          _infoRow('Telp', order.customerPhone),
                        if (order.notes.isNotEmpty)
                          _infoRow('Catatan', order.notes),
                        if (order.canCancel) ...[
                          const SizedBox(height: 12),
                          PaymentInfo(
                            orderCode: order.orderCode,
                            total: total,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _cancel(
                                order.id,
                                order.orderCode,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Batalkan Pesanan',
                                  style: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

}
