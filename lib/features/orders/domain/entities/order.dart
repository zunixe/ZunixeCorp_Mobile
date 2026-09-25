/// Satu baris item dalam pesanan.
class OrderItem {
  final String productName;
  final int quantity;
  final int price;

  const OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  int get subtotal => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        productName: (m['product_name'] ?? '').toString(),
        quantity: (m['quantity'] as num?)?.toInt() ?? 0,
        price: (m['price'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'product_name': productName,
        'quantity': quantity,
        'price': price,
      };
}

/// Pesanan milik user beserta item-itemnya.
class Order {
  final String id;
  final String orderCode;
  final String status;
  final String paymentStatus;
  final int total;
  final DateTime? createdAt;
  final String shippingAddress;
  final String customerPhone;
  final String notes;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.orderCode,
    this.status = 'pending',
    this.paymentStatus = 'unpaid',
    this.total = 0,
    this.createdAt,
    this.shippingAddress = '',
    this.customerPhone = '',
    this.notes = '',
    this.items = const [],
  });

  bool get isPaid => paymentStatus == 'paid';

  /// Dapat dibatalkan: belum bayar + masih pending/processing.
  bool get canCancel =>
      !isPaid && (status == 'pending' || status == 'processing');

  int get itemCount => items.length;

  factory Order.fromMap(Map<String, dynamic> m) {
    final rawItems = m['order_items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <OrderItem>[];
    return Order(
      id: (m['id'] ?? '').toString(),
      orderCode: (m['order_code'] ?? '-').toString(),
      status: (m['status'] ?? 'pending').toString(),
      paymentStatus: (m['payment_status'] ?? 'unpaid').toString(),
      total: (m['total'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(m['created_at']?.toString() ?? ''),
      shippingAddress: (m['shipping_address'] ?? '').toString(),
      customerPhone: (m['customer_phone'] ?? '').toString(),
      notes: (m['notes'] ?? '').toString(),
      items: items,
    );
  }
}

/// Hasil checkout sukses: kode + total untuk layar sukses & pembayaran.
class OrderConfirmation {
  final String orderCode;
  final int total;

  const OrderConfirmation({required this.orderCode, required this.total});

  factory OrderConfirmation.fromMap(Map<String, dynamic> m) =>
      OrderConfirmation(
        orderCode: (m['order_code'] ?? '-').toString(),
        total: (m['total'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {'order_code': orderCode, 'total': total};
}
