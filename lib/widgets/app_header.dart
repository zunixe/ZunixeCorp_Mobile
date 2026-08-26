import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final bool showBack;
  final VoidCallback? onBack;
  final bool showMenu;
  final VoidCallback? onMenu;
  final bool showSearch;
  final VoidCallback? onSearch;
  final bool showCart;
  final int cartCount;
  final VoidCallback? onCart;
  final bool showProfile;
  final VoidCallback? onProfile;
  final List<Widget>? trailing;

  const AppHeader({
    super.key,
    this.title = 'zunixe',
    this.subtitle,
    this.leading,
    this.showBack = false,
    this.onBack,
    this.showMenu = false,
    this.onMenu,
    this.showSearch = true,
    this.onSearch,
    this.showCart = true,
    this.cartCount = 0,
    this.onCart,
    this.showProfile = true,
    this.onProfile,
    this.trailing,
  });

  Widget _defaultLeading() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundColor: Color(0xFFC8102E),
          child: Text('Z', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC8102E)),
        ),
      ],
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (showMenu) {
      return Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, size: 24, color: Color(0xFF3C3C3C)),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          tooltip: 'Menu',
          onPressed: onMenu ?? () => Scaffold.of(ctx).openDrawer(),
        ),
      );
    }
    if (showBack) {
      return IconButton(
        icon: const Icon(Icons.arrow_back, size: 22, color: Color(0xFF3C3C3C)),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        tooltip: 'Kembali',
        onPressed: onBack ?? () => Navigator.maybePop(context),
      );
    }
    return leading ?? _defaultLeading();
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (showSearch)
        IconButton(
          icon: const Icon(Icons.search, size: 22, color: Color(0xFF3C3C3C)),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          tooltip: 'Cari',
          onPressed: onSearch,
        ),
      if (showCart)
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, size: 22, color: Color(0xFF3C3C3C)),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              tooltip: 'Keranjang',
              onPressed: onCart,
            ),
            if (cartCount > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Color(0xFFC8102E), shape: BoxShape.circle),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      if (showProfile)
        IconButton(
          icon: const Icon(Icons.person_outline, size: 22, color: Color(0xFF3C3C3C)),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          tooltip: 'Akun',
          onPressed: onProfile,
        ),
      if (trailing != null) ...trailing!,
    ];

    return Container(
      color: Colors.white,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          _buildLeading(context),
          const SizedBox(width: 8),
          if (title.isNotEmpty && !showBack && !showMenu && leading == null)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF3C3C3C)),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                ],
              ),
            )
          else if ((showBack || showMenu) && title.isNotEmpty)
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF3C3C3C)),
              ),
            )
          else if (subtitle != null)
            Expanded(
              child: Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            )
          else
            const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
