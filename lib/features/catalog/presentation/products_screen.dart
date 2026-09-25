import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';
import 'package:zunixe_corp_mobile/core/ui/app_header.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  final bool isTab;

  const ProductsScreen({super.key, this.isTab = true});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  ProductRepository get _repository => ref.read(productRepositoryProvider);
  final ScrollController _scroll = ScrollController();

  List<Product> _items = [];
  List<String> _cats = [];
  String _category = '';
  String _search = '';
  String _sortLabel = 'Terbaru';
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  bool _hasMore = true;

  ProductSort get _sort => productSortFromLabel(_sortLabel);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
    _loadCats();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
            _scroll.position.maxScrollExtent - 400 &&
        !_loading &&
        !_loadingMore &&
        _hasMore &&
        _error == null) {
      _load();
    }
  }

  Future<void> _loadCats() async {
    final res = await _repository.getCategories();
    if (mounted) {
      res.fold(
        (cats) => setState(() => _cats = cats),
        (_) {},
      );
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _items = [];
        _hasMore = true;
      });
    } else {
      setState(() => _loadingMore = true);
    }
    final offset = reset ? 0 : _items.length;
    final res = await _repository.getProducts(
      search: _search,
      category: _category.isEmpty ? null : _category,
      offset: offset,
      sort: _sort,
    );
    if (!mounted) return;
    res.fold(
      (rows) => setState(() {
        _items = reset ? rows : [..._items, ...rows];
        _hasMore = rows.length >= ProductRepository.pageSize;
        _loading = false;
        _loadingMore = false;
      }),
      (f) => setState(() {
        _loading = false;
        _loadingMore = false;
        if (reset) _error = f.message;
      }),
    );
  }

  void _reload() => _load(reset: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.brand));
    }
    if (_error != null && _items.isEmpty) {
      return _buildError();
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        color: AppColors.brand,
        onRefresh: () => _load(reset: true),
        child: ListView(
          children: const [
            SizedBox(height: 80),
            Center(
              child: Text('Tidak ada produk ditemukan',
                  style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: () => _load(reset: true),
      child: GridView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.53,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _items.length + (_loadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.brand),
              ),
            );
          }
          final p = _items[index];
          return ProductCard(
            product: p,
            onTap: () => context.pushNamed(
              AppRouteNames.productDetail,
              pathParameters: {'id': p.id},
              extra: p,
            ),
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Gagal memuat produk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _reload,
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brand),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    final ctrl = TextEditingController(text: _search);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cari Produk'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ketik nama produk...'),
          onSubmitted: (_) {
            Navigator.pop(dialogContext);
            setState(() => _search = ctrl.text.trim());
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
              setState(() => _search = ctrl.text.trim());
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
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list,
                  size: 18, color: AppColors.brand),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _catChip('', 'Semua'),
                      ..._cats.map((c) => _catChip(c, c)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _sortLabel,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down,
                    color: AppColors.ink),
                items: kProductSortLabels.map((e) {
                  return DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 13)));
                }).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _sortLabel = v);
                  _reload();
                },
              ),
            ],
          ),
          if (_search.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Hasil: "$_search"',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _search = '');
                      _reload();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.clear, size: 16, color: AppColors.brand),
                        Text('Hapus',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.brand)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _catChip(String value, String label) {
    final selected = _category == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) {
          setState(() => _category = value);
          _reload();
        },
        selectedColor: AppColors.brand,
        labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.ink),
        backgroundColor: AppColors.chipFill,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
