package com.zunixe.zunixe_store.feature.auth.ui

import androidx.compose.foundation.Image
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zunixe.zunixe_store.R
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu
import com.zunixe.zunixe_store.core.ui.GradientButton
import com.zunixe.zunixe_store.core.ui.ZunixeLogo

/** Form login lengkap (email + Google + Facebook). */
@Composable
fun LoginForm(
    state: AuthUiState,
    onSubmit: (email: String, password: String) -> Unit,
    onGoogle: () -> Unit,
    onFacebook: () -> Unit,
    onForgotPassword: (email: String) -> Unit,
    onGoRegister: () -> Unit,
    snackbar: (String, Boolean) -> Unit,
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var obscure by remember { mutableStateOf(true) }
    var showForgot by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 24.dp, vertical = 16.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            ZunixeLogo(size = 48.dp)
            Spacer(Modifier.width(10.dp))
            Column {
                Text(
                    "zunixe",
                    style = MaterialTheme.typography.headlineSmall.copy(
                        fontFamily = Ubuntu,
                        color = AppColors.Brand,
                        letterSpacing = 2.sp,
                    ),
                )
                Text(
                    "Zunixe Electronics",
                    style = TextStyleSmallGrey(),
                )
            }
        }

        Spacer(Modifier.height(24.dp))
        Text(
            "Masuk",
            style = MaterialTheme.typography.headlineMedium.copy(
                fontFamily = Ubuntu, color = AppColors.Ink,
            ),
        )
        Spacer(Modifier.height(4.dp))
        Text("Masuk ke akun Zunixe Anda", style = TextStyleSmallGrey(13))
        Spacer(Modifier.height(18.dp))

        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") },
            leadingIcon = { Icon(Icons.Default.Email, null, tint = AppColors.Brand) },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Email,
                imeAction = ImeAction.Next,
            ),
        )
        Spacer(Modifier.height(12.dp))
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            leadingIcon = { Icon(Icons.Default.Lock, null, tint = AppColors.Brand) },
            trailingIcon = {
                IconButton(onClick = { obscure = !obscure }) {
                    Icon(
                        if (obscure) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                        contentDescription = if (obscure) "Tampilkan" else "Sembunyikan",
                        tint = AppColors.Grey,
                    )
                }
            },
            singleLine = true,
            visualTransformation = if (obscure) PasswordVisualTransformation() else VisualTransformation.None,
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Password,
                imeAction = ImeAction.Done,
            ),
        )

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
            TextButton(onClick = { showForgot = true }) {
                Text("Lupa password?", color = AppColors.Brand, fontSize = 12.5.sp)
            }
        }

        GradientButton(
            label = "Masuk",
            loading = state.loading,
            onClick = { onSubmit(email.trim(), password) },
        )

        Spacer(Modifier.height(24.dp))
        SocialAuthButtons(onGoogle = onGoogle, onFacebook = onFacebook)
        Spacer(Modifier.height(24.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center,
        ) {
            Text("Belum punya akun? ", style = TextStyleSmallGrey(13))
            TextButton(onClick = onGoRegister) {
                Text("Daftar", color = AppColors.Brand, fontWeight = FontWeight.Bold, fontSize = 13.sp)
            }
        }

        state.error?.let {
            Spacer(Modifier.height(8.dp))
            Text(it, color = AppColors.Error, fontSize = 12.sp, textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth())
        }
    }

    if (showForgot) {
        ForgotPasswordDialog(
            initialEmail = email,
            onDismiss = { showForgot = false },
            onSend = { target ->
                showForgot = false
                onForgotPassword(target)
            },
            snackbar = snackbar,
        )
    }
}

@Composable
internal fun SocialAuthButtons(onGoogle: () -> Unit, onFacebook: () -> Unit) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(Modifier.weight(1f).height(1.dp).background(AppColors.BorderAlt))
        Text(
            "atau masuk dengan",
            modifier = Modifier.padding(horizontal = 12.dp),
            style = TextStyleSmallGrey(12),
        )
        Box(Modifier.weight(1f).height(1.dp).background(AppColors.BorderAlt))
    }
    Spacer(Modifier.height(16.dp))

    OutlinedButton(
        onClick = onGoogle,
        modifier = Modifier.fillMaxWidth().height(50.dp),
        shape = RoundedCornerShape(12.dp),
    ) {
        Image(
            painter = painterResource(R.drawable.google_icon),
            contentDescription = null,
            modifier = Modifier.size(22.dp),
        )
        Spacer(Modifier.width(8.dp))
        Text("Lanjutkan dengan Google", fontSize = 15.sp, fontWeight = FontWeight.SemiBold)
    }
    Spacer(Modifier.height(12.dp))
    OutlinedButton(
        onClick = onFacebook,
        modifier = Modifier.fillMaxWidth().height(50.dp),
        shape = RoundedCornerShape(12.dp),
    ) {
        Image(
            painter = painterResource(R.drawable.facebook_icon),
            contentDescription = null,
            modifier = Modifier.size(22.dp),
        )
        Spacer(Modifier.width(8.dp))
        Text(
            "Lanjutkan dengan Facebook",
            fontSize = 15.sp,
            fontWeight = FontWeight.SemiBold,
            color = Color.White,
        )
    }
}

@Composable
private fun TextStyleSmallGrey(size: Int = 9) = MaterialTheme.typography.labelSmall.copy(
    fontFamily = Ubuntu,
    fontSize = size.sp,
    color = AppColors.Grey,
    letterSpacing = if (size <= 9) 2.5.sp else 0.sp,
)
