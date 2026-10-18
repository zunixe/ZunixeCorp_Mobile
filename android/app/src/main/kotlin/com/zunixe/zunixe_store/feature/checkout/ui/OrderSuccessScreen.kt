package com.zunixe.zunixe_store.feature.checkout.ui

import android.content.ClipboardManager
import android.content.Context
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Chat
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.Payment
import androidx.compose.material.icons.filled.ReceiptLong
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zunixe.zunixe_store.core.config.StoreConfig
import com.zunixe.zunixe_store.core.format.formatRupiah
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu
import com.zunixe.zunixe_store.core.ui.AppHeader
import com.zunixe.zunixe_store.core.ui.GradientButton
import com.zunixe.zunixe_store.core.ui.ZunixeLogo
import kotlinx.coroutines.launch

/** Layar sukses pesanan + instruksi pembayaran manual. */
@Composable
fun OrderSuccessScreen(
    orderCode: String,
    total: Int,
    onViewOrders: () -> Unit,
    onBackHome: () -> Unit,
) {
    val context = LocalContext.current
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()

    Scaffold(
        containerColor = Color.White,
        snackbarHost = { SnackbarHost(snackbar) },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            AppHeader(
                title = "Pesanan Berhasil",
                showBack = false,
                showSearch = false,
                showCart = false,
                showProfile = false,
            )
            Column(
                Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Box {
                    ZunixeLogo(size = 96.dp)
                    Box(
                        Modifier
                            .align(Alignment.BottomEnd)
                            .size(28.dp)
                            .background(AppColors.Success, CircleShape),
                        contentAlignment = Alignment.Center,
                    ) {
                        Icon(Icons.Default.Check, null, tint = Color.White, modifier = Modifier.size(18.dp))
                    }
                }
                Spacer(Modifier.height(24.dp))
                Text(
                    "Terima kasih!",
                    style = MaterialTheme.typography.headlineMedium.copy(
                        fontFamily = Ubuntu, fontWeight = FontWeight.Bold, color = AppColors.Ink,
                    ),
                )
                Spacer(Modifier.height(8.dp))
                Text(
                    "Pesanan Anda berhasil dibuat.\nTim kami akan segera memproses.",
                    textAlign = TextAlign.Center,
                    fontSize = 14.sp,
                    color = AppColors.Grey,
                    lineHeight = 22.sp,
                )
                Spacer(Modifier.height(24.dp))

                // Ringkasan
                Surface(color = AppColors.Background, shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()) {
                    Column(Modifier.padding(16.dp)) {
                        Row(
                            Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Text("No. Pesanan", fontSize = 13.sp, color = AppColors.Grey)
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text(orderCode, fontWeight = FontWeight.Bold, fontSize = 15.sp,
                                    color = AppColors.Brand)
                                IconButton(
                                    onClick = {
                                        copyToClipboard(context, orderCode)
                                        scope.launch { snackbar.showSnackbar("No. pesanan disalin") }
                                    },
                                    modifier = Modifier.size(28.dp),
                                ) {
                                    Icon(Icons.Default.ContentCopy, "Salin", tint = AppColors.Brand,
                                        modifier = Modifier.size(16.dp))
                                }
                            }
                        }
                        Spacer(Modifier.height(8.dp))
                        Row(
                            Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                        ) {
                            Text("Total", fontSize = 13.sp, color = AppColors.Grey)
                            Text(formatRupiah(total), fontWeight = FontWeight.Bold, fontSize = 15.sp)
                        }
                    }
                }

                Spacer(Modifier.height(16.dp))
                PaymentInfo(orderCode = orderCode, total = total)

                Spacer(Modifier.height(24.dp))
                GradientButton(
                    label = "Lihat Pesanan Saya",
                    icon = Icons.Default.ReceiptLong,
                    onClick = onViewOrders,
                )
                Spacer(Modifier.height(12.dp))
                GradientButton(
                    label = "Kembali ke Beranda",
                    onClick = onBackHome,
                )
            }
        }
    }
}

/** Kartu cara bayar: transfer + konfirmasi WhatsApp. */
@Composable
fun PaymentInfo(orderCode: String, total: Int) {
    val context = LocalContext.current
    Surface(
        color = AppColors.WarningBg,
        shape = RoundedCornerShape(12.dp),
        border = androidx.compose.foundation.BorderStroke(1.dp, AppColors.WarningBorder),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Column(Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.Payment, null, tint = AppColors.Warning, modifier = Modifier.size(18.dp))
                Spacer(Modifier.width(8.dp))
                Text("Cara Bayar", fontWeight = FontWeight.Bold, fontSize = 15.sp)
            }
            Spacer(Modifier.height(10.dp))
            Text("1. Transfer ${formatRupiah(total)} ke:", fontSize = 13.sp)
            Spacer(Modifier.height(8.dp))

            Surface(color = Color.White, shape = RoundedCornerShape(10.dp)) {
                if (StoreConfig.hasBank) {
                    Row(Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Column(Modifier.weight(1f)) {
                            Text(StoreConfig.bankName, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                            Text(StoreConfig.accountNumber, fontSize = 16.sp, fontWeight = FontWeight.Bold,
                                letterSpacing = 1.sp)
                            Text("a.n. ${StoreConfig.accountHolder}", fontSize = 12.sp, color = AppColors.Grey)
                        }
                        Text("Salin", fontSize = 12.sp, color = AppColors.Brand,
                            modifier = Modifier.padding(8.dp))
                    }
                } else {
                    Text(
                        "Hubungi WhatsApp ${StoreConfig.waDisplay} untuk nomor rekening.",
                        modifier = Modifier.padding(12.dp),
                        fontSize = 13.sp,
                        color = AppColors.Grey,
                    )
                }
            }

            Spacer(Modifier.height(10.dp))
            Text("2. Konfirmasi via WhatsApp (sertakan kode pesanan).", fontSize = 13.sp)
            Spacer(Modifier.height(12.dp))

            GradientButton(
                label = "Konfirmasi via WhatsApp",
                icon = Icons.Default.Chat,
                onClick = { openWa(context, StoreConfig.waConfirmUrl(orderCode, total)) },
            )
        }
    }
}

private fun copyToClipboard(context: Context, text: String) {
    val manager = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    manager.setPrimaryClip(android.content.ClipData.newPlainText("text", text))
}

private fun openWa(context: Context, url: String) {
    runCatching {
        context.startActivity(android.content.Intent(
            android.content.Intent.ACTION_VIEW,
            android.net.Uri.parse(url),
        ))
    }
}
