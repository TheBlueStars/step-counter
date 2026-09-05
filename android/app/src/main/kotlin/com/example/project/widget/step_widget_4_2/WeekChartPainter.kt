package com.example.project.widget.step_widget_4_2

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.DashPathEffect
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
import androidx.annotation.ColorInt

object WeekChartPainter {

    private const val LABEL_HEIGHT_DP = 16f
    private const val LABEL_SIZE_DP = 10f
    private const val BAR_WIDTH_DP = 12f
    private const val BAR_RADIUS_DP = 2f
    private const val EMPTY_BAR_HEIGHT_DP = 1f
    private const val FUTURE_BAR_HEIGHT_DP = 3f
    private const val MAX_BAR_RATIO = 0.9f

    private val LABELS = listOf("M", "T", "W", "T", "F", "S", "S")

    fun render(
        context: Context,
        widthDp: Float,
        heightDp: Float,
        weekSteps: List<Int>,
        goal: Int,
        todayIndex: Int,
        style: WeekChartStyle = WeekChartStyle.from(context),
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val width = (widthDp * density).toInt().coerceAtLeast(1)
        val height = (heightDp * density).toInt().coerceAtLeast(1)

        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val labelHeight = LABEL_HEIGHT_DP * density
        val plotHeight = height - labelHeight
        if (plotHeight <= 0) return bitmap

        val barWidth = BAR_WIDTH_DP * density
        val radius = BAR_RADIUS_DP * density
        val slot = width / LABELS.size.toFloat()

        val peak = weekSteps.maxOrNull() ?: 0
        val peakIndex = weekSteps.indexOfFirst { it == peak && it > 0 }
        val usableHeight = plotHeight * MAX_BAR_RATIO

        drawAverageLine(
            canvas = canvas,
            width = width.toFloat(),
            plotHeight = plotHeight,
            usableHeight = usableHeight,
            weekSteps = weekSteps,
            peak = peak,
            density = density,
            color = style.averageLineColor,
        )

        val labelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = style.labelColor
            textSize = LABEL_SIZE_DP * density
            textAlign = Paint.Align.CENTER
        }

        LABELS.forEachIndexed { index, label ->
            val centerX = slot * index + slot / 2f
            val steps = weekSteps.getOrElse(index) { 0 }
            val isFuture = index > todayIndex

            val barHeight = when {
                steps > 0 && peak > 0 ->
                    (usableHeight * steps / peak).coerceAtLeast(FUTURE_BAR_HEIGHT_DP * density)
                isFuture -> FUTURE_BAR_HEIGHT_DP * density
                else -> EMPTY_BAR_HEIGHT_DP * density
            }

            val rect = RectF(
                centerX - barWidth / 2f,
                plotHeight - barHeight,
                centerX + barWidth / 2f,
                plotHeight,
            )

            canvas.drawRoundRect(
                rect,
                radius,
                radius,
                barPaint(rect, steps, goal, index, peakIndex, isFuture, style, density),
            )
            canvas.drawText(label, centerX, height - labelPaint.descent(), labelPaint)
        }

        return bitmap
    }

    private fun drawAverageLine(
        canvas: Canvas,
        width: Float,
        plotHeight: Float,
        usableHeight: Float,
        weekSteps: List<Int>,
        peak: Int,
        density: Float,
        @ColorInt color: Int,
    ) {
        if (peak <= 0) return

        val average = weekSteps.sum().toFloat() / LABELS.size
        if (average <= 0f) return

        val y = plotHeight - usableHeight * average / peak

        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = color
            style = Paint.Style.STROKE
            strokeWidth = density
            pathEffect = DashPathEffect(floatArrayOf(4f * density, 4f * density), 0f)
        }
        canvas.drawLine(0f, y, width, y, paint)
    }

    private fun barPaint(
        rect: RectF,
        steps: Int,
        goal: Int,
        index: Int,
        peakIndex: Int,
        isFuture: Boolean,
        style: WeekChartStyle,
        density: Float,
    ): Paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        if (steps <= 0) {
            color = if (isFuture) style.futureColor else style.emptyColor
            return@apply
        }

        val bar = when {
            index == peakIndex -> style.peak
            goal in 1..steps -> style.reachedGoal
            else -> style.belowGoal
        }

        shader = LinearGradient(
            rect.centerX(),
            rect.top,
            rect.centerX(),
            rect.bottom,
            bar.gradientTop,
            bar.gradientBottom,
            Shader.TileMode.CLAMP,
        )

        if (style.shadowBlurDp <= 0f) return@apply

        setShadowLayer(style.shadowBlurDp * density, 0f, 0f, bar.shadowColor)
    }
}
