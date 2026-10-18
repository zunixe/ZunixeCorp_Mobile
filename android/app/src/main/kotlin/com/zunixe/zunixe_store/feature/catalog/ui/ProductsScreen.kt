package com.zunixe.zunixe_store.feature.catalog.ui

import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.grid.rememberLazyGridState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.FilterList
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.AssistChip
import androidx.compose.material3.AssistChipDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu
import com.zunixe.zunixe_store.core.ui.AppHeader
import com.zunixe.zunixe_store.feature.catalog.domain.Product
import com.zunixe.zunixe_store.feature.catalog.domain.productSortLabels
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.filter

/** Daftar produk dengan cari, filter kategori, sort, dan pagination. */
@Composable
fun ProductsScreen(
    showBack: Boolean,
    cartCount: Int,
    onBack: () -> Unit,
    onCart: () -> Unit,
    onProductClick: (Product) -> Unit,
    addButton: @Composable (Product) -> Unit,
    viewModel: ProductsViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()
    val gridState = rememberLazyGridState()
    var showSearch by remember { mutableStateOf(false) }
    var sortOpen by remember { mutableStateOf(false) }

    // Infinite scroll: muat lagi saat mendekati akhir.
    LaunchedEffect(gridState) {
        snapshotFlow {
            val total = gridState.layoutInfo.totalItemsCount
            val last = gridState.layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: 0
            total > 0 && last >= total - 2
        }
            .distinctUntilChanged()
            .filter { it }
            .collect { viewModel.loadMore() }
    }

    Scaffold(containerColor = AppColors.Background) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            AppHeader(
                title = "zunixe",
                showBack = showBack,
                onBack = onBack,
                showSearch = true,
                onSearch = { showSearch = true },
                showCart = true,
                cartCount = cartCount,
                onCart = onCart,
                showProfile = false,
            )

            // Baris filter
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(Icons.Default.FilterList, null, tint = AppColors.Brand, modifier = Modifier.width(18.dp))
                Spacer(Modifier.width(8.dp))
                Row(
                    modifier = Modifier.weight(1f).horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    CategoryChip("Semua", state.category.isEmpty()) { viewModel.setCategory("") }
                    state.categories.forEach { category ->
                        CategoryChip(category, state.category == category) {
                            viewModel.setCategory(category)
                        }
                    }
                }
                Spacer(Modifier.width(8.dp))
                Box {
                    TextButton(onClick = { sortOpen = true }) {
                        Text(state.sortLabel, fontSize = 13.sp, color = AppColors.Ink)
                    }
                    DropdownMenu(expanded = sortOpen, onDismissRequest = { sortOpen = false }) {
                        productSortLabels.forEach { label ->
                            DropdownMenuItem(
                                text = { Text(label, fontSize = 13.sp) },
                                onClick = {
                                    sortOpen = false
                                    viewModel.setSort(label)
                                },
                            )
                        }
                    }
                }
            }

            if (state.search.isNotEmpty()) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        "Hasil: \"${state.search}\"",
                        modifier = Modifier.weight(1f),
                        fontSize = 12.sp,
                        color = AppColors.Grey,
                    )
                    TextButton(onClick = { viewModel.setSearch("") }) {
                        Text("Hapus", fontSize = 12.sp, color = AppColors.Brand)
                    }
                }
            }

            Box(Modifier.fillMaxSize()) {
                when {
                    state.loading -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = AppColors.Brand)
                    }

                    state.error != null && state.items.isEmpty() -> Column(
                        modifier = Modifier.fillMaxSize(),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center,
                    ) {
                        Text("Gagal memuat produk", fontWeight = FontWeight.SemiBold)
                        Text(state.error ?: "", fontSize = 13.sp, color = AppColors.Grey)
                        Spacer(Modifier.height(16.dp))
                        OutlinedButton(onClick = { viewModel.reload() }) { Text("Coba Lagi") }
                    }

                    state.isEmpty -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text("Tidak ada produk ditemukan", color = AppColors.Grey)
                    }

                    else -> LazyVerticalGrid(
                        state = gridState,
                        columns = androidx.compose.foundation.lazy.grid.GridCells.Fixed(2),
                        contentPadding = androidx.compose.foundation.layout.PaddingValues(16.dp),
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp),
                    ) {
                        items(state.items, key = { it.id }) { product ->
                            ProductCard(
                                product = product,
                                onClick = { onProductClick(product) },
                                bottomSlot = { addButton(product) },
                            )
                        }
                        if (state.loadingMore) {
                            item(span = { GridItemSpan(2) }) {
                                Box(Modifier.fillMaxWidth().padding(16.dp), contentAlignment = Alignment.Center) {
                                    CircularProgressIndicator(color = AppColors.Brand)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    if (showSearch) {
        SearchDialog(
            initial = state.search,
            onDismiss = { showSearch = false },
            onSearch = {
                showSearch = false
                viewModel.setSearch(it)
            },
        )
    }
}

@Composable
private fun CategoryChip(label: String, selected: Boolean, onClick: () -> Unit) {
    AssistChip(
        onClick = onClick,
        label = { Text(label, fontSize = 12.sp) },
        colors = AssistChipDefaults.assistChipColors(
            containerColor = if (selected) AppColors.Brand else AppColors.ChipFill,
            labelColor = if (selected) Color.White else AppColors.Ink,
        ),
    )
}

@Composable
private fun SearchDialog(initial: String, onDismiss: () -> Unit, onSearch: (String) -> Unit) {
    var text by remember { mutableStateOf(initial) }
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Cari Produk") },
        text = {
            OutlinedTextField(
                value = text,
                onValueChange = { text = it },
                placeholder = { Text("Ketik nama produk...") },
                leadingIcon = { Icon(Icons.Default.Search, null) },
                singleLine = true,
            )
        },
        confirmButton = {
            TextButton(onClick = { onSearch(text.trim()) }) {
                Text("Cari", color = AppColors.Brand)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Batal", color = AppColors.Grey) }
        },
    )
}
