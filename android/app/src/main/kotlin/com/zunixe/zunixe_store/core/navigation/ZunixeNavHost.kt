package com.zunixe.zunixe_store.core.navigation

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

/**
 * NavHost aplikasi. Fase 1 masih placeholder — rute lengkap dipasang
 * bertahap (auth → katalog → keranjang → checkout → home).
 */
@Composable
fun ZunixeNavHost() {
    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text("Zunixe Store")
        Button(onClick = { /* rute dipasang pada fase berikutnya */ }) {
            Text("Mulai")
        }
    }
}
