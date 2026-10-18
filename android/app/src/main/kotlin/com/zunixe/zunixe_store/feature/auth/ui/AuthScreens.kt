package com.zunixe.zunixe_store.feature.auth.ui

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
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.runtime.collectAsState
import androidx.hilt.navigation.compose.hiltViewModel
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu
import com.zunixe.zunixe_store.core.ui.AppHeader
import com.zunixe.zunixe_store.core.ui.GradientButton
import com.zunixe.zunixe_store.core.ui.ZunixeLogo
import com.zunixe.zunixe_store.feature.auth.domain.RegisterResult
import kotlinx.coroutines.launch

/** Layar login mandiri. */
@Composable
fun LoginScreen(
    onBack: () -> Unit,
    onLoggedIn: () -> Unit,
    onGoRegister: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()

    fun show(msg: String, success: Boolean) {
        scope.launch {
            snackbar.showSnackbar(msg)
        }
    }

    LaunchedEffect(state.isLoggedIn) {
        if (state.isLoggedIn) onLoggedIn()
    }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbar) },
        containerColor = androidx.compose.ui.graphics.Color.White,
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            AppHeader(
                title = "Masuk",
                showBack = true,
                onBack = onBack,
                showSearch = false,
                showCart = false,
                showProfile = false,
            )
            LoginForm(
                state = state,
                onSubmit = { email, password ->
                    viewModel.login(email, password) { }
                },
                onGoogle = { viewModel.signInWithGoogle { ok -> if (!ok) show(state.error ?: "Gagal", false) } },
                onFacebook = { viewModel.signInWithFacebook { ok -> if (!ok) show(state.error ?: "Gagal", false) } },
                onForgotPassword = { email ->
                    viewModel.resetPassword(email) { ok, err ->
                        show(if (ok) "Link reset terkirim ke $email. Cek inbox/spam." else (err ?: "Gagal"), ok)
                    }
                },
                onGoRegister = onGoRegister,
                snackbar = ::show,
            )
        }
    }
}

/** Layar daftar akun. */
@Composable
fun RegisterScreen(
    onBack: () -> Unit,
    onDoneLoggedIn: () -> Unit,
    onNeedVerification: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()

    var name by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var phone by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var confirm by remember { mutableStateOf("") }
    var error by remember { mutableStateOf<String?>(null) }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbar) },
        containerColor = androidx.compose.ui.graphics.Color.White,
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            AppHeader(
                title = "zunixe",
                showBack = true,
                onBack = onBack,
                showSearch = false,
                showCart = false,
                showProfile = false,
            )
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(24.dp),
            ) {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
                    ZunixeLogo(size = 72.dp)
                }
                Spacer(Modifier.height(20.dp))
                Text(
                    "Daftar",
                    style = MaterialTheme.typography.headlineLarge.copy(fontFamily = Ubuntu, color = AppColors.Ink),
                )
                Text("Buat akun baru di Zunixe", fontSize = 14.sp, color = AppColors.Grey)
                Spacer(Modifier.height(32.dp))

                OutlinedTextField(name, { name = it }, label = { Text("Nama Lengkap") },
                    singleLine = true, modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp))
                Spacer(Modifier.height(16.dp))
                OutlinedTextField(email, { email = it }, label = { Text("Email") },
                    singleLine = true, modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email, imeAction = ImeAction.Next))
                Spacer(Modifier.height(16.dp))
                OutlinedTextField(phone, { phone = it }, label = { Text("Nomor WhatsApp (opsional)") },
                    singleLine = true, modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone, imeAction = ImeAction.Next))
                Spacer(Modifier.height(16.dp))
                OutlinedTextField(password, { password = it }, label = { Text("Password") },
                    singleLine = true, modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password, imeAction = ImeAction.Next))
                Spacer(Modifier.height(16.dp))
                OutlinedTextField(confirm, { confirm = it }, label = { Text("Konfirmasi Password") },
                    singleLine = true, modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password, imeAction = ImeAction.Done))

                error?.let {
                    Spacer(Modifier.height(8.dp))
                    Text(it, color = AppColors.Error, fontSize = 12.sp)
                }

                Spacer(Modifier.height(24.dp))
                GradientButton(
                    label = "Daftar",
                    loading = state.loading,
                    onClick = {
                        error = validateRegister(name, email, password, confirm)
                        if (error == null) {
                            viewModel.register(email.trim(), password, name.trim(),
                                phone.trim().ifEmpty { null }) { result ->
                                scope.launch {
                                    when (result) {
                                        RegisterResult.LOGGED_IN -> {
                                            snackbar.showSnackbar("Pendaftaran berhasil! Selamat datang.")
                                            onDoneLoggedIn()
                                        }
                                        RegisterResult.NEED_VERIFICATION -> {
                                            snackbar.showSnackbar("Pendaftaran berhasil! Cek email untuk verifikasi.")
                                            onNeedVerification()
                                        }
                                        RegisterResult.FAILED -> {
                                            error = state.error ?: "Pendaftaran gagal"
                                        }
                                    }
                                }
                            }
                        }
                    },
                )

                Spacer(Modifier.height(16.dp))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
                    Text("Sudah punya akun? ", color = AppColors.Grey)
                    TextButton(onClick = onBack) {
                        Text("Masuk", color = AppColors.Brand, fontWeight = FontWeight.SemiBold)
                    }
                }
            }
        }
    }
}

