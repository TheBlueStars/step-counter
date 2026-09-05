package com.example.project.widget.step_widget_2_2

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
import androidx.glance.state.PreferencesGlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.example.project.R
import com.example.project.services.OpenAppAction
import com.example.project.widget.ProgressRing
import com.example.project.widget.SQUARE_HEIGHT_DP
import com.example.project.widget.SQUARE_WIDTH_DP
import com.example.project.widget.StepWidgetState
import com.example.project.widget.WIDGET_REVISION
import com.example.project.widget.formatInteger
import com.example.project.widget.readStepWidgetState

private const val RING_SIZE_DP = 58f
private const val RING_STROKE_DP = 8f
private const val SHOE_SIZE_DP = 44f

class StepSquareAppWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Single

    override val stateDefinition = PreferencesGlanceStateDefinition

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            currentState(WIDGET_REVISION)
            Content(context, readStepWidgetState(context))
        }
    }
}

@SuppressLint("RestrictedApi")
@Composable
private fun Content(context: Context, state: StepWidgetState) {
    Box(
        modifier = GlanceModifier.fillMaxSize(),
        contentAlignment = Alignment.TopStart,
    ) {
        Column(
            modifier = GlanceModifier
                .size(SQUARE_WIDTH_DP.dp, SQUARE_HEIGHT_DP.dp)
                .background(ImageProvider(R.drawable.bg_widget))
                .padding(12.dp)
                .clickable(actionStartActivity(OpenAppAction.intent(context))),
            verticalAlignment = Alignment.Vertical.Top,
            horizontalAlignment = Alignment.Horizontal.Start,
        ) {
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Vertical.Top,
            ) {
                ProgressRing(
                    context = context,
                    progress = state.progress,
                    sizeDp = RING_SIZE_DP,
                    strokeWidthDp = RING_STROKE_DP,
                    labelSize = 12.sp,
                    decimals = 1,
                )

                Spacer(GlanceModifier.defaultWeight())

                Image(
                    provider = ImageProvider(R.drawable.ic_step),
                    contentDescription = null,
                    modifier = GlanceModifier.size(SHOE_SIZE_DP.dp),
                )
            }

            Spacer(GlanceModifier.height(8.dp))

            Text(
                text = "Steps",
                style = TextStyle(
                    color = ColorProvider(R.color.notif_text_secondary),
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium,
                ),
                maxLines = 1,
            )

            Spacer(GlanceModifier.height(2.dp))

            Text(
                text = formatInteger(state.steps),
                style = TextStyle(
                    color = ColorProvider(R.color.color_neutral_black),
                    fontSize = 26.sp,
                    fontWeight = FontWeight.Bold,
                ),
                maxLines = 1,
            )
        }
    }
}
