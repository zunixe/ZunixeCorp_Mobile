package com.zunixe.zunixe_store.core.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.RoundRect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zunixe.zunixe_store.core.theme.AppColors
import kotlin.math.atan2
import kotlin.math.hypot

/**
 * Logo Zunixe — robot merah bertema (porting dari `_ZunixeRobotPainter`
 * Flutter ke Compose Canvas). Semua koordinat memakai skala u = size/100.
 */
@Composable
fun ZunixeLogo(size: Dp = 40.dp, modifier: Modifier = Modifier) {
    Canvas(modifier = modifier.size(size)) {
        drawRobotLogo(this.size.width)
    }
}

private fun DrawScope.drawRobotLogo(s: Float) {
    val u = s / 100f

    // Glow merah di belakang kepala
    drawOval(
        brush = Brush.radialGradient(
            colors = listOf(AppColors.Brand.copy(alpha = 0.42f), Color.Transparent),
            center = Offset(50 * u, 54 * u),
            radius = 46 * u,
        ),
        topLeft = Offset(10 * u, 16 * u),
        size = Size(80 * u, 76 * u),
    )

    // Antena
    drawLine(
        color = AppColors.Brand,
        start = Offset(50 * u, 26 * u),
        end = Offset(50 * u, 12 * u),
        strokeWidth = 3.4f * u,
        cap = androidx.compose.ui.graphics.StrokeCap.Round,
    )

    // Telinga
    drawRoundRect(
        color = AppColors.RobotEar,
        topLeft = Offset(5 * u, 42 * u),
        size = Size(9 * u, 16 * u),
        cornerRadius = CornerRadius(5 * u),
    )
    drawRoundRect(
        color = AppColors.RobotEar,
        topLeft = Offset(86 * u, 42 * u),
        size = Size(9 * u, 16 * u),
        cornerRadius = CornerRadius(5 * u),
    )
    drawCircle(AppColors.RobotCyan, radius = 2.6f * u, center = Offset(9.5f * u, 50 * u))
    drawCircle(AppColors.RobotCyan, radius = 2.6f * u, center = Offset(90.5f * u, 50 * u))

    // Kepala gradient
    val headRect = Rect(14 * u, 24 * u, 86 * u, 82 * u)
    val headRRect = RoundRect(headRect, CornerRadius(20 * u))
    drawPath(
        path = Path().apply { addRoundRect(headRRect) },
        brush = Brush.verticalGradient(
            colors = listOf(AppColors.BrandBright, AppColors.RobotDark),
            startY = headRect.top,
            endY = headRect.bottom,
        ),
    )
    drawPath(
        path = Path().apply { addRoundRect(headRRect) },
        color = Color.White.copy(alpha = 0.28f),
        style = Stroke(width = 1.4f * u),
    )

    // Visor
    val visorRect = Rect(21 * u, 38 * u, 79 * u, 63 * u)
    val visorRRect = RoundRect(visorRect, CornerRadius(11 * u))
    drawPath(Path().apply { addRoundRect(visorRRect) }, color = AppColors.RobotVisor)
    drawPath(
        Path().apply { addRoundRect(visorRRect) },
        color = AppColors.RobotCyan.copy(alpha = 0.85f),
        style = Stroke(width = 1.6f * u),
    )

    // Huruf Z putih
    val vw = 58 * u
    val vh = 25 * u
    val zw = 0.44f * vw
    val zh = 0.80f * vh
    val barH = zh / 5.2f
    val zcx = 50 * u
    val zcy = 50.5f * u
    val zx0 = zcx - zw / 2
    val zTopY = zcy - zh / 2
    val zBotY = zcy + zh / 2
    val radius = CornerRadius(barH * 0.4f)

    // Batang atas & bawah
    drawRoundRect(
        color = Color.White,
        topLeft = Offset(zx0, zTopY),
        size = Size(zw, barH),
        cornerRadius = radius,
    )
    drawRoundRect(
        color = Color.White,
        topLeft = Offset(zx0, zBotY - barH),
        size = Size(zw, barH),
        cornerRadius = radius,
    )

    // Batang diagonal
    val dA = Offset(zx0 + zw - barH * 0.48f, zTopY + barH - u * 0.3f)
    val dB = Offset(zx0 + barH * 0.48f, zBotY - barH + u * 0.3f)
    val dx = dB.x - dA.x
    val dy = dB.y - dA.y
    val len = hypot(dx, dy).coerceAtLeast(0.0001f)
    val nx = -dy / len
    val ny = dx / len
    val halfWidth = barH * 0.66f

    val diag = Path().apply {
        moveTo(dA.x + nx * halfWidth, dA.y + ny * halfWidth)
        lineTo(dA.x - nx * halfWidth, dA.y - ny * halfWidth)
        lineTo(dB.x - nx * halfWidth, dB.y - ny * halfWidth)
        lineTo(dB.x + nx * halfWidth, dB.y + ny * halfWidth)
        close()
    }
    drawPath(diag, color = Color.White)

    // Lampu mulut
    drawRoundRect(
        color = AppColors.RobotCyan,
        topLeft = Offset(43 * u, 70 * u),
        size = Size(14 * u, 3.4f * u),
        cornerRadius = CornerRadius(1.7f * u),
    )

    // Bola antena + glow
    val antTo = Offset(50 * u, 12 * u)
    drawCircle(
        brush = Brush.radialGradient(
            colors = listOf(AppColors.RobotCyan.copy(alpha = 0.45f), Color.Transparent),
            center = antTo,
            radius = 7.6f * u,
        ),
        radius = 7.6f * u,
        center = antTo,
    )
    drawCircle(AppColors.RobotCyan, radius = 5.2f * u, center = antTo)
}

/** Sudut rotasi tak terpakai — disisakan untuk animasi logo bila perlu. */
@Suppress("unused")
private fun angleBetween(dx: Float, dy: Float): Float = atan2(dy, dx)
