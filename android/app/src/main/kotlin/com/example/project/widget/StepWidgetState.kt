package com.example.project.widget

import android.content.Context
import com.example.project.preferences.StepCounterPreferences
import com.example.project.utils.StepMetricsUtils
import com.example.project.utils.StepTimeUtils
import kotlin.math.roundToLong

private const val DAYS_IN_WEEK = 7
private const val DAY_MILLIS = 24 * 60 * 60 * 1000L

internal data class StepWidgetState(
    val steps: Int,
    val goal: Int,
    val calories: Double,
    val distanceKm: Double,
    val walkingSeconds: Long = 0,
    val weekCalories: Double = 0.0,
    val weekDistanceKm: Double = 0.0,
    val weekWalkingSeconds: Long = 0,
    val weekSteps: List<Int> = emptyList(),
    val todayIndex: Int = 0,
) {
    val progress: Float
        get() = if (goal > 0) (steps.toFloat() / goal).coerceIn(0f, 1f) else 0f

    val weekTotal: Int
        get() = weekSteps.sum()

    val weekProgress: Float
        get() = if (goal > 0) {
            (weekTotal.toFloat() / (goal * DAYS_IN_WEEK)).coerceIn(0f, 1f)
        } else {
            0f
        }
}

internal fun readStepWidgetState(context: Context): StepWidgetState {
    val preferences = StepCounterPreferences(context)
    val now = System.currentTimeMillis()
    val today = StepTimeUtils.dayStartMillis(now)

    val steps = preferences.getDaySteps(today)
    val heightCm = preferences.heightCm.toDouble()
    val weightKg = preferences.weightKg.toDouble()
    val speedMps = preferences.paceSpeedMps.toDouble()
    val met = preferences.paceMet.toDouble()
    val weekSteps = preferences.weekSteps(now)
    val weekTotal = weekSteps.sum()

    return StepWidgetState(
        steps = steps,
        goal = preferences.getDayGoal(today),
        calories = StepMetricsUtils.calories(
            steps = steps,
            heightCm = heightCm,
            weightKg = weightKg,
            speedMps = speedMps,
            met = met,
        ),
        distanceKm = StepMetricsUtils.distanceKm(steps, heightCm),
        walkingSeconds = StepMetricsUtils.walkingSeconds(steps, heightCm, speedMps).roundToLong(),
        weekCalories = StepMetricsUtils.calories(
            steps = weekTotal,
            heightCm = heightCm,
            weightKg = weightKg,
            speedMps = speedMps,
            met = met,
        ),
        weekDistanceKm = StepMetricsUtils.distanceKm(weekTotal, heightCm),
        weekWalkingSeconds = StepMetricsUtils
            .walkingSeconds(weekTotal, heightCm, speedMps)
            .roundToLong(),
        weekSteps = weekSteps,
        todayIndex = StepTimeUtils.weekdayIndex(now),
    )
}

private fun StepCounterPreferences.weekSteps(now: Long): List<Int> {
    val weekStart = StepTimeUtils.weekStartMillis(now)

    return List(DAYS_IN_WEEK) { day -> getDaySteps(weekStart + day * DAY_MILLIS) }
}
