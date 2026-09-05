package com.example.project.widget

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.SweepGradient
import androidx.annotation.ColorInt
import kotlin.math.max

object RingProgressPainter {

    private const val START_ANGLE = 90f
    private const val TOTAL_SWEEP = 360f

    fun render(
        context: Context,
        sizeDp: Float,
        strokeWidthDp: Float,
        progress: Float,
        @ColorInt color: Int,
        @ColorInt trackColor: Int,
        gradientColors: IntArray? = null,
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val size = (sizeDp * density).toInt().coerceAtLeast(1)
        val stroke = strokeWidthDp * density

        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val inset = stroke / 2f
        val rect = RectF(inset, inset, size - inset, size - inset)

        val track = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = trackColor
            style = Paint.Style.STROKE
            strokeWidth = stroke
            strokeCap = Paint.Cap.ROUND
        }
        canvas.drawArc(rect, START_ANGLE, TOTAL_SWEEP, false, track)

        if (progress <= 0f) return bitmap

        val sweep = TOTAL_SWEEP * progress.coerceIn(0f, 1f)

        val arc = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = stroke
            strokeCap = Paint.Cap.ROUND
        }

        arc.applyStroke(rect, sweep, stroke, color, gradientColors)

        canvas.drawArc(rect, START_ANGLE, sweep, false, arc)

        return bitmap
    }

    private fun Paint.applyStroke(
        rect: RectF,
        sweep: Float,
        stroke: Float,
        @ColorInt color: Int,
        gradientColors: IntArray?,
    ) {
        if (gradientColors == null || gradientColors.size < 2) {
            this.color = color
            return
        }

        val capAngle = Math.toDegrees((stroke / rect.width()).toDouble()).toFloat()
        val span = max(sweep + capAngle, 0.01f)

        val frac = (span / TOTAL_SWEEP).coerceIn(0f, 1f)
        val last = gradientColors.size - 1
        val positions = FloatArray(gradientColors.size) { i -> i.toFloat() / last * frac }

        shader = SweepGradient(rect.centerX(), rect.centerY(), gradientColors, positions).apply {
            setLocalMatrix(
                Matrix().apply {
                    setRotate(START_ANGLE - capAngle, rect.centerX(), rect.centerY())
                },
            )
        }
    }
}
