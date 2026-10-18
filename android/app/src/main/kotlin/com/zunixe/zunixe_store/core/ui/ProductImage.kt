package com.zunixe.zunixe_store.core.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Image
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import coil3.compose.SubcomposeAsyncImage
import com.zunixe.zunixe_store.core.theme.AppColors

/**
 * Gambar produk anti-crash — padanan `ProductImage`.
 * URL kosong → placeholder, gagal → ikon, saat load → spinner.
 */
@Composable
fun ProductImage(
    url: String,
    modifier: Modifier = Modifier,
    width: Dp? = null,
    height: Dp? = null,
    iconSize: Dp = 40.dp,
) {
    val sizeModifier = modifier
        .then(if (width != null) Modifier.size(width = width, height = height ?: width) else Modifier)

    if (url.isBlank()) {
        ImagePlaceholder(sizeModifier, iconSize)
        return
    }

    SubcomposeAsyncImage(
        model = url,
        contentDescription = null,
        contentScale = ContentScale.Crop,
        modifier = sizeModifier,
        loading = {
            Box(Modifier.fillMaxSize().background(AppColors.InputFill), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(
                    modifier = Modifier.size(24.dp),
                    strokeWidth = 2.dp,
                    color = AppColors.Brand,
                )
            }
        },
        error = { ImagePlaceholder(Modifier.fillMaxSize(), iconSize) },
    )
}

@Composable
private fun ImagePlaceholder(modifier: Modifier, iconSize: Dp) {
    Box(
        modifier = modifier.background(AppColors.InputFill),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            Icons.Filled.Image,
            contentDescription = null,
            tint = Color(0xFFBDBDBD),
            modifier = Modifier.size(iconSize),
        )
    }
}
