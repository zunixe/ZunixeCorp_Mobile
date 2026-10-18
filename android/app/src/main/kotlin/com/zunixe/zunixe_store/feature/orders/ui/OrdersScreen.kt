package com.zunixe.zunixe_store.feature.orders.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.zunixe.zunixe_store.core.format.formatOrderDate
import com.zunixe.zunixe_store.core.format.formatRupiah
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu
import com.zunixe.zunixe_store.core.ui.AppHeader
import com.zunixe.zunixe_store.feature.orders.domain.Order
import com.zunixe.zunixe_store.feature.orders.domain.orderStatusLabel
import kotlinx.coroutines.launch
import java.time.ZoneId

/** Daftar pesanan milik user + batalkan. */
@Composable
fun OrdersScreen(
    onBack: () -> Unit,
    onLogin: () -> Unit,
    viewModel: OrdersViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    var cancelTarget by remember { mutableStateOf<Order?>(null) }
    var expandedId by remember { mutableStateOf<String?>(null) }

    Scaffold(
        containerColor = AppColors.Background,
        snackbarHost = { SnackbarHost(snackbar) },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            AppHeader(
                title = "Pesanan Saya",
                showBack = true,
                onBack = onBack,
                showSearch = false,
                showCart = false,
                showProfile = false,
            )

            when {
                state.loading -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = AppColors.Brand)
                }

                state.error != null -> Column(
                    Modifier.fillMaxSize(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center,
                ) {
                    Text(state.error ?: "", color = AppColors.Grey)
                    Spacer(Modifier.height(16.dp))
                    OutlinedButton(onClick = { viewModel.reload() }) { Text("Coba Lagi") }
                }

                state.orders.isEmpty() -> Column(
                    Modifier.fillMaxSize(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center,
                ) {
                    Text("Belum ada pesanan", color = AppColors.Grey)
                    Spacer(Modifier.height(16.dp))
                    TextButton(onClick = onLogin) { Text("Masuk", color = AppColors.Brand) }
                }

                else -> LazyColumn(
                    contentPadding = androidx.compose.foundation.layout.PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    items(state.orders, key = { it.id }) { order ->
                        OrderCard(
                            order = order,
                            expanded = expandedId == order.id,
                            onToggle = {
                                expandedId = if (expandedId == order.id) null else order.id
                            },
                            onCancel = { cancelTarget = order },
                        )
                    }
                }
            }
        }
    }

    cancelTarget?.let { order ->
        AlertDialog(
            onDismissRequest = { cancelTarget = null },
            title = { Text("Batalkan pesanan?") },
            text = { Text("Pesanan ${order.orderCode} dibatalkan dan stok dikembalikan.") },
            confirmButton = {
                TextButton(onClick = {
                    cancelTarget = null
                    viewModel.cancelOrder(order.id) { ok, err ->
                        scope.launch {
                            snackbar.showSnackbar(
                                if (ok) "Pesanan ${order.orderCode} dibatalkan." else (err ?: "Gagal membatalkan."),
                            )
                        }
                    }
                }) { Text("Ya, Batalkan", color = Color.Red) }
            },
            dismissButton = {
                TextButton(onClick = { cancelTarget = null }) {
                    Text("Tidak", color = AppColors.Grey)
                }
            },
        )
    }
}

@Composable
private fun OrderCard(
    order: Order,
    expanded: Boolean,
    onToggle: () -> Unit,
    onCancel: () -> Unit,
) {
    Surface(color = Color.White, shape = RoundedCornerShape(12.dp)) {
        Column(Modifier.padding(16.dp)) {
            Row(
                Modifier.fillMaxWidth().let { m -> m },
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Column(Modifier.weight(1f)) {
                    Text(order.orderCode, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    order.createdAt?.let { instant ->
                        val local = instant.atZone(ZoneId.systemDefault())
                        val date = formatOrderDate(
                            local.dayOfMonth, local.monthValue, local.year,
                            local.hour, local.minute,
                        )
                        Text(
                            "$date${if (order.isPaid) "" else " • Belum bayar"}",
                            fontSize = 12.sp,
                            color = AppColors.Grey,
                        )
                    }
                }
                StatusBadge(order.status)
            }

            Spacer(Modifier.height(6.dp))
            Text(
                "${order.itemCount} item - ${formatRupiah(order.total)}",
                fontSize = 12.sp,
                color = AppColors.Grey,
            )

            TextButton(onClick = onToggle) {
                Text(if (expanded) "Tutup" else "Detail", color = AppColors.Brand, fontSize = 12.sp)
            }

            if (expanded) {
                order.items.forEach { item ->
                    Row(
                        Modifier.fillMaxWidth().padding(bottom = 6.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                    ) {
                        Text("${item.productName} x${item.quantity}", fontSize = 13.sp, modifier = Modifier.weight(1f))
                        Text(formatRupiah(item.subtotal), fontSize = 13.sp)
                    }
                }
                HorizontalDivider(color = AppColors.Border)
                Spacer(Modifier.height(8.dp))
                InfoRow("Alamat", order.shippingAddress.ifEmpty { "-" })
                if (order.customerPhone.isNotEmpty()) InfoRow("Telp", order.customerPhone)
                if (order.notes.isNotEmpty()) InfoRow("Catatan", order.notes)

                if (order.canCancel) {
                    Spacer(Modifier.height(12.dp))
                    OutlinedButton(
                        onClick = onCancel,
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(10.dp),
                    ) { Text("Batalkan Pesanan", fontSize = 13.sp, color = Color.Red) }
                }
            }
        }
    }
}

@Composable
private fun StatusBadge(status: String) {
    val color = orderStatusColor(status)
    Box(
        Modifier
            .background(color.copy(alpha = 0.1f), RoundedCornerShape(20.dp))
            .padding(horizontal = 10.dp, vertical = 4.dp),
    ) {
        Text(orderStatusLabel(status), fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = color)
    }
}

@Composable
private fun InfoRow(label: String, value: String) {
    Row(Modifier.padding(bottom = 6.dp)) {
        Text(label, modifier = Modifier.width(70.dp), fontSize = 12.sp, color = AppColors.Grey)
        Text(value, fontSize = 12.sp, modifier = Modifier.weight(1f))
    }
}

/** Warna badge status pesanan — fungsi murni agar dapat diuji. */
fun orderStatusColor(status: String): Color = when (status) {
    "processing" -> AppColors.Warning
    "shipped" -> AppColors.Info
    "completed" -> AppColors.Success
    "cancelled" -> Color.Red
    else -> AppColors.Grey
}
