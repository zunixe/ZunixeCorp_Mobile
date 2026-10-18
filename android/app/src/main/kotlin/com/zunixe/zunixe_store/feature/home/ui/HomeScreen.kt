package com.zunixe.zunixe_store.feature.home.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu
import com.zunixe.zunixe_store.core.ui.AppHeader
import com.zunixe.zunixe_store.core.ui.ZunixeLogo
import com.zunixe.zunixe_store.feature.catalog.domain.Product
import com.zunixe.zunixe_store.feature.catalog.ui.ProductCard

/** Beranda: promo, hero, produk unggulan, section produk, FAQ, footer. */
@Composable
fun HomeScreen(
    cartCount: Int,
    onSearch: () -> Unit,
    onCart: () -> Unit,
    onProfile: () -> Unit,
    onProducts: () -> Unit,
    onProductClick: (Product) -> Unit,
    onAbout: () -> Unit,
    onLegal: (String) -> Unit,
    addButton: @Composable (Product) -> Unit,
    viewModel: HomeViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()

    Scaffold(containerColor = AppColors.Background) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            PromoBanner()

            AppHeader(
                title = "zunixe",
                showSearch = true,
                onSearch = onSearch,
                showCart = true,
                cartCount = cartCount,
                onCart = onCart,
                showProfile = true,
                onProfile = onProfile,
            )

            Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
                HeroSection()
                FeaturedProduct(onProducts)
                SuperPromo(state.countdown)

                when {
                    state.loading -> Box(
                        Modifier.fillMaxWidth().padding(32.dp),
                        contentAlignment = Alignment.Center,
                    ) { CircularProgressIndicator(color = AppColors.Brand) }

                    state.error != null -> Surface(
                        color = Color.White,
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.fillMaxWidth().padding(16.dp),
                    ) {
                        Column(
                            Modifier.padding(20.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                        ) {
                            Text(state.error ?: "", fontSize = 14.sp, color = AppColors.Grey)
                            Spacer(Modifier.height(12.dp))
                            OutlinedButton(onClick = { viewModel.loadProducts() }) { Text("Coba Lagi") }
                        }
                    }

                    state.products.isEmpty() -> Surface(
                        color = Color.White,
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.fillMaxWidth().padding(16.dp),
                    ) {
                        Text(
                            "Belum ada produk tersedia.",
                            modifier = Modifier.padding(20.dp).fillMaxWidth(),
                            textAlign = TextAlign.Center,
                            fontSize = 14.sp,
                            color = AppColors.Grey,
                        )
                    }

                    else -> {
                        ProductSection(
                            title = "Rekomendasi",
                            products = state.recommendations,
                            onProductClick = onProductClick,
                            onSeeAll = onProducts,
                            addButton = addButton,
                        )
                        ProductSection(
                            title = "Produk Terbaru",
                            products = state.products,
                            onProductClick = onProductClick,
                            onSeeAll = onProducts,
                            addButton = addButton,
                        )
                    }
                }

                HelpSection()
                HomeFooter(onLegal = onLegal)
            }
        }
    }
}

@Composable
private fun PromoBanner() {
    Box(
        Modifier.fillMaxWidth().background(AppColors.Brand).padding(vertical = 8.dp),
        contentAlignment = Alignment.Center,
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Default.LocalFireDepartment, null, tint = Color.White, modifier = Modifier.size(16.dp))
            Spacer(Modifier.width(6.dp))
            Text("Get our latest products!", color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Medium)
        }
    }
}

@Composable
private fun HeroSection() {
    Surface(color = Color.White, modifier = Modifier.fillMaxWidth()) {
        Column(
            Modifier.padding(start = 20.dp, end = 20.dp, top = 24.dp, bottom = 16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                ZunixeLogo(size = 56.dp)
                Spacer(Modifier.width(14.dp))
                Column {
                    Text(
                        "zunixe",
                        style = MaterialTheme.typography.headlineLarge.copy(
                            fontFamily = Ubuntu,
                            fontSize = 30.sp,
                            color = AppColors.Brand,
                            letterSpacing = 2.sp,
                        ),
                    )
                    Text("Zunixe Electronics", fontSize = 11.sp, color = AppColors.Grey, letterSpacing = 3.sp)
                }
            }
            Spacer(Modifier.height(8.dp))
            Text(
                "Mitra Terpercaya Inovasi Elektronika Anda",
                textAlign = TextAlign.Center,
                fontSize = 13.sp,
                color = AppColors.Grey,
            )
        }
    }
}

