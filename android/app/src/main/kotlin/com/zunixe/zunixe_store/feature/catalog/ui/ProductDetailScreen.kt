package com.zunixe.zunixe_store.feature.catalog.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Cancel
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.zunixe.zunixe_store.core.format.formatRupiah
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu
import com.zunixe.zunixe_store.core.ui.AppHeader
import com.zunixe.zunixe_store.core.ui.ProductImage
import com.zunixe.zunixe_store.feature.catalog.domain.Product

/** Detail produk: galeri, harga, stok, deskripsi, tombol beli. */
@Composable
fun ProductDetailScreen(
    productId: String?,
    initialProduct: Product?,
    cartCount: Int,
    onBack: () -> Unit,
    onCart: () -> Unit,
    addButton: @Composable (Product) -> Unit,
    viewModel: ProductDetailViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()

    LaunchedEffect(productId, initialProduct) {
        when {
            initialProduct != null -> viewModel.setProduct(initialProduct)
            productId != null -> viewModel.load(productId)
        }
    }

    Scaffold(
        containerColor = AppColors.Background,
        bottomBar = {
            state.product?.let { product ->
                Surface(color = Color.White, shadowElevation = 8.dp) {
                    Box(
                        Modifier
                            .fillMaxWidth()
                            .navigationBarsPadding()
                            .padding(16.dp),
                    ) {
                        addButton(product)
                    }
                }
            }
        },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            AppHeader(
                title = "Detail Produk",
                showBack = true,
                onBack = onBack,
                showSearch = false,
                showCart = true,
                cartCount = cartCount,
                onCart = onCart,
                showProfile = false,
            )

            when {
                state.loading -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = AppColors.Brand)
                }

                state.notFound || state.product == null -> Box(
                    Modifier.fillMaxSize(), contentAlignment = Alignment.Center,
                ) {
                    Text("Produk tidak ditemukan", color = AppColors.Grey)
                }

                else -> ProductDetailBody(state)
            }
        }
    }
}

@Composable
private fun ProductDetailBody(state: ProductDetailUiState) {
    val product = state.product ?: return
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
        // Galeri
        if (state.gallery.isNotEmpty()) {
            Surface(color = Color.White, modifier = Modifier.fillMaxWidth()) {
                ProductImage(
                    url = state.currentImage,
                    modifier = Modifier.fillMaxWidth().height(280.dp).padding(20.dp),
                    iconSize = 56.dp,
                )
            }
            if (state.gallery.size > 1) {
                Surface(color = Color.White, modifier = Modifier.fillMaxWidth()) {
                    LazyRow(
                        contentPadding = androidx.compose.foundation.layout.PaddingValues(
                            start = 20.dp, end = 20.dp, bottom = 14.dp,
                        ),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                    ) {
                        items(state.gallery.size) { index ->
                            val selected = index == state.imageIndex
                            Box(
                                Modifier
                                    .size(56.dp)
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(AppColors.InputFill)
                                    .then(Modifier),
                            ) {
                                ProductImage(
                                    url = state.gallery[index],
                                    modifier = Modifier.fillMaxSize(),
                                    iconSize = 20.dp,
                                )
                                if (selected) {
                                    Box(
                                        Modifier
                                            .matchParentSize()
                                            .clip(RoundedCornerShape(6.dp))
                                            .background(AppColors.Brand.copy(alpha = 0.18f)),
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }

        // Info utama
        Surface(color = Color.White, modifier = Modifier.fillMaxWidth()) {
            Column(Modifier.padding(horizontal = 20.dp, vertical = 16.dp)) {
                Text(
                    product.name,
                    style = MaterialTheme.typography.titleLarge.copy(
                        fontFamily = Ubuntu, color = AppColors.Ink, lineHeight = 25.sp,
                    ),
                )
                Spacer(Modifier.height(10.dp))
                Row(verticalAlignment = Alignment.Bottom) {
                    Text(
                        formatRupiah(product.price),
                        style = MaterialTheme.typography.headlineMedium.copy(
                            fontFamily = Ubuntu, fontSize = 24.sp,
                            fontWeight = FontWeight.Bold, color = AppColors.Brand,
                        ),
                    )
                    if (product.originalPrice > product.price) {
                        Spacer(Modifier.width(10.dp))
                        Text(
                            formatRupiah(product.originalPrice),
                            fontSize = 14.sp,
                            color = AppColors.Grey,
                            textDecoration = TextDecoration.LineThrough,
                        )
                        Spacer(Modifier.width(8.dp))
                        Box(
                            Modifier
                                .background(AppColors.ErrorBg, RoundedCornerShape(4.dp))
                                .padding(horizontal = 6.dp, vertical = 2.dp),
                        ) {
                            Text(
                                "-${product.discountPercent}%",
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                color = AppColors.Brand,
                            )
                        }
                    }
                }

                Spacer(Modifier.height(14.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    StockBadge(product.stock)
                    if (product.category.isNotEmpty() && product.category != "0") {
                        Spacer(Modifier.width(8.dp))
                        Box(
                            Modifier
                                .background(AppColors.ChipFillAlt, RoundedCornerShape(6.dp))
                                .padding(horizontal = 10.dp, vertical = 5.dp),
                        ) {
                            Text(product.category, fontSize = 12.sp, color = AppColors.ChipText)
                        }
                    }
                }

                product.description?.takeIf { it.isNotBlank() }?.let { description ->
                    Spacer(Modifier.height(18.dp))
                    androidx.compose.material3.HorizontalDivider(color = AppColors.Border)
                    Spacer(Modifier.height(10.dp))
                    Text(
                        "Deskripsi Produk",
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontFamily = Ubuntu, color = AppColors.Ink,
                        ),
                    )
                    Spacer(Modifier.height(8.dp))
                    Text(description, fontSize = 14.sp, color = AppColors.Grey, lineHeight = 22.sp)
                }
            }
        }
        Spacer(Modifier.height(16.dp))
    }
}

@Composable
private fun StockBadge(stock: Int) {
    val inStock = stock > 0
    Box(
        Modifier
            .background(if (inStock) AppColors.SuccessBg else AppColors.ErrorBg, RoundedCornerShape(6.dp))
            .padding(horizontal = 10.dp, vertical = 5.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
                if (inStock) Icons.Default.CheckCircle else Icons.Default.Cancel,
                contentDescription = null,
                tint = if (inStock) AppColors.Success else Color.Red,
                modifier = Modifier.size(13.dp),
            )
            Spacer(Modifier.width(5.dp))
            Text(
                if (inStock) "Stok $stock" else "Stok Habis",
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold,
                color = if (inStock) AppColors.Success else Color.Red,
            )
        }
    }
}

/** Helper klik thumbnail (tidak dipakai langsung; disediakan untuk a11y test). */
@Composable
internal fun Thumb(selected: Boolean, onClick: () -> Unit) {
    Box(
        Modifier
            .size(56.dp)
            .clip(RoundedCornerShape(6.dp))
            .background(if (selected) AppColors.Brand else AppColors.InputFill)
            .clickable(onClick = onClick),
    )
}
