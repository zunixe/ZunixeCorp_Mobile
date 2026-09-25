/// Satu baris keranjang milik user.
class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  int quantity;

  /// Stok terkini (diisi saat fetch; default tak terbatas bila tak ada data).
  final int stock;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.stock = 1 << 30,
  });

  factory CartItem.fromRow(Map<String, dynamic> row) {
    final prod = row['products'];
    final stock = prod is Map ? (prod['stock'] as num?)?.toInt() : null;
    return CartItem(
      id: row['id'].toString(),
      productId: row['product_id'].toString(),
      productName: row['product_name'] ?? '',
      productImage: row['product_image'] ?? '',
      price: (row['price'] as num?)?.toDouble() ?? 0,
      quantity: (row['quantity'] as num?)?.toInt() ?? 1,
      stock: stock ?? 1 << 30,
    );
  }
}
