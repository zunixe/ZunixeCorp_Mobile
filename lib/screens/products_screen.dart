import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  final bool isTab;
  const ProductsScreen({super.key, this.isTab = true});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String sortBy = 'Terbaru';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilterBar(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: dummyProducts.length,
                itemBuilder: (context, index) => ProductCard(product: dummyProducts[index]),
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
          if (!widget.isTab)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_back, color: Color(0xFF3C3C3C), size: 20),
              ),
            ),
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

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () {},
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
