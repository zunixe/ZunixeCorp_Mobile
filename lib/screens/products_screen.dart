import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/app_header.dart';
import '../widgets/product_card.dart';
import '../screens/product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final bool isTab;
  const ProductsScreen({super.key, this.isTab = true});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _service = ProductService();
  late Future<List<Product>> _future;
  String sortBy = 'Terbaru';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = _service.fetchProducts();
  }

  void _reload() {
    setState(() {
      _future = _service.fetchProducts(search: _search);
    });
  }

  List<Product> _applySort(List<Product> products) {
    final list = List<Product>.from(products);
    switch (sortBy) {
      case 'Termurah':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Termahal':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Terlaris':
        list.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      default:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'zunixe',
              showBack: !widget.isTab,
              showSearch: true,
              onSearch: _showSearchDialog,
              showCart: false,
              showProfile: false,
            ),
            _buildFilterBar(),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFC8102E)));
                  }
                  if (snapshot.hasError) {
                    return _buildError(snapshot.error.toString());
                  }
                  final products = _applySort(snapshot.data ?? []);
                  if (products.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada produk ditemukan', style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) => ProductCard(
                      product: products[index],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: products[index]))),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Gagal memuat produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Pastikan server API berjalan dan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _reload,
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFC8102E)),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cari Produk'),
        content: TextField(
          autofocus: true,
          onChanged: (v) => _search = v,
          decoration: const InputDecoration(hintText: 'Ketik nama produk...'),
          onSubmitted: (v) {
            Navigator.pop(dialogContext);
            _reload();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _reload();
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur filter akan segera hadir'), backgroundColor: Color(0xFFC8102E)),
              );
            },
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('Filter', style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3C3C3C),
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: sortBy,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF3C3C3C)),
            items: ['Terbaru', 'Termurah', 'Termahal', 'Terlaris'].map((e) {
              return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)));
            }).toList(),
            onChanged: (v) => setState(() => sortBy = v!),
          ),
        ],
      ),
    );
  }
}
