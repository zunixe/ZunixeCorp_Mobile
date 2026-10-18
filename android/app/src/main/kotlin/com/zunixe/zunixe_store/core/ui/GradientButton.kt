package com.zunixe.zunixe_store.core.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import com.zunixe.zunixe_store.core.theme.AppColors
import com.zunixe.zunixe_store.core.theme.Ubuntu

private val BrandGradient = Brush.linearGradient(
    listOf(AppColors.BrandLight, AppColors.Brand, AppColors.BrandDark),
)

/**
 * Tombol CTA gradient brand — padanan `GradientButton`.
 * `loading` menampilkan spinner dan menonaktifkan tap.
 */
@Composable
fun GradientButton(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    height: Dp = 48.dp,
    fontSize: Int = 15,
    icon: ImageVector? = null,
    loading: Boolean = false,
    expanded: Boolean = true,
    enabled: Boolean = true,
) {
    val active = enabled && !loading
    val shape = RoundedCornerShape(height / 2)

    Box(
        modifier = modifier
            .then(if (expanded) Modifier.fillMaxWidth() else Modifier)
            .height(height)
            .clip(shape)
            .background(if (active) BrandGradient else Brush.linearGradient(
                listOf(AppColors.Silver, AppColors.Disabled),
            ))
            .clickable(
                enabled = active,
                interactionSource = MutableInteractionSource(),
                indication = null,
                onClick = onClick,
            )
            .padding(horizontal = 20.dp)
            .semantics { contentDescription = label },
        contentAlignment = Alignment.Center,
    ) {
        if (loading) {
            CircularProgressIndicator(
                modifier = Modifier.size((fontSize + 4).dp),
                strokeWidth = 2.dp,
                color = Color.White,
            )
        } else {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (icon != null) {
                    Icon(icon, contentDescription = null, tint = Color.White, modifier = Modifier.size((fontSize + 4).dp))
                    Spacer(Modifier.width(8.dp))
                }
                Text(
                    text = label,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontFamily = Ubuntu,
                        color = Color.White,
                        fontSize = fontSize.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.2.sp,
                    ),
                )
            }
        }
    }
}
