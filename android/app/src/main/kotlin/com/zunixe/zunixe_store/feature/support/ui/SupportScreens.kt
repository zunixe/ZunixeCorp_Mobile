package com.zunixe.zunixe_store.feature.support.ui

import android.content.Context
import android.content.Intent
import android.net.Uri
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
import androidx.compose.material.icons.filled.HeadsetMic
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.Send
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zunixe.zunixe_store.core.config.StoreConfig
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu
import com.zunixe.zunixe_store.core.ui.AppHeader
import com.zunixe.zunixe_store.core.ui.ZunixeLogo
import kotlinx.coroutines.launch

/** Chat support via WhatsApp (tanpa backend chat). */
@Composable
fun ChatScreen() {
    val context = LocalContext.current
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    var message by remember { mutableStateOf("") }

    Scaffold(
        containerColor = AppColors.Background,
        snackbarHost = { SnackbarHost(snackbar) },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            AppHeader(
                title = "Zunixe Support",
                subtitle = "Chat via WhatsApp — balasan di WhatsApp",
                leading = {
                    Box(
                        Modifier.size(28.dp)
                            .then(Modifier)
                            .padding(2.dp),
                        contentAlignment = Alignment.Center,
                    ) {
                        Icon(Icons.Default.HeadsetMic, null, tint = AppColors.Brand, modifier = Modifier.size(18.dp))
                    }
                },
                showSearch = false,
                showCart = false,
                showProfile = false,
                trailing = {
                    IconButton(onClick = { openWa(context, StoreConfig.waChatUrl) }) {
                        Icon(Icons.Default.Chat, "Chat WhatsApp", tint = AppColors.Brand)
                    }
                },
            )

            Column(
                Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Surface(color = Color.White, shape = RoundedCornerShape(16.dp)) {
                    Column(
                        Modifier.padding(20.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                    ) {
                        Box(
                            Modifier.size(64.dp)
                                .background(AppColors.Brand, CircleShape),
                            contentAlignment = Alignment.Center,
                        ) {
                            Icon(Icons.Default.HeadsetMic, null, tint = Color.White, modifier = Modifier.size(30.dp))
                        }
                        Spacer(Modifier.height(14.dp))
                        Text(
                            "Butuh bantuan?",
                            style = MaterialTheme.typography.titleLarge.copy(
                                fontFamily = Ubuntu, color = AppColors.Ink,
                            ),
                        )
                        Spacer(Modifier.height(6.dp))
                        Text(
                            "Tim support Zunixe siap membantu Anda. Ketik pesan di bawah, " +
                                "lalu tekan kirim — pesan akan dibuka langsung di WhatsApp.",
                            textAlign = TextAlign.Center,
                            fontSize = 13.sp,
                            color = AppColors.Grey,
                            lineHeight = 20.sp,
                        )
                        Spacer(Modifier.height(16.dp))
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.Schedule, null, tint = AppColors.Brand, modifier = Modifier.size(16.dp))
                            Spacer(Modifier.width(8.dp))
                            Text(StoreConfig.supportHours, fontSize = 13.sp, color = AppColors.Grey)
                        }
                        Spacer(Modifier.height(8.dp))
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.Chat, null, tint = AppColors.Brand, modifier = Modifier.size(16.dp))
                            Spacer(Modifier.width(8.dp))
                            Text("WhatsApp ${StoreConfig.waDisplay}", fontSize = 13.sp, color = AppColors.Grey)
                        }
                    }
                }

                Spacer(Modifier.height(12.dp))

                Surface(
                    color = AppColors.WarningBg,
                    shape = RoundedCornerShape(12.dp),
                    border = androidx.compose.foundation.BorderStroke(1.dp, AppColors.WarningBorder),
                ) {
                    Row(Modifier.padding(16.dp)) {
                        Icon(Icons.Default.Info, null, tint = AppColors.Warning, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.width(10.dp))
                        Text(
                            "Pesan hanya terkirim lewat WhatsApp. Aplikasi tidak menyimpan riwayat chat.",
                            fontSize = 12.sp,
                            color = AppColors.Grey,
                            lineHeight = 18.sp,
                        )
                    }
                }

                Spacer(Modifier.height(16.dp))

                OutlinedTextField(
                    value = message,
                    onValueChange = { message = it },
                    placeholder = { Text("Ketik pesan…") },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(24.dp),
                    maxLines = 4,
                    trailingIcon = {
                        IconButton(onClick = {
                            val text = message.trim()
                            val url = if (text.isEmpty()) StoreConfig.waChatUrl
                            else StoreConfig.waTextUrl(text)
                            openWa(context, url)
                            message = ""
                        }) {
                            Icon(Icons.Default.Send, "Kirim", tint = Color.White,
                                modifier = Modifier.size(18.dp))
                        }
                    },
                )
            }
        }
    }
}

