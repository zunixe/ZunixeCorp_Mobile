package com.zunixe.zunixe_store.feature.auth.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Chat
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.ReceiptLong
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
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

/** Tab Akun: form login bila belum masuk, profil bila sudah. */
@Composable
fun AccountScreen(
    onGoOrders: () -> Unit,
    onGoCart: () -> Unit,
    onGoChat: () -> Unit,
    onGoAbout: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()

    if (!state.isLoggedIn) {
        Scaffold(containerColor = Color.White) { padding ->
            Column(Modifier.fillMaxSize().padding(padding)) {
                LoginForm(
                    state = state,
                    onSubmit = { e, p -> viewModel.login(e, p) { } },
                    onGoogle = { viewModel.signInWithGoogle { } },
                    onFacebook = { viewModel.signInWithFacebook { } },
                    onForgotPassword = { email -> viewModel.resetPassword(email) { _, _ -> } },
                    onGoRegister = { },
                    snackbar = { _, _ -> },
                )
            }
        }
        return
    }

    var confirmLogout by remember { mutableStateOf(false) }

    Scaffold(containerColor = AppColors.Background) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            AppHeader(
                title = "Akun Saya",
                showSearch = false,
                showCart = false,
                showProfile = false,
            )
            Column(
                Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(20.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Surface(
                    shape = CircleShape,
                    color = AppColors.Brand,
                    modifier = Modifier.size(80.dp),
                ) {
                    Row(Modifier.fillMaxSize(), horizontalArrangement = Arrangement.Center,
                        verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            state.displayName.take(1).uppercase(),
                            fontSize = 28.sp, color = Color.White, fontWeight = FontWeight.Bold,
                        )
                    }
                }
                Spacer(Modifier.height(16.dp))
                Text(
                    state.displayName,
                    style = MaterialTheme.typography.headlineSmall.copy(fontFamily = Ubuntu, color = AppColors.Ink),
                )
                Text(state.user?.email ?: "", fontSize = 14.sp, color = AppColors.Grey)
                Spacer(Modifier.height(24.dp))

                MenuTile("Pesanan Saya", Icons.Default.ReceiptLong, onGoOrders)
                Spacer(Modifier.height(8.dp))
                MenuTile("Keranjang", Icons.Default.ShoppingCart, onGoCart)
                Spacer(Modifier.height(8.dp))
                MenuTile("Chat Support", Icons.Default.Chat, onGoChat)
                Spacer(Modifier.height(8.dp))
                MenuTile("Tentang Kami", Icons.Default.Info, onGoAbout)

                Spacer(Modifier.height(24.dp))
                OutlinedButton(
                    onClick = { confirmLogout = true },
                    modifier = Modifier.fillMaxWidth().height(48.dp),
                    shape = RoundedCornerShape(12.dp),
                ) {
                    Text("Keluar", fontSize = 16.sp, color = AppColors.Brand)
                }
            }
        }
    }

    if (confirmLogout) {
        AlertDialog(
            onDismissRequest = { confirmLogout = false },
            title = { Text("Keluar akun?") },
            text = { Text("Anda harus masuk lagi untuk berbelanja.") },
            confirmButton = {
                TextButton(onClick = {
                    confirmLogout = false
                    viewModel.logout()
                }) { Text("Keluar", color = AppColors.Brand) }
            },
            dismissButton = {
                TextButton(onClick = { confirmLogout = false }) { Text("Batal", color = AppColors.Grey) }
            },
        )
    }
}

@Composable
private fun MenuTile(
    title: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    onClick: () -> Unit,
) {
    Surface(shape = RoundedCornerShape(12.dp), color = Color.White, onClick = onClick,
        modifier = Modifier.fillMaxWidth()) {
        ListItem(
            leadingContent = { Icon(icon, null, tint = AppColors.Brand) },
            headlineContent = { Text(title, fontSize = 15.sp) },
            trailingContent = {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, null, tint = AppColors.Muted)
            },
        )
    }
}

/** Placeholder tombol login bila dibutuhkan di layar lain. */
@Composable
internal fun LoginRequiredPlaceholder(onLogin: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("Login untuk melanjutkan", color = AppColors.Grey)
        Spacer(Modifier.height(12.dp))
        Button(onClick = onLogin) { Text("Masuk") }
    }
}
