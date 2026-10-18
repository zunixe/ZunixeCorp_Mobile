package com.zunixe.zunixe_store.feature.cart.ui

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddShoppingCart
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu
import com.zunixe.zunixe_store.feature.catalog.domain.Product
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

private val BrandGradient = Brush.linearGradient(
    listOf(AppColors.BrandLight, AppColors.Brand, AppColors.BrandDark),
)
private val SuccessGradient = Brush.linearGradient(
    listOf(AppColors.SuccessBright, AppColors.Success),
)

/**
 * Tombol tambah-ke-keranjang dengan animasi:
 * idle → **berputar** (loading) → **centang** (sukses) + haptic.
 */
@Composable
fun AddToCartButton(
    product: Product,
    onAdd: suspend (productId: String) -> Boolean,
    modifier: Modifier = Modifier,
    compact: Boolean = false,
    expand: Boolean = false,
    label: String = "Beli",
    onNeedLogin: () -> Unit = {},
    onError: (String) -> Unit = {},
) {
    var busy by remember { mutableStateOf(false) }
    var done by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    val haptics = LocalHapticFeedback.current
    val interactionSource = remember { MutableInteractionSource() }

    if (product.stock <= 0) {
        OutOfStock(compact = compact, expand = expand, modifier = modifier)
        return
    }

    val height = if (compact) 32.dp else 52.dp
    val radius = if (compact) 16.dp else 14.dp

    Box(
        modifier = modifier
            .then(if (expand) Modifier.fillMaxWidth() else Modifier)
            .height(height)
            .clip(RoundedCornerShape(radius))
            .background(if (done) SuccessGradient else BrandGradient)
            .clickable(
                enabled = !busy,
                interactionSource = interactionSource,
                indication = null,
            ) {
                scope.launch {
                    busy = true
                    val ok = onAdd(product.id)
                    busy = false
                    if (ok) {
                        done = true
                        haptics.performHapticFeedback(HapticFeedbackType.LongPress)
                        delay(1300)
                        done = false
                    }
                }
            }
            .padding(horizontal = if (compact) 12.dp else 16.dp),
        contentAlignment = if (expand) Alignment.Center else Alignment.CenterStart,
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = if (expand) Modifier else Modifier,
        ) {
            CartIconState(busy = busy, done = done, size = if (compact) 14.dp else 20.dp)
            Spacer(Modifier.width(if (compact) 5.dp else 10.dp))
            AnimatedContent(
                targetState = when {
                    busy -> label
                    done -> if (compact) "OK" else "Berhasil Ditambahkan"
                    else -> label
                },
                transitionSpec = {
                    (fadeIn(tween(150)) + scaleIn(tween(150), initialScale = 0.9f))
                        .togetherWith(fadeOut(tween(100)))
                        .using(SizeTransform(clip = false))
                },
                label = "cartLabel",
            ) { text ->
                Text(
                    text = text,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontFamily = Ubuntu,
                        color = Color.White,
                        fontSize = if (compact) 12.5.sp else 16.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.2.sp,
                    ),
                )
            }
        }
    }
}

/** Ikon: berputar saat busy, centang saat sukses. */
@Composable
private fun CartIconState(busy: Boolean, done: Boolean, size: Dp) {
    val infinite = rememberInfiniteTransition(label = "spin")
    val rotation by infinite.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(700, easing = LinearEasing),
        ),
        label = "rotation",
    )

    AnimatedContent(
        targetState = when {
            busy -> 1
            done -> 2
            else -> 0
        },
        transitionSpec = {
            (fadeIn(tween(150)) + scaleIn(tween(180), initialScale = 0.6f))
                .togetherWith(fadeOut(tween(100)))
        },
        label = "cartIcon",
    ) { mode ->
        when (mode) {
            1 -> Icon(
                Icons.Filled.AddShoppingCart,
                contentDescription = "Memproses",
                tint = Color.White,
                modifier = Modifier.size(size).rotate(rotation),
            )
            2 -> Icon(
                Icons.Filled.CheckCircle,
                contentDescription = "Berhasil",
                tint = Color.White,
                modifier = Modifier.size(size),
            )
            else -> Icon(
                Icons.Filled.AddShoppingCart,
                contentDescription = "Tambah ke keranjang",
                tint = Color.White,
                modifier = Modifier.size(size),
            )
        }
    }
}

@Composable
private fun OutOfStock(compact: Boolean, expand: Boolean, modifier: Modifier) {
    Box(
        modifier = modifier
            .then(if (expand) Modifier.fillMaxWidth() else Modifier)
            .height(if (compact) 32.dp else 52.dp)
            .clip(RoundedCornerShape(if (compact) 16.dp else 14.dp))
            .background(AppColors.Disabled)
            .padding(horizontal = 16.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            "Stok Habis",
            maxLines = 1,
            style = MaterialTheme.typography.labelMedium.copy(
                fontFamily = Ubuntu,
                color = Color.White,
                fontWeight = FontWeight.Bold,
            ),
        )
    }
}