/** Tentang Kami. */
@Composable
fun AboutScreen(onBack: () -> Unit) {
    val context = LocalContext.current
    Scaffold(containerColor = AppColors.Background) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            AppHeader(
                title = "Tentang Kami",
                showBack = true,
                onBack = onBack,
                showSearch = false,
                showCart = false,
                showProfile = false,
            )
            Column(
                Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
            ) {
                Surface(color = Color.White, shape = RoundedCornerShape(12.dp)) {
                    Column(Modifier.padding(20.dp)) {
                        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
                            ZunixeLogo(size = 88.dp)
                        }
                        Spacer(Modifier.height(12.dp))
                        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
                            Text(
                                "zunixe",
                                style = MaterialTheme.typography.headlineLarge.copy(
                                    fontFamily = Ubuntu, color = AppColors.Brand, letterSpacing = 2.sp,
                                ),
                            )
                        }
                        Spacer(Modifier.height(16.dp))
                        Text(
                            "Selamat Datang di Zunixe Store",
                            style = MaterialTheme.typography.titleLarge.copy(
                                fontFamily = Ubuntu, color = AppColors.Ink,
                            ),
                        )
                        Spacer(Modifier.height(8.dp))
                        Text(
                            "Mitra Terpercaya Inovasi Elektronika Anda Sejak 2017",
                            fontSize = 14.sp, color = AppColors.Grey, fontWeight = FontWeight.SemiBold,
                        )
                        Spacer(Modifier.height(16.dp))
                        Text(
                            "Di bawah naungan CV Zunixe Berkah Jaya, kami hadir sebagai solusi utama bagi para " +
                                "pengembang, pelajar, dan pelaku industri yang membutuhkan komponen mikrokontroler " +
                                "dan elektronika berkualitas.",
                            fontSize = 14.sp, color = AppColors.Grey, lineHeight = 22.sp,
                        )
                        Spacer(Modifier.height(20.dp))
                        ServiceItem("Produk berkualitas dengan harga terbaik")
                        ServiceItem("Pengiriman cepat & aman ke seluruh Indonesia")
                        ServiceItem("Dukungan teknis responsif")
                        Spacer(Modifier.height(20.dp))
                        Text(
                            "Hubungi Kami:",
                            style = MaterialTheme.typography.titleMedium.copy(
                                fontFamily = Ubuntu, color = AppColors.Ink,
                            ),
                        )
                        Spacer(Modifier.height(8.dp))
                        TextButton(onClick = { openMap(context) }) {
                            Text(StoreConfig.address, fontSize = 14.sp, color = AppColors.Brand)
                        }
                        TextButton(onClick = { openWa(context, StoreConfig.waChatUrl) }) {
                            Text("WhatsApp: ${StoreConfig.waDisplay}", fontSize = 14.sp, color = AppColors.Brand)
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun ServiceItem(text: String) {
    Row(Modifier.padding(bottom = 6.dp), verticalAlignment = Alignment.Top) {
        Icon(Icons.Default.Info, null, tint = AppColors.Brand, modifier = Modifier.size(18.dp))
        Spacer(Modifier.width(8.dp))
        Text(text, fontSize = 14.sp, color = AppColors.Grey)
    }
}

/** Halaman legal statis. */
@Composable
fun LegalScreen(slug: String, onBack: () -> Unit) {
    val page = legalPages[slug] ?: legalPages["tos"]!!
    Scaffold(containerColor = Color.White) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            AppHeader(
                title = page.first,
                showBack = true,
                onBack = onBack,
                showSearch = false,
                showCart = false,
                showProfile = false,
            )
            Column(
                Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(20.dp),
            ) {
                Text(page.second, fontSize = 14.sp, color = AppColors.Ink, lineHeight = 24.sp)
            }
        }
    }
}

/** Isi halaman legal. */
val legalPages: Map<String, Pair<String, String>> = mapOf(
    "tos" to (
        "Persyaratan Layanan" to
            "Dengan menggunakan aplikasi Zunixe Store, Anda menyetujui:\n\n" +
            "1. Harga dan stok dapat berubah sewaktu-waktu.\n" +
            "2. Pesanan dibuat setelah data pengiriman lengkap.\n" +
            "3. Pembayaran via transfer bank, dikonfirmasi via WhatsApp.\n" +
            "4. Pesanan yang belum dibayar dapat dibatalkan.\n" +
            "5. Penyalahgunaan akun berakibat penangguhan."
        ),
    "privacy" to (
        "Kebijakan Privasi" to
            "Kami menyimpan data yang Anda berikan (nama, email, no. HP, alamat) " +
            "hanya untuk memproses pesanan dan layanan pelanggan.\n\n" +
            "Data tidak dibagikan ke pihak ketiga kecuali jasa pengiriman untuk " +
            "keperluan pengantaran. Anda dapat meminta penghapusan data via " +
            "WhatsApp ${StoreConfig.waDisplay}."
        ),
    "shipping" to (
        "Kebijakan Pengiriman" to
            "Pengiriman ke seluruh Indonesia via ekspedisi rekanan.\n\n" +
            "Estimasi 2-7 hari kerja tergantung lokasi. Nomor resi dikirim via " +
            "WhatsApp/email setelah barang dikirim. Ongkos kirim saat ini GRATIS."
        ),
    "returns" to (
        "Kebijakan Pengembalian" to
            "Barang rusak/salah kirim dapat ditukar maksimal 3 hari setelah " +
            "diterima (wajib video unboxing).\n\n" +
            "Hubungi WhatsApp ${StoreConfig.waDisplay} dengan nomor pesanan dan bukti foto/video. " +
            "Dana dikembalikan via transfer setelah barang retur kami terima."
        ),
    "ip" to (
        "Kebijakan KI" to
            "Seluruh konten aplikasi (logo, teks, gambar) adalah milik " +
            "CV Zunixe Berkah Jaya. Dilarang menyalin atau menggunakan untuk " +
            "tujuan komersial tanpa izin tertulis."
        ),
)

internal fun openWa(context: Context, url: String) {
    runCatching {
        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
    }
}

private fun openMap(context: Context) {
    val query = Uri.encode(StoreConfig.address)
    runCatching {
        context.startActivity(
            Intent(Intent.ACTION_VIEW, Uri.parse("https://www.google.com/maps/search/?api=1&query=$query")),
        )
    }
}
