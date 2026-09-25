import 'package:flutter/material.dart';

/// Design tokens warna Zunixe — SATU-SATUNYA sumber kebenaran warna brand.
///
/// Jangan lagi menulis `Color(0xFF...)` literal di kode fitur; pakai
/// konstanta di sini agar rebrand / dark-mode cukup menyentuh satu file.
abstract final class AppColors {
  // Brand.
  static const Color brand = Color(0xFFC8102E);
  static const Color brandDark = Color(0xFF9E001A);
  static const Color brandLight = Color(0xFFE11D3C);
  static const Color brandBright = Color(0xFFFF3D57);

  // Teks & netral.
  static const Color ink = Color(0xFF3C3C3C);
  static const Color grey = Color(0xFF7A7A7A);
  static const Color muted = Color(0xFFAAAAAA);
  static const Color silver = Color(0xFFB0B0B0);
  static const Color dark = Color(0xFF1F2937);
  static const Color footer = Color(0xFF2D2D2D);

  // Latar & garis.
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color inputFill = Color(0xFFF3F3F3);
  static const Color chipFill = Color(0xFFF1F1F1);
  static const Color chipFillAlt = Color(0xFFF0F0F5);
  static const Color chipText = Color(0xFF5A5A6A);
  static const Color border = Color(0xFFE8E8E8);
  static const Color borderAlt = Color(0xFFE0E0E0);
  static const Color borderInput = Color(0xFFDADCE0);

  // Status.
  static const Color success = Color(0xFF1BA303);
  static const Color successBright = Color(0xFF22C55E);
  static const Color successBg = Color(0xFFE8F8EE);
  static const Color warning = Color(0xFFB8860B);
  static const Color warningBg = Color(0xFFFFF7E6);
  static const Color warningBorder = Color(0xFFF0D9A6);
  static const Color info = Color(0xFF1565C0);
  static const Color errorBg = Color(0xFFFFE8EB);
  static const Color pinkLight = Color(0xFFFCA5A5);

  // Pihak ketiga.
  static const Color whatsapp = Color(0xFF25D366);
  static const Color facebook = Color(0xFF1877F2);

  // Logo robot.
  static const Color robotCyan = Color(0xFF22D3EE);
  static const Color robotEar = Color(0xFF9A0824);
  static const Color robotDark = Color(0xFF7E0418);
  static const Color robotVisor = Color(0xFF0B0E1E);
}
