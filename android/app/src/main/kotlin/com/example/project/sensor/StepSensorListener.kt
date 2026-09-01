package com.example.project.sensor

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.SystemClock
import com.example.project.preferences.StepCounterPreferences
import com.example.project.utils.StepTimeUtils

class StepSensorListener(
    context: Context,
    private val preferences: StepCounterPreferences,
    private val onStepUpdate: (steps: Int, activeMinutes: Int, timestampMillis: Long) -> Unit,
) : SensorEventListener {

    private val sensorManager =
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

    private val stepSensor: Sensor? =
        sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)

    val isSensorAvailable: Boolean
        get() = stepSensor != null

    fun start(): Boolean {
        val sensor = stepSensor ?: return false
        return sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI)
    }

    fun stop() = sensorManager.unregisterListener(this)

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null || event.sensor.type != Sensor.TYPE_STEP_COUNTER) return

        val raw = event.values[0]
        val timestamp = wallClockMillis(event)
        val delta = stepDelta(raw)
        val hourStart = StepTimeUtils.hourStartMillis(timestamp)

        var steps = preferences.getHourSteps(hourStart)
        var activeMinutes = preferences.getHourActiveMinutes(hourStart)

        if (delta > 0) {
            steps += delta
            preferences.setHourSteps(hourStart, steps)
            preferences.addDaySteps(StepTimeUtils.dayStartMillis(timestamp), delta)
            activeMinutes = countActiveMinute(hourStart, timestamp, activeMinutes)
        }

        onStepUpdate(steps, activeMinutes, timestamp)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    private fun stepDelta(raw: Float): Int {
        val lastRaw = preferences.lastRaw
        preferences.lastRaw = raw
        return if (lastRaw >= 0 && raw >= lastRaw) (raw - lastRaw).toInt() else 0
    }

    private fun countActiveMinute(hourStart: Long, timestamp: Long, current: Int): Int {
        val minuteIndex = timestamp / 60_000
        if (minuteIndex == preferences.lastActiveMinute) return current

        preferences.lastActiveMinute = minuteIndex
        val updated = current + 1
        preferences.setHourActiveMinutes(hourStart, updated)
        return updated
    }

    private fun wallClockMillis(event: SensorEvent): Long =
        System.currentTimeMillis() -
            (SystemClock.elapsedRealtimeNanos() - event.timestamp) / 1_000_000
}
