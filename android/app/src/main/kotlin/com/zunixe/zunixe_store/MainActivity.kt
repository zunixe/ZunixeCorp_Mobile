package com.zunixe.zunixe_store

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.ZunixeTheme
import com.zunixe.zunixe_store.core.navigation.ZunixeNavHost
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        setContent {
            ZunixeTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = AppColors.Background,
                ) {
                    ZunixeNavHost()
                }
            }
        }
    }
}