@Composable
private fun FeaturedProduct(onProducts: () -> Unit) {
    Surface(
        color = Color.White,
        shape = RoundedCornerShape(12.dp),
        shadowElevation = 2.dp,
        modifier = Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, bottom = 16.dp),
    ) {
        Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(
                Modifier.size(80.dp).background(AppColors.Surface, RoundedCornerShape(8.dp)),
                contentAlignment = Alignment.Center,
            ) { Icon(Icons.Default.Memory, null, tint = AppColors.Brand, modifier = Modifier.size(40.dp)) }
            Spacer(Modifier.width(16.dp))
            Column(Modifier.weight(1f)) {
                Text("ESP32 Development Board", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                Spacer(Modifier.height(4.dp))
                Text("Mulai proyek IoT Anda sekarang", fontSize = 13.sp, color = AppColors.Grey)
                Spacer(Modifier.height(8.dp))
                OutlinedButton(onClick = onProducts, shape = RoundedCornerShape(12.dp)) {
                    Text("Lihat Produk", fontSize = 12.sp, color = AppColors.Brand)
                }
            }
        }
    }
}

@Composable
private fun SuperPromo(countdown: PromoCountdown) {
    Box(
        Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .background(
                androidx.compose.ui.graphics.Brush.linearGradient(
                    listOf(AppColors.Brand, AppColors.BrandDark),
                ),
                RoundedCornerShape(12.dp),
            )
            .padding(16.dp),
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.fillMaxWidth()) {
            Text("Super Promo", color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            Text("Promo terbatas hingga akhir bulan", color = Color.White.copy(alpha = 0.9f), fontSize = 13.sp)
            Spacer(Modifier.height(12.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                CountdownBox(countdown.days.toString(), "Hari")
                Colon()
                CountdownBox(countdown.hours.toString().padStart(2, '0'), "Jam")
                Colon()
                CountdownBox(countdown.minutes.toString().padStart(2, '0'), "Menit")
                Colon()
                CountdownBox(countdown.seconds.toString().padStart(2, '0'), "Detik")
            }
        }
    }
}

@Composable
private fun Colon() {
    Text(":", color = Color.White, fontSize = 24.sp, fontWeight = FontWeight.Bold,
        modifier = Modifier.padding(horizontal = 8.dp))
}

@Composable
private fun CountdownBox(value: String, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            Modifier
                .background(Color.White.copy(alpha = 0.2f), RoundedCornerShape(6.dp))
                .padding(horizontal = 10.dp, vertical = 6.dp),
        ) {
            Text(value, color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Bold)
        }
        Text(label, color = Color.White.copy(alpha = 0.8f), fontSize = 10.sp)
    }
}

@Composable
private fun ProductSection(
    title: String,
    products: List<Product>,
    onProductClick: (Product) -> Unit,
    onSeeAll: () -> Unit,
    addButton: @Composable (Product) -> Unit,
) {
    if (products.isEmpty()) return
    Column(Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, top = 20.dp)) {
        Row(
            Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(title, fontSize = 20.sp, color = AppColors.Ink)
            TextButton(onClick = onSeeAll) {
                Text("Lihat Semua", fontSize = 13.sp, color = AppColors.Brand)
            }
        }
        Spacer(Modifier.height(12.dp))
        // Grid 2 kolom tanpa scroll (di dalam scroll induk)
        products.chunked(2).forEach { row ->
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                row.forEach { product ->
                    Box(Modifier.weight(1f)) {
                        ProductCard(
                            product = product,
                            onClick = { onProductClick(product) },
                            bottomSlot = { addButton(product) },
                        )
                    }
                }
                if (row.size == 1) Spacer(Modifier.weight(1f))
            }
            Spacer(Modifier.height(12.dp))
        }
    }
}

