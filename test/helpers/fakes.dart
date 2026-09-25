import 'package:supabase_flutter/supabase_flutter.dart' show User;
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/features/cart/cart.dart';

/// Builder `Product` ringkas untuk test.
Product buildProduct({
  String id = 'p1',
  String sku = 'SKU1',
  String name = 'Produk Uji',
  double price = 100000,
  double originalPrice = 0,
  int stock = 10,
  String imageUrl = '',
  List<String> imageList = const [],
  String category = 'Elektronik',
  String? description,
}) {
  return Product(
    id: id,
    sku: sku,
    name: name,
    price: price,
    originalPrice: originalPrice,
    stock: stock,
    imageUrl: imageUrl,
    imageList: imageList,
    category: category,
    description: description,
  );
}

/// Builder `CartItem` ringkas untuk test.
CartItem buildCartItem({
  String id = 'c1',
  String productId = 'p1',
  String productName = 'Produk Uji',
  String productImage = '',
  double price = 100000,
  int quantity = 1,
  int stock = 1 << 30,
}) {
  return CartItem(
    id: id,
    productId: productId,
    productName: productName,
    productImage: productImage,
    price: price,
    quantity: quantity,
    stock: stock,
  );
}

/// Builder `User` ringkas untuk test auth.
User buildUser({
  String id = 'u1',
  String? email = 'user@zunixe.com',
  Map<String, dynamic>? userMetadata,
}) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: userMetadata ?? const {},
    aud: 'authenticated',
    email: email,
    createdAt: '2024-01-01T00:00:00Z',
  );
}
