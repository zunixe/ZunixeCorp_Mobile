package com.zunixe.zunixe_store.core.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.zunixe.zunixe_store.R

/** Font brand Ubuntu (aset dari proyek Flutter lama). */
val Ubuntu = FontFamily(
    Font(R.font.ubuntu_regular, FontWeight.Normal),
    Font(R.font.ubuntu_medium, FontWeight.Medium),
    Font(R.font.ubuntu_bold, FontWeight.Bold),
)

private val ZunixeColorScheme = lightColorScheme(
    primary = AppColors.Brand,
    onPrimary = androidx.compose.ui.graphics.Color.White,
    secondary = AppColors.BrandDark,
    background = AppColors.Background,
    onBackground = AppColors.Ink,
    surface = androidx.compose.ui.graphics.Color.White,
    onSurface = AppColors.Ink,
    error = AppColors.Error,
)

private val ZunixeTypography = Typography(
    displayLarge = TextStyle(fontFamily = Ubuntu, fontWeight = FontWeight.Bold, fontSize = 32.sp),
    headlineLarge = TextStyle(fontFamily = Ubuntu, fontWeight = FontWeight.Bold, fontSize = 28.sp),
    headlineMedium = TextStyle(fontFamily = Ubuntu, fontWeight = FontWeight.Bold, fontSize = 24.sp),
    headlineSmall = TextStyle(fontFamily = Ubuntu, fontWeight = FontWeight.Bold, fontSize = 20.sp),
    titleLarge = TextStyle(fontFamily = Ubuntu, fontWeight = FontWeight.Bold, fontSize = 18.sp),
    titleMedium = TextStyle(fontFamily = Ubuntu, fontWeight = FontWeight.SemiBold, fontSize = 16.sp),
    titleSmall = TextStyle(fontFamily = Ubuntu, fontWeight = FontWeight.SemiBold, fontSize = 14.sp),
    bodyLarge = TextStyle(fontFamily = Ubuntu, fontSize = 15.sp),
    bodyMedium = TextStyle(fontFamily = Ubuntu, fontSize = 14.sp),
    bodySmall = TextStyle(fontFamily = Ubuntu, fontSize = 12.sp),
    labelLarge = TextStyle(fontFamily = Ubuntu, fontWeight = FontWeight.SemiBold, fontSize = 14.sp),
    labelMedium = TextStyle(fontFamily = Ubuntu, fontWeight = FontWeight.SemiBold, fontSize = 12.sp),
    labelSmall = TextStyle(fontFamily = Ubuntu, fontSize = 11.sp),
)

@Composable
fun ZunixeTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = ZunixeColorScheme,
        typography = ZunixeTypography,
        content = content,
    )
}
