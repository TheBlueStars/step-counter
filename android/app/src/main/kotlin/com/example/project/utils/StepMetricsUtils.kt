package com.example.project.utils

/**
 * Công thức giống StepMetricsUtils bên Dart:
 *  stride   = height(m) x 0.414
 *  distance = stride x steps
 *  time     = distance / speed
 *  calories = time(phút) x MET x 3.5 x weight(kg) / 200
 */
object StepMetricsUtils {

    private const val STRIDE_FACTOR = 0.414

    fun strideMeters(heightCm: Double): Double = heightCm / 100 * STRIDE_FACTOR

    fun distanceMeters(steps: Int, heightCm: Double): Double =
        strideMeters(heightCm) * steps

    fun distanceKm(steps: Int, heightCm: Double): Double =
        distanceMeters(steps, heightCm) / 1000

    fun walkingSeconds(steps: Int, heightCm: Double, speedMps: Double): Double {
        if (speedMps <= 0) return 0.0

        return distanceMeters(steps, heightCm) / speedMps
    }

    fun calories(
        steps: Int,
        heightCm: Double,
        weightKg: Double,
        speedMps: Double,
        met: Double,
    ): Double {
        val minutes = walkingSeconds(steps, heightCm, speedMps) / 60
        return minutes * met * 3.5 * weightKg / 200
    }
}
