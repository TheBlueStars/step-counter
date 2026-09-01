package com.example.project.sensor

import android.content.Context
import android.util.Log
import com.example.project.preferences.StepCounterPreferences

typealias StepObserver = (steps: Int, activeMinutes: Int, timestampMillis: Long) -> Unit

object StepSensorHub {

    private const val TAG = "StepSensorHub"

    private val observers = mutableListOf<StepObserver>()
    private var listener: StepSensorListener? = null

    @Synchronized
    fun addObserver(
        context: Context,
        preferences: StepCounterPreferences,
        observer: StepObserver,
    ): Boolean {
        observers += observer

        if (preferences.isPaused) {
            Log.i(TAG, "observer added while paused, total=${observers.size}")
            return true
        }

        if (listener != null) {
            Log.i(TAG, "observer added to running listener, total=${observers.size}")
            return true
        }

        if (!startListener(context.applicationContext, preferences)) {
            observers -= observer
            return false
        }

        return true
    }

    @Synchronized
    fun removeObserver(observer: StepObserver) {
        observers -= observer
        if (observers.isNotEmpty()) return

        stopListener()
        Log.i(TAG, "last observer removed, listener stopped")
    }

    @Synchronized
    fun pause(preferences: StepCounterPreferences) {
        preferences.isPaused = true
        preferences.pausedAt = System.currentTimeMillis()
        stopListener()
        Log.i(TAG, "paused, observers kept=${observers.size}")
    }

    @Synchronized
    fun resume(context: Context, preferences: StepCounterPreferences): Boolean {
        preferences.isPaused = false
        preferences.resetBaseline()

        if (observers.isEmpty() || listener != null) return true

        return startListener(context.applicationContext, preferences)
    }

    fun isSensorAvailable(context: Context): Boolean =
        StepSensorListener(context.applicationContext, StepCounterPreferences(context)) { _, _, _ -> }
            .isSensorAvailable

    private fun startListener(
        context: Context,
        preferences: StepCounterPreferences,
    ): Boolean {
        val created = StepSensorListener(context, preferences) { steps, activeMinutes, timestamp ->
            observers.toList().forEach { it(steps, activeMinutes, timestamp) }
        }

        if (!created.start()) return false

        listener = created
        Log.i(TAG, "listener started, observers=${observers.size}")
        return true
    }

    private fun stopListener() {
        listener?.stop()
        listener = null
    }
}
