package com.zunixe.zunixe_store.feature.home.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Chat
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material3.Badge
import androidx.compose.material3.BadgedBox
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.sp
import com.zunixe.zunixe_store.core.theme.AppColors

/** Shell 5 tab (Home, Produk, Keranjang, Akun, Chat) dengan IndexedStack. */
@Composable
fun MainShell(
    cartCount: Int,
    screens: List<@Composable () -> Unit>,
    initialIndex: Int = 0,
) {
    var current by rememberSaveable { mutableIntStateOf(initialIndex) }

    val items = listOf(
        Triple("Home", Icons.Default.Home, 0),
        Triple("Produk", Icons.Default.GridView, 1),
        Triple("Keranjang", Icons.Default.ShoppingCart, 2),
        Triple("Akun", Icons.Default.Person, 3),
        Triple("Chat", Icons.AutoMirrored.Filled.Chat, 4),
    )

    Scaffold(
        containerColor = AppColors.Background,
        bottomBar = {
            NavigationBar(containerColor = androidx.compose.ui.graphics.Color.White) {
                items.forEach { (label, icon, index) ->
                    val selected = current == index
                    NavigationBarItem(
                        selected = selected,
                        onClick = { current = index },
                        colors = androidx.compose.material3.NavigationBarItemDefaults.colors(
                            selectedIconColor = AppColors.Brand,
                            selectedTextColor = AppColors.Brand,
                            unselectedIconColor = AppColors.Grey,
                            unselectedTextColor = AppColors.Grey,
                            indicatorColor = AppColors.Brand.copy(alpha = 0.12f),
                        ),
                        icon = {
                            if (index == 2 && cartCount > 0) {
                                BadgedBox(badge = {
                                    Badge(containerColor = AppColors.Brand) {
                                        Text("$cartCount", fontSize = 9.sp)
                                    }
                                }) { Icon(icon, contentDescription = label) }
                            } else {
                                Icon(icon, contentDescription = label)
                            }
                        },
                        label = { Text(label, fontSize = 11.sp) },
                    )
                }
            }
        },
    ) { padding ->
        Box(Modifier.fillMaxSize().padding(padding)) {
            screens.getOrNull(current)?.let { screen -> screen() }
        }
    }
}

/** Ikon tak terpakai (jaga impor). */
@Suppress("unused")
private val unusedIcon: ImageVector = Icons.Default.Home
