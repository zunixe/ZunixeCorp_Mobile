package com.zunixe.zunixe_store.feature.cart.ui

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddCircleOutline
import androidx.compose.material.icons.filled.CloudOff
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.RemoveCircleOutline
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.zunixe.zunixe_store.core.format.formatRupiah
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu
import com.zunixe.zunixe_store.core.ui.AppHeader
import com.zunixe.zunixe_store.core.ui.GradientButton
import com.zunixe.zunixe_store.core.ui.ProductImage
import com.zunixe.zunixe_store.feature.cart.domain.CartItem

/** Layar keranjang: list item, qty +/-, total, checkout. */
@Composable
fun CartScreen(
    onSwitchToProduk: () -> Unit,
    onCheckout: () -> Unit,
    viewModel: CartViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()

    Scaffold(containerColor = AppColors.Background) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            AppHeader(
                title = "Keranjang",
                showSearch = false,
                showCart = false,
                showProfile = false,
                cartCount = state.itemCount,
            )

            when {
                state.loading && state.items.isEmpty() -> Box(
                    Modifier.fillMaxSize(), contentAlignment = Alignment.Center,
                ) {
                    CircularProgressIndicator(color = AppColors.Brand)
                }

                state.error != null && state.items.isEmpty() -> Column(
                    modifier = Modifier.fillMaxSize().padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center,
                ) {
                    Icon(Icons.Default.CloudOff, null, tint = AppColors.Muted, modifier = Modifier.size(56.dp))
                    Spacer(Modifier.height(12.dp))
                    Text(state.error ?: "", color = AppColors.Grey, fontSize = 14.sp)
                    Spacer(Modifier.height(16.dp))
                    GradientButton(
                        label = "Coba Lagi",
                        height = 44.dp,
                        expanded = false,
                        onClick = {
                            viewModel.clearError()
                            viewModel.syncUser(null)
                        },
                    )
                }

                state.items.isEmpty() -> EmptyCart(onSwitchToProduk)

                else -> Column(Modifier.fillMaxSize()) {
                    LazyColumn(
                        modifier = Modifier.weight(1f),
                        contentPadding = androidx.compose.foundation.layout.PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp),
                    ) {
                        items(state.items, key = { it.id }) { item ->
                            CartRow(
                                item = item,
                                onMinus = { viewModel.updateQuantity(item.id, item.quantity - 1) },
                                onPlus = { viewModel.updateQuantity(item.id, item.quantity + 1) },
                                onRemove = { viewModel.removeItem(item.id) },
                            )
                        }
                    }

                    Surface(color = Color.White, shadowElevation = 8.dp) {
                        Column(Modifier.navigationBarsPadding().padding(16.dp)) {
                            Row(
                                Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                            ) {
                                Text(
                                    "Total",
                                    style = MaterialTheme.typography.titleMedium.copy(fontFamily = Ubuntu),
                                )
                                Text(
                                    formatRupiah(state.totalPrice),
                                    style = MaterialTheme.typography.titleLarge.copy(
                                        fontFamily = Ubuntu,
                                        color = AppColors.Brand,
                                        fontWeight = FontWeight.Bold,
                                    ),
                                )
                            }
                            Spacer(Modifier.height(12.dp))
                            GradientButton(
                                label = "Checkout",
                                height = 48.dp,
                                fontSize = 16,
                                enabled = state.items.isNotEmpty(),
                                onClick = onCheckout,
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun CartRow(
    item: CartItem,
    onMinus: () -> Unit,
    onPlus: () -> Unit,
    onRemove: () -> Unit,
) {
    val atStockLimit = item.quantity >= item.stock

    Surface(color = Color.White, shape = RoundedCornerShape(12.dp)) {
        Row(Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(64.dp).clip(RoundedCornerShape(8.dp))) {
                ProductImage(url = item.productImage, modifier = Modifier.fillMaxSize(), iconSize = 28.dp)
            }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(
                    item.productName,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    fontSize = 13.sp,
                )
                Spacer(Modifier.height(4.dp))
                Text(
                    formatRupiah(item.price.toInt()),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppColors.Brand,
                )
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = onMinus, modifier = Modifier.size(32.dp)) {
                    Icon(
                        Icons.Default.RemoveCircleOutline,
                        contentDescription = "Kurangi",
                        tint = AppColors.Brand,
                        modifier = Modifier.size(24.dp),
                    )
                }
                // Angka qty beranimasi (slide + fade) saat berubah.
                AnimatedContent(
                    targetState = item.quantity,
                    transitionSpec = {
                        (slideInVertically(tween(180)) { it / 2 } + fadeIn(tween(180)))
                            .togetherWith(slideOutVertically(tween(180)) { -it / 2 } + fadeOut(tween(120)))
                            .using(SizeTransform(clip = false))
                    },
                    label = "qty",
                ) { qty ->
                    Text(
                        "$qty",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.padding(horizontal = 4.dp),
                    )
                }
                IconButton(
                    onClick = onPlus,
                    enabled = !atStockLimit,
                    modifier = Modifier.size(32.dp),
                ) {
                    Icon(
                        Icons.Default.AddCircleOutline,
                        contentDescription = "Tambah",
                        tint = if (atStockLimit) AppColors.Muted else AppColors.Brand,
                        modifier = Modifier.size(24.dp),
                    )
                }
            }
            IconButton(onClick = onRemove, modifier = Modifier.size(32.dp)) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Hapus",
                    tint = AppColors.Muted,
                    modifier = Modifier.size(20.dp),
                )
            }
        }
    }
}

@Composable
private fun EmptyCart(onSwitchToProduk: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Surface(color = Color.White, shape = RoundedCornerShape(12.dp)) {
            Column(
                Modifier.padding(32.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Icon(
                    Icons.Outlined.ShoppingCart,
                    contentDescription = null,
                    tint = AppColors.Muted,
                    modifier = Modifier.size(64.dp),
                )
                Spacer(Modifier.height(16.dp))
                Text(
                    "Keranjang Kosong",
                    style = MaterialTheme.typography.titleLarge.copy(
                        fontFamily = Ubuntu, color = AppColors.Ink,
                    ),
                )
                Spacer(Modifier.height(8.dp))
                Text(
                    "Tambah produk atau masuk untuk melanjutkan belanja",
                    fontSize = 13.sp,
                    color = AppColors.Grey,
                )
                Spacer(Modifier.height(20.dp))
                GradientButton(
                    label = "Lanjutkan berbelanja",
                    height = 44.dp,
                    expanded = false,
                    onClick = onSwitchToProduk,
                )
            }
        }
    }
}

/** Latar lembut untuk area konten. */
@Composable
internal fun SoftBackground(content: @Composable () -> Unit) {
    Box(Modifier.fillMaxSize().background(AppColors.Background)) { content() }
}