/** Validasi form register — fungsi murni agar dapat diuji. */
internal fun validateRegister(
    name: String,
    email: String,
    password: String,
    confirm: String,
): String? {
    if (name.trim().isEmpty()) return "Nama harus diisi"
    val mail = email.trim()
    if (mail.isEmpty()) return "Email harus diisi"
    if (!mail.contains('@') || !mail.contains('.') || mail.contains(' ')) return "Email tidak valid"
    if (password.isEmpty()) return "Password harus diisi"
    if (password.length < 6) return "Minimal 6 karakter"
    if (confirm != password) return "Password tidak cocok"
    return null
}

/** Layar password baru (dari link reset). */
@Composable
fun ResetPasswordScreen(
    onDone: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel(),
) {
    var password by remember { mutableStateOf("") }
    var confirm by remember { mutableStateOf("") }
    var error by remember { mutableStateOf<String?>(null) }
    var saving by remember { mutableStateOf(false) }
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()

    Scaffold(snackbarHost = { SnackbarHost(snackbar) }, containerColor = androidx.compose.ui.graphics.Color.White) { padding ->
        Column(
            Modifier.fillMaxSize().padding(padding).verticalScroll(rememberScrollState()).padding(24.dp),
        ) {
            Spacer(Modifier.height(32.dp))
            Text("Password Baru",
                style = MaterialTheme.typography.headlineMedium.copy(fontFamily = Ubuntu, color = AppColors.Ink))
            Text("Masukkan password baru untuk akun Anda", fontSize = 13.sp, color = AppColors.Grey)
            Spacer(Modifier.height(24.dp))

            OutlinedTextField(password, { password = it }, label = { Text("Password baru") },
                singleLine = true, modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password, imeAction = ImeAction.Next))
            Spacer(Modifier.height(12.dp))
            OutlinedTextField(confirm, { confirm = it }, label = { Text("Konfirmasi password baru") },
                singleLine = true, modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password, imeAction = ImeAction.Done))

            error?.let {
                Spacer(Modifier.height(8.dp))
                Text(it, color = AppColors.Error, fontSize = 12.sp)
            }

            Spacer(Modifier.height(24.dp))
            GradientButton(
                label = "Simpan Password",
                loading = saving,
                onClick = {
                    error = when {
                        password.isEmpty() -> "Password harus diisi"
                        password.length < 6 -> "Minimal 6 karakter"
                        confirm != password -> "Password tidak cocok"
                        else -> null
                    }
                    if (error == null) {
                        saving = true
                        viewModel.updatePassword(password) { ok, err ->
                            saving = false
                            scope.launch {
                                if (ok) {
                                    snackbar.showSnackbar("Password berhasil diubah. Silakan masuk.")
                                    viewModel.logout()
                                    onDone()
                                } else {
                                    snackbar.showSnackbar(err ?: "Gagal menyimpan password.")
                                }
                            }
                        }
                    }
                },
            )
        }
    }
}
