package com.example.project.widget.step_widget_4_2

import android.content.Context
import androidx.annotation.ColorInt
import com.example.project.R

data class WeekBarStyle(
    @param:ColorInt val gradientTop: Int,
    @param:ColorInt val gradientBottom: Int,
    @param:ColorInt val shadowColor: Int = gradientBottom,
)

data class WeekChartStyle(
    val peak: WeekBarStyle,
    val reachedGoal: WeekBarStyle,
    val belowGoal: WeekBarStyle,
    @param:ColorInt val emptyColor: Int,
    @param:ColorInt val futureColor: Int,
    @param:ColorInt val averageLineColor: Int,
    @param:ColorInt val labelColor: Int,
    val shadowBlurDp: Float = 4f,
) {
    companion object {
        fun from(context: Context, shadowBlurDp: Float = 4f) = WeekChartStyle(
            peak = WeekBarStyle(
                gradientTop = context.getColor(R.color.widget_bar_today_top),
                gradientBottom = context.getColor(R.color.widget_bar_today_bottom),
            ),
            reachedGoal = WeekBarStyle(
                gradientTop = context.getColor(R.color.widget_bar_goal_top),
                gradientBottom = context.getColor(R.color.widget_bar_goal_bottom),
            ),
            belowGoal = WeekBarStyle(
                gradientTop = context.getColor(R.color.widget_bar_mid_top),
                gradientBottom = context.getColor(R.color.widget_bar_mid_bottom),
            ),
            emptyColor = context.getColor(R.color.widget_bar_empty),
            futureColor = context.getColor(R.color.widget_bar_future),
            averageLineColor = context.getColor(R.color.notif_primary),
            labelColor = context.getColor(R.color.notif_text_secondary),
            shadowBlurDp = shadowBlurDp,
        )
    }
}
