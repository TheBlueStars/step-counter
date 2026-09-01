package com.example.project.handler

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.example.project.preferences.StepCounterPreferences
import com.example.project.sensor.StepObserver
import com.example.project.sensor.StepSensorHub
import io.flutter.plugin.common.EventChannel


class StepCounterStreamHandler(
    private val context: Context,
    private val preferences: StepCounterPreferences,
) : EventChannel.StreamHandler {

    private val mainHandler = Handler(Looper.getMainLooper())
    private var stepObserver: StepObserver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onCancel(arguments)
        if (events == null) return

        val observer: StepObserver = { steps, activeMinutes, timestamp ->
            val payload = mapOf(
                "todaySteps" to preferences.todaySteps(timestamp),
                "hourSteps" to steps,
                "activeMinutes" to activeMinutes,
                "timestampMs" to timestamp,
            )
            mainHandler.post { events.success(payload) }
        }

        if (!StepSensorHub.addObserver(context, preferences, observer)) {
            events.error("SENSOR_UNAVAILABLE", "Thiết bị không có cảm biến TYPE_STEP_COUNTER", null)
            return
        }

        stepObserver = observer
    }

    override fun onCancel(arguments: Any?) {
        stepObserver?.let { StepSensorHub.removeObserver(it) }
        stepObserver = null
    }
}
