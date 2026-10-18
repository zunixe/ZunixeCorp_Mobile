package com.zunixe.zunixe_store.feature.checkout.ui

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.runtime.collectAsState
import androidx.hilt.navigation.compose.hiltViewModel
import com.zunixe.zunixe_store.core.config.StoreConfig
import com.zunixe.zunixe_store.core.format.formatRupiah
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu
import com.zunixe.zunixe_store.core.ui.AppHeader
import com.zunixe.zunixe_store.core.ui.GradientButton
import com.zunixe.zunixe_store.feature.cart.ui.CartViewModel
import kotlinx.coroutines.launch

/** Layar checkout: ringkasan keranjang + form penerima + buat pesanan. */
@Composable
fun CheckoutScreen(
    onBack: () -> Unit,
    onSuccess: (orderCode: String, total: Int) -> Unit,
    onNeedLogin: () -> Unit,
    checkoutViewModel: CheckoutViewModel = hiltViewModel(),
    cartViewModel: CartViewModel = hiltViewModel(),
) {
    val cart by cartViewModel.state.collectAsState()
    val state by checkoutViewModel.state.collectAsState()
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    val context = LocalContext.current

    var name by remember { mutableStateOf("") }
    var phone by remember { mutableStateOf("") }
    var address by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }
    var error by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(Unit) {
        checkoutViewModel.prefill { fullName, tel ->
            if (name.isEmpty()) name = fullName
            if (phone.isEmpty()) phone = tel
        }
    }

    Scaffold(
        containerColor = AppColors.Background,
        snackbarHost = { SnackbarHost(snackbar) },
        bottomBar = {
            Surface(color = Color.White, shadowElevation = 8.dp) {
                Column(Modifier.padding(16.dp)) {
                    GradientButton(
                        label = "Buat Pesanan - ${formatRupiah(cart.totalPrice)}",
                        height = 50.dp,
                        fontSize = 16,
                        loading = state.submitting,
                        enabled = cart.items.isNotEmpty(),
                        onClick = {
                            val validation = validateCheckout(name, phone, address)
                            if (validation != null) {
                                error = validation
                                return@GradientButton
                            }
                            error = null
                            checkoutViewModel.submit(
                                name = name,
                                phone = phone,
                                address = address,
                                notes = notes,
                                onSuccess = { confirmation ->
                                    scope.launch { cartViewModel.fetchCart() }
                                    onSuccess(confirmation.orderCode, confirmation.total)
                                },
                                onError = { message ->
                                    scope.launch { snackbar.showSnackbar(message) }
                                },
                            )
                        },
                    )
                }
            }
        },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            AppHeader(
                title = "Checkout",
                showBack = true,
                onBack = onBack,
                showSearch = false,
                showCart = false,
                showProfile = false,
            )
            Column(
                Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
            ) {
                // Ringkasan produk
                Surface(color = Color.White, shape = RoundedCornerShape(12.dp)) {
                    Column(Modifier.padding(16.dp)) {
                        Text(
                            "Produk (${cart.itemCount})",
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 15.sp,
                        )
                        Spacer(Modifier.height(8.dp))
                        cart.items.forEach { item ->
                            Row(
                                Modifier.fillMaxWidth().padding(bottom = 6.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                            ) {
                                Text(
                                    "${item.productName} x${item.quantity}",
                                    fontSize = 13.sp,
                                    modifier = Modifier.weight(1f),
                                )
                                Text(formatRupiah(item.subtotal), fontSize = 13.sp)
                            }
                        }
                        Spacer(Modifier.height(8.dp))
                        Row(
                            Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                        ) {
                            Text("Ongkir", fontSize = 13.sp)
                            Text("Rp 0 (GRATIS)", fontSize = 13.sp, color = AppColors.Success)
                        }
                        Spacer(Modifier.height(6.dp))
                        Row(
                            Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                        ) {
                            Text("Total", fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
                            Text(
                                formatRupiah(cart.totalPrice),
                                fontWeight = FontWeight.Bold,
                                fontSize = 17.sp,
                                color = AppColors.Brand,
                            )
                        }
                    }
                }

                Spacer(Modifier.height(16.dp))

                // Data penerima
                Surface(color = Color.White, shape = RoundedCornerShape(12.dp)) {
                    Column(Modifier.padding(16.dp)) {
                        Text("Data Penerima", fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
                        Spacer(Modifier.height(12.dp))
                        OutlinedTextField(name, { name = it }, label = { Text("Nama Lengkap") },
                            singleLine = true, modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(10.dp))
                        Spacer(Modifier.height(12.dp))
                        OutlinedTextField(phone, { phone = it }, label = { Text("No. WhatsApp") },
                            singleLine = true, modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(10.dp),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone, imeAction = ImeAction.Next))
                        Spacer(Modifier.height(12.dp))
                        OutlinedTextField(address, { address = it }, label = { Text("Alamat Lengkap Pengiriman") },
                            minLines = 2, maxLines = 3, modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(10.dp))
                        Spacer(Modifier.height(12.dp))
                        OutlinedTextField(notes, { notes = it }, label = { Text("Catatan (opsional)") },
                            minLines = 1, maxLines = 2, modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(10.dp))
                        error?.let {
                            Spacer(Modifier.height(8.dp))
                            Text(it, color = AppColors.Error, fontSize = 12.sp)
                        }
                    }
                }

                Spacer(Modifier.height(16.dp))

                // Info pembayaran
                Surface(
                    color = AppColors.WarningBg,
                    shape = RoundedCornerShape(12.dp),
                    border = androidx.compose.foundation.BorderStroke(1.dp, AppColors.WarningBorder),
                ) {
                    Text(
                        if (StoreConfig.hasBank) {
                            "Bayar via transfer ${StoreConfig.bankName} ${StoreConfig.accountNumber} " +
                                "(a.n. ${StoreConfig.accountHolder}), lalu konfirmasi via WhatsApp."
                        } else {
                            "Bayar via transfer bank, lalu konfirmasi via WhatsApp ${StoreConfig.waDisplay}. " +
                                "No. rekening tertera setelah pesanan dibuat."
                        },
                        modifier = Modifier.padding(14.dp),
                        fontSize = 12.sp,
                        color = AppColors.Grey,
                        lineHeight = 18.sp,
                    )
                }
                Spacer(Modifier.height(80.dp))
            }
        }
    }
}

/** Buka URL eksternal (WA) — dipakai layar pembayaran. */
internal fun openUrl(context: android.content.Context, url: String) {
    runCatching {
        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
    }
}
