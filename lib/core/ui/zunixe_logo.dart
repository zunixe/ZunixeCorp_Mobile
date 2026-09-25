import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';

/// Logo Zunixe v3 — ROBOT THEME.
/// Kepala robot merah gradient: antena + bola cyan bercahaya, tombing telinga
/// dengan dot cyan, visor gelap berisi huruf Z putih menyala, lampu mulut cyan.
class ZunixeLogo extends StatelessWidget {
  final double size;

  const ZunixeLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ZunixeRobotPainter()),
    );
  }
}

class _ZunixeRobotPainter extends CustomPainter {
  static const cyan = AppColors.robotCyan;
  static const g1 = AppColors.brandBright;
  static const g3 = AppColors.robotDark;
  static const visor = AppColors.robotVisor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final u = s / 100.0;
    final white = Paint()..color = Colors.white;
    final cyanPaint = Paint()..color = cyan;

    // ---- Background (transparan; kalau butuh panel gelap, pakai container luar) ----

    // ---- Red glow di belakang kepala ----
    final glowRect = Rect.fromLTWH(10 * u, 16 * u, 80 * u, 76 * u);
    canvas.drawOval(
      glowRect,
      Paint()
        ..color = AppColors.brand.withValues(alpha: 0.42)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * u),
    );

    // ---- Antena ----
    final antFrom = Offset(50 * u, 26 * u);
    final antTo = Offset(50 * u, 12 * u);
    canvas.drawLine(
      antFrom, antTo,
      Paint()
        ..color = AppColors.brand
        ..strokeWidth = 3.4 * u
        ..strokeCap = StrokeCap.round,
    );

    // ---- Telinga ----
    final earCol = Paint()..color = AppColors.robotEar;
    final earL = RRect.fromRectAndRadius(
        Rect.fromLTWH(5 * u, 42 * u, 9 * u, 16 * u), Radius.circular(5 * u));
    final earR = RRect.fromRectAndRadius(
        Rect.fromLTWH(86 * u, 42 * u, 9 * u, 16 * u), Radius.circular(5 * u));
    canvas.drawRRect(earL, earCol);
    canvas.drawRRect(earR, earCol);

    // dot cyan telinga
    canvas.drawCircle(Offset(9.5 * u, 50 * u), 2.6 * u, cyanPaint);
    canvas.drawCircle(Offset(90.5 * u, 50 * u), 2.6 * u, cyanPaint);

    // ---- Kepala (gradient merah) ----
    final headRect = Rect.fromLTWH(14 * u, 24 * u, 72 * u, 58 * u);
    final headRRect = RRect.fromRectAndRadius(headRect, Radius.circular(20 * u));
    final headPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [g1, g3],
      ).createShader(headRect);
    canvas.drawRRect(headRRect, headPaint);
    // outline terang tipis
    canvas.drawRRect(
      headRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 * u
        ..color = Colors.white.withValues(alpha: 0.28),
    );

    // ---- Visor gelap + stroke cyan ----
    final visorRect = Rect.fromLTWH(21 * u, 38 * u, 58 * u, 25 * u);
    final visorRRect = RRect.fromRectAndRadius(visorRect, Radius.circular(11 * u));
    canvas.drawRRect(visorRRect, Paint()..color = visor);
    canvas.drawRRect(
      visorRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * u
        ..color = cyan.withValues(alpha: 0.85),
    );

    // ---- Huruf Z putih (dengan glow) — ramping & tersambung ----
    // Visor: 21..79 x 38..63 → Z tinggi-sempit (0.44 x 0.80 visor), bar tipis
    final vw = 58 * u, vh = 25 * u;
    final zw = 0.44 * vw;
    final zh = 0.80 * vh;
    final barH = zh / 5.2;
    final zcx = 50 * u, zcy = 50.5 * u;
    final zx0 = zcx - zw / 2;
    final zx1 = zcx + zw / 2;
    final zTopY = zcy - zh / 2;
    final zBotY = zcy + zh / 2;
    final zR = Radius.circular(barH * 0.4);
    final dA = Offset(zx1 - barH * 0.48, zTopY + barH - u * 0.3);
    final dB = Offset(zx0 + barH * 0.48, zBotY - barH + u * 0.3);
    final dx = dB.dx - dA.dx;
    final dy = dB.dy - dA.dy;
    final L = math.sqrt(dx * dx + dy * dy);
    final nx = -dy / L, ny = dx / L;
    final dw = barH * 0.66;

    final diagPath = Path()
      ..moveTo(dA.dx + nx * dw, dA.dy + ny * dw)
      ..lineTo(dA.dx - nx * dw, dA.dy - ny * dw)
      ..lineTo(dB.dx - nx * dw, dB.dy - ny * dw)
      ..lineTo(dB.dx + nx * dw, dB.dy + ny * dw)
      ..close();

    // glow putih
    final zGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.6 * u);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(zx0, zTopY, zw, barH), zR), zGlow);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(zx0, zBotY - barH, zw, barH), zR), zGlow);
    canvas.drawPath(diagPath, zGlow);

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(zx0, zTopY, zw, barH), zR), white);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(zx0, zBotY - barH, zw, barH), zR), white);
    canvas.drawPath(diagPath, white);

    // ---- Lampu mulut cyan ----
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(43 * u, 70 * u, 14 * u, 3.4 * u), Radius.circular(1.7 * u)),
      cyanPaint,
    );

    // ---- Bola antena cyan + glow ----
    canvas.drawCircle(
      antTo,
      5.2 * u + 2.4 * u,
      Paint()
        ..color = cyan.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.4 * u),
    );
    canvas.drawCircle(antTo, 5.2 * u, cyanPaint);
  }

  @override
  bool shouldRepaint(covariant _ZunixeRobotPainter oldDelegate) => false;
}
