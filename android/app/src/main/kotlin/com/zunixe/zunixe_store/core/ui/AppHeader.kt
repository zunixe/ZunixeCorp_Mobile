package com.zunixe.zunixe_store.core.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.material3.Badge
import androidx.compose.material3.BadgedBox
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu

/**
 * Header aplikasi — padanan `AppHeader` Flutter.
 *
 * Catatan: judul tetap tampil walau ada [leading] custom (bug lama Flutter
 * yang sudah diperbaiki, tetap terjaga di native).
 */
@Composable
fun AppHeader(
    title: String = "zunixe",
    subtitle: String? = null,
    showBack: Boolean = false,
    onBack: () -> Unit = {},
    showMenu: Boolean = false,
    onMenu: () -> Unit = {},
    showSearch: Boolean = true,
    onSearch: () -> Unit = {},
    showCart: Boolean = true,
    cartCount: Int = 0,
    onCart: () -> Unit = {},
    showProfile: Boolean = true,
    onProfile: () -> Unit = {},
    leading: (@Composable () -> Unit)? = null,
    trailing: @Composable (() -> Unit)? = null,
) {
    Surface(color = androidx.compose.ui.graphics.Color.White, shadowElevation = 0.dp) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = 56.dp)
                .statusBarsPadding()
                .padding(horizontal = 8.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            when {
                showMenu -> IconButton(onClick = onMenu, modifier = Modifier.size(40.dp)) {
                    Icon(Icons.Default.Menu, contentDescription = "Menu", tint = AppColors.Ink)
                }

                showBack -> IconButton(onClick = onBack, modifier = Modifier.size(40.dp)) {
                    Icon(
                        Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = "Kembali",
                        tint = AppColors.Ink,
                    )
                }

                leading != null -> leading()
                else -> ZunixeLogo(size = 30.dp)
            }

            Spacer(Modifier.width(8.dp))

            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.Center) {
                if (title.isNotEmpty()) {
                    Text(
                        text = title,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontFamily = Ubuntu,
                            fontWeight = FontWeight.Bold,
                            fontSize = if (showBack || showMenu) 17.sp else 16.sp,
                            color = AppColors.Ink,
                        ),
                    )
                }
                if (subtitle != null) {
                    Text(
                        text = subtitle,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontFamily = Ubuntu,
                            fontSize = 11.sp,
                            color = AppColors.Grey,
                        ),
                    )
                }
            }

            Row(verticalAlignment = Alignment.CenterVertically) {
                if (showSearch) {
                    IconButton(onClick = onSearch, modifier = Modifier.size(40.dp)) {
                        Icon(Icons.Default.Search, contentDescription = "Cari", tint = AppColors.Ink)
                    }
                }
                if (showCart) {
                    IconButton(onClick = onCart, modifier = Modifier.size(40.dp)) {
                        BadgedBox(
                            badge = {
                                if (cartCount > 0) {
                                    Badge(containerColor = AppColors.Brand) {
                                        Text("$cartCount", fontSize = 9.sp)
                                    }
                                }
                            },
                        ) {
                            Icon(
                                Icons.Outlined.ShoppingCart,
                                contentDescription = "Keranjang",
                                tint = AppColors.Ink,
                            )
                        }
                    }
                }
                if (showProfile) {
                    IconButton(onClick = onProfile, modifier = Modifier.size(40.dp)) {
                        Icon(Icons.Default.Person, contentDescription = "Akun", tint = AppColors.Ink)
                    }
                }
                trailing?.invoke()
            }
        }
    }
}
