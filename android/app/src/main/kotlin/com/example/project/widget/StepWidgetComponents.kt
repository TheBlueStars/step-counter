package com.example.project.widget

import android.annotation.SuppressLint
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.size
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.example.project.R
import java.text.NumberFormat
import java.util.Locale

internal const val WIDE_WIDTH_DP = 300f
internal const val WIDE_HEIGHT_DP = 140f
internal const val SQUARE_WIDTH_DP = 140f
internal const val SQUARE_HEIGHT_DP = 140f
internal const val RING_STROKE_DP = 12f

@SuppressLint("RestrictedApi")
@Composable
internal fun ProgressRing(
    context: Context,
    progress: Float,
    sizeDp: Float,
    strokeWidthDp: Float = RING_STROKE_DP,
    labelSize: TextUnit = 14.sp,
    decimals: Int = 0,
) {
    Box(contentAlignment = Alignment.Center) {
        Image(
            provider = ImageProvider(
                RingProgressPainter.render(
                    context = context,
                    sizeDp = sizeDp,
                    strokeWidthDp = strokeWidthDp,
                    progress = progress,
                    color = context.getColor(R.color.notif_primary),
                    trackColor = context.getColor(R.color.notif_progress_track),
                    gradientColors = intArrayOf(
                        context.getColor(R.color.notif_primary_light),
                        context.getColor(R.color.notif_primary),
                    ),
                ),
            ),
            contentDescription = null,
            modifier = GlanceModifier.size(sizeDp.dp),
        )

        Text(
            text = String.format(
                Locale.getDefault(),
                "%.${decimals}f%%",
                progress * 100,
            ),
            style = TextStyle(
                color = ColorProvider(R.color.notif_primary),
                fontSize = labelSize,
                fontWeight = FontWeight.Medium,
            ),
            maxLines = 1,
        )
    }
}

internal fun formatInteger(value: Int): String =
    NumberFormat.getIntegerInstance(Locale.getDefault()).format(value)
