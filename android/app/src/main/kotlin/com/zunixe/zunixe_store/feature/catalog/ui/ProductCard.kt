package com.zunixe.zunixe_store.feature.catalog.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zunixe.zunixe_store.core.format.formatRupiah
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu
import com.zunixe.zunixe_store.core.ui.ProductImage
import com.zunixe.zunixe_store.feature.catalog.domain.Product

/** Kartu produk untuk grid katalog. */
@Composable
fun ProductCard(
    product: Product,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    bottomSlot: @Composable (() -> Unit)? = null,
) {
    Surface(
        modifier = modifier.fillMaxWidth().clickable(onClick = onClick),
        shape = RoundedCornerShape(8.dp),
        color = androidx.compose.ui.graphics.Color.White,
        shadowElevation = 2.dp,
    ) {
        Column {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(1f)
                    .clip(RoundedCornerShape(topStart = 8.dp, topEnd = 8.dp)),
            ) {
                ProductImage(url = product.imageUrl, modifier = Modifier.fillMaxWidth().aspectRatio(1f))
                if (product.discountPercent > 0) {
                    Box(
                        modifier = Modifier
                            .align(Alignment.TopStart)
                            .padding(8.dp)
                            .background(AppColors.Brand, RoundedCornerShape(4.dp))
                            .padding(horizontal = 6.dp, vertical = 3.dp),
                    ) {
                        Text(
                            "-${product.discountPercent}%",
                            color = androidx.compose.ui.graphics.Color.White,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                        )
                    }
                }
            }

            Column(modifier = Modifier.padding(10.dp)) {
                Text(
                    product.name,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    style = MaterialTheme.typography.bodySmall.copy(
                        fontFamily = Ubuntu, fontSize = 12.sp, lineHeight = 16.sp,
                    ),
                )
                Spacer(Modifier.height(6.dp))
                if (product.discountPercent > 0) {
                    Text(
                        formatRupiah(product.originalPrice),
                        fontSize = 11.sp,
                        color = AppColors.Muted,
                        textDecoration = TextDecoration.LineThrough,
                    )
                }
                Text(
                    formatRupiah(product.price),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = MaterialTheme.typography.titleSmall.copy(
                        fontFamily = Ubuntu,
                        fontSize = 14.5.sp,
                        fontWeight = FontWeight.Bold,
                        color = AppColors.Brand,
                    ),
                )
                Spacer(Modifier.height(8.dp))
                bottomSlot?.invoke()
            }
        }
    }
}

/** Grid produk dua kolom. */
@Composable
fun ProductGrid(
    products: List<Product>,
    onProductClick: (Product) -> Unit,
    bottomSlot: @Composable (Product) -> Unit = {},
) {
    androidx.compose.foundation.lazy.grid.LazyVerticalGrid(
        columns = androidx.compose.foundation.lazy.grid.GridCells.Fixed(2),
        contentPadding = androidx.compose.foundation.layout.PaddingValues(16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        items(products.size) { index ->
            val product = products[index]
            ProductCard(
                product = product,
                onClick = { onProductClick(product) },
                bottomSlot = { bottomSlot(product) },
            )
        }
    }
}
