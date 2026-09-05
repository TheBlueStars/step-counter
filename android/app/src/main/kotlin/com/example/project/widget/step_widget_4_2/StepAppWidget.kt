package com.example.project.widget.step_widget_4_2

import android.annotation.SuppressLint
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.state.PreferencesGlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.example.project.R
import com.example.project.services.OpenAppAction
import com.example.project.widget.ProgressRing
import com.example.project.widget.StepWidgetState
import com.example.project.widget.WIDE_HEIGHT_DP
import com.example.project.widget.WIDE_WIDTH_DP
import com.example.project.widget.WIDGET_REVISION
import com.example.project.widget.formatInteger
import com.example.project.widget.readStepWidgetState
import java.util.Locale

private const val PADDING_DP = 12f
private const val COLUMN_GAP_DP = 10f
private const val LEFT_COLUMN_DP = 80f
private const val RING_SIZE_DP = 56f
private const val RING_STROKE_DP = 8f
private const val CHART_HEIGHT_DP = 75f

class StepAppWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Single

    override val stateDefinition = PreferencesGlanceStateDefinition

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            currentState(WIDGET_REVISION)
            Content(context, readStepWidgetState(context))
        }
    }
}

@Composable
private fun Content(context: Context, state: StepWidgetState) {
    Box(
        modifier = GlanceModifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        Row(
            modifier = GlanceModifier
                .size(WIDE_WIDTH_DP.dp, WIDE_HEIGHT_DP.dp)
                .background(ImageProvider(R.drawable.bg_widget))
                .padding(PADDING_DP.dp)
                .clickable(actionStartActivity(OpenAppAction.intent(context))),
            verticalAlignment = Alignment.Vertical.Top,
        ) {
            ProgressColumn(context, state)

            Spacer(GlanceModifier.width(COLUMN_GAP_DP.dp))

            ChartColumn(context, state)
        }
    }
}

@SuppressLint("RestrictedApi")
@Composable
private fun ProgressColumn(context: Context, state: StepWidgetState) {
    Column(
        modifier = GlanceModifier.width(LEFT_COLUMN_DP.dp),
        horizontalAlignment = Alignment.Horizontal.Start,
    ) {
        ProgressRing(
            context = context,
            progress = state.weekProgress,
            sizeDp = RING_SIZE_DP,
            strokeWidthDp = RING_STROKE_DP,
            labelSize = 10.sp,
            decimals = 1,
        )

        Spacer(GlanceModifier.height(6.dp))

        Text(
            text = "Steps",
            style = TextStyle(
                color = ColorProvider(R.color.notif_text_secondary),
                fontSize = 12.sp,
                fontWeight = FontWeight.Medium,
            ),
            maxLines = 1,
        )

        Spacer(GlanceModifier.height(2.dp))

        Text(
            text = formatInteger(state.weekTotal),
            style = TextStyle(
                color = ColorProvider(R.color.color_neutral_black),
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
            ),
            maxLines = 1,
        )
    }
}

@Composable
private fun ChartColumn(context: Context, state: StepWidgetState) {
    val chartWidth = WIDE_WIDTH_DP - PADDING_DP * 2 - LEFT_COLUMN_DP - COLUMN_GAP_DP

    Column(
        modifier = GlanceModifier.fillMaxWidth(),
        horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
    ) {
        Image(
            provider = ImageProvider(
                WeekChartPainter.render(
                    context = context,
                    widthDp = chartWidth,
                    heightDp = CHART_HEIGHT_DP,
                    weekSteps = state.weekSteps,
                    goal = state.goal,
                    todayIndex = state.todayIndex,
                ),
            ),
            contentDescription = null,
            modifier = GlanceModifier.size(chartWidth.dp, CHART_HEIGHT_DP.dp),
        )

        Spacer(GlanceModifier.height(8.dp))

        Row(modifier = GlanceModifier.fillMaxWidth()) {
            Spacer(GlanceModifier.width(8.dp))
            Metric(formatDuration(state.weekWalkingSeconds), "Min")
            Spacer(GlanceModifier.defaultWeight())
            Metric(String.format(Locale.getDefault(), "%.1f", state.weekCalories), "Kcal")
            Spacer(GlanceModifier.defaultWeight())
            Metric(String.format(Locale.getDefault(), "%.1f", state.weekDistanceKm), "Km")
            Spacer(GlanceModifier.width(8.dp))
        }
    }
}

@SuppressLint("RestrictedApi")
@Composable
private fun Metric(value: String, label: String) {
    Column(horizontalAlignment = Alignment.Horizontal.CenterHorizontally) {
        Text(
            text = value,
            style = TextStyle(
                color = ColorProvider(R.color.notif_text_primary),
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold,
            ),
            maxLines = 1,
        )

        Text(
            text = label,
            style = TextStyle(
                color = ColorProvider(R.color.notif_text_secondary),
                fontSize = 10.sp,
            ),
            maxLines = 1,
        )
    }
}

private fun formatDuration(seconds: Long): String {
    val hours = seconds / 3600
    val minutes = seconds % 3600 / 60

    return "${hours}h ${minutes}m"
}
