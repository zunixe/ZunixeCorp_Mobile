package com.zunixe.zunixe_store.feature.auth.ui

import androidx.compose.foundation.background
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.zunixe.zunixe_store.core.theme.AppColors

/** Dialog "Lupa password": kirim link reset ke email. */
@Composable
internal fun ForgotPasswordDialog(
    initialEmail: String,
    onDismiss: () -> Unit,
    onSend: (String) -> Unit,
    snackbar: (String, Boolean) -> Unit,
) {
    var email by remember { mutableStateOf(initialEmail) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Lupa password") },
        text = {
            OutlinedTextField(
                value = email,
                onValueChange = { email = it },
                label = { Text("Email akun") },
                singleLine = true,
                modifier = Modifier,
            )
        },
        confirmButton = {
            TextButton(onClick = {
                val target = email.trim()
                if (target.isNotEmpty()) {
                    onSend(target)
                    snackbar("Link reset terkirim ke $target. Cek inbox/spam.", true)
                }
            }) { Text("Kirim Link", color = AppColors.Brand) }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Batal", color = AppColors.Grey) }
        },
    )
}