@Composable
private fun HelpSection() {
    val items = listOf(
        "Mengapa membeli dari Kami" to
            "Zunixe adalah mitra terpercaya sejak 2017. Kami menyediakan komponen mikrokontroler " +
            "dan elektronika berkualitas dengan harga kompetitif. Semua produk kami diuji sebelum " +
            "dikirim untuk memastikan kualitas terbaik.",
        "Cara Berbelanja" to
            "1. Telusuri produk di katalog kami.\n2. Klik \"Beli\" pada produk yang diinginkan.\n" +
            "3. Atur jumlah di keranjang, lalu lanjutkan ke checkout.\n4. Isi data pengiriman dan buat pesanan.\n" +
            "5. Lakukan pembayaran via transfer, lalu konfirmasi via WhatsApp.",
        "Melacak Order Kamu" to
            "Setelah pesanan dikirim, Anda akan menerima nomor resi melalui WhatsApp atau email. " +
            "Estimasi pengiriman 2-7 hari kerja tergantung lokasi.",
        "Hubungi Dukungan" to
            "Tim support kami siap membantu Anda:\n\nWhatsApp: ${com.zunixe.zunixe_store.core.config.StoreConfig.waDisplay}\n" +
            "Email: support@zunixe.com\n\nJam operasional: Senin - Sabtu, 08:00 - 17:00 WIB",
        "Tips Keamanan Akun" to
            "1. Gunakan password yang kuat dan unik.\n2. Jangan bagikan kode OTP ke siapa pun.\n" +
            "3. Selalu periksa URL sebelum login.\n4. Aktifkan verifikasi dua langkah jika tersedia.",
    )

    Column(Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, top = 20.dp)) {
        Text("Tanya Kami", fontSize = 20.sp, color = AppColors.Ink)
        Spacer(Modifier.height(12.dp))
        items.forEach { (title, content) ->
            Surface(
                color = Color.White,
                shape = RoundedCornerShape(8.dp),
                modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp),
            ) {
                var expanded by androidx.compose.runtime.remember {
                    androidx.compose.runtime.mutableStateOf(false)
                }
                Column {
                    Row(
                        Modifier.fillMaxWidth().clickable { expanded = !expanded }.padding(14.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                    ) {
                        Text(title, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                        Text(if (expanded) "−" else "+", fontSize = 16.sp, color = AppColors.Brand)
                    }
                    if (expanded) {
                        HorizontalDivider(color = AppColors.Border)
                        Text(
                            content,
                            modifier = Modifier.padding(14.dp),
                            fontSize = 13.sp,
                            color = AppColors.Grey,
                            lineHeight = 20.sp,
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun HomeFooter(onLegal: (String) -> Unit) {
    Column(
        Modifier
            .fillMaxWidth()
            .padding(top = 16.dp)
            .background(AppColors.Footer)
            .padding(start = 20.dp, end = 20.dp, top = 24.dp, bottom = 32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        ZunixeLogo(size = 44.dp)
        Spacer(Modifier.height(8.dp))
        Text("zunixe", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.2.sp)
        Text("Mitra Terpercaya Inovasi Elektronika Anda", color = AppColors.Grey, fontSize = 12.sp)
        Spacer(Modifier.height(16.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            FooterLink("Persyaratan Layanan") { onLegal("tos") }
            FooterLink("Kebijakan Privasi") { onLegal("privacy") }
        }
        Spacer(Modifier.height(8.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            FooterLink("Kebijakan Pengiriman") { onLegal("shipping") }
            FooterLink("Kebijakan Pengembalian") { onLegal("returns") }
            FooterLink("Kebijakan KI") { onLegal("ip") }
        }
        Spacer(Modifier.height(16.dp))
        Text(
            "Powered By : CV Zunixe Berkah Jaya",
            color = AppColors.Grey,
            fontSize = 11.sp,
        )
    }
}

@Composable
private fun FooterLink(text: String, onClick: () -> Unit) {
    Text(
        text,
        color = AppColors.Muted,
        fontSize = 12.sp,
        textDecoration = androidx.compose.ui.text.style.TextDecoration.Underline,
        modifier = Modifier.clickable(onClick = onClick),
    )
}
