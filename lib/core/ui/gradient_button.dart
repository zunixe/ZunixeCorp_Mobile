import 'package:flutter/material.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';

/// Tombol CTA gradient merah brand — konsisten dengan AddToCartButton.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final IconData? icon;
  final bool loading;
  final bool expanded;

  static const _gradRed = LinearGradient(
    colors: [AppColors.brandLight, AppColors.brand, AppColors.brandDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 48,
    this.fontSize = 15,
    this.icon,
    this.loading = false,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: _gradRed,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.brand.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: (onPressed == null || loading) ? null : onPressed,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: loading
                ? SizedBox(
                    width: fontSize + 4,
                    height: fontSize + 4,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: fontSize + 4, color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
