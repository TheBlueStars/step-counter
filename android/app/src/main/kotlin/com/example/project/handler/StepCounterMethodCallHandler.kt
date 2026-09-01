package com.example.project.handler

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorManager
import android.os.Build
import androidx.core.content.ContextCompat
import com.example.project.preferences.StepCounterPreferences
import com.example.project.sensor.StepSensorHub
import com.example.project.services.StepCounterForegroundService
import com.example.project.utils.StepTimeUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class StepCounterMethodCallHandler(
    private val context: Context,
    private val preferences: StepCounterPreferences,
    private val requestMotionPermission: ((Boolean) -> Unit) -> Unit,
) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSensorAvailable" -> result.success(isSensorAvailable())

            "hasPermission" -> result.success(hasPermission())

            "requestPermission" -> requestMotionPermission { granted -> result.success(granted) }

            "startBackgroundTracking" -> result.success(
                StepCounterForegroundService.start(context),
            )

            "stopBackgroundTracking" -> {
                StepCounterForegroundService.stop(context)
                result.success(true)
            }

            "isBackgroundTrackingEnabled" -> result.success(preferences.isServiceEnabled)

            "pauseTracking" -> {
                StepSensorHub.pause(preferences)
                StepCounterForegroundService.stop(context)
                result.success(true)
            }

            "resumeTracking" -> {
                val resumed = StepSensorHub.resume(context, preferences)
                StepCounterForegroundService.start(context)
                result.success(resumed)
            }

            "isPaused" -> result.success(preferences.isPaused)

            "getHourlySteps" -> result.success(hourlySteps())

            "getDailySteps" -> result.success(dailySteps())

            "getTodaySteps" -> result.success(preferences.todaySteps())

            "getLifetimeSteps" -> result.success(preferences.lifetimeSteps)

            "setHourSteps" -> {
                val hourStart = call.longArg("hourStartMs")
                val steps = call.intArg("steps")
                if (hourStart == null || steps == null) {
                    result.error("INVALID_ARGS", "hourStartMs/steps bị thiếu", null)
                    return
                }

                preferences.setHourSteps(hourStart, steps)
                preferences.recomputeDay(StepTimeUtils.dayStartMillis(hourStart))
                notifyDataChanged()
                result.success(true)
            }

            "clearDay" -> {
                val dayStart = call.longArg("dayStartMs")
                if (dayStart == null) {
                    result.error("INVALID_ARGS", "dayStartMs bị thiếu", null)
                    return
                }

                preferences.clearDay(dayStart)
                notifyDataChanged()
                result.success(true)
            }

            "setConfig" -> {
                call.intArg("goal")?.let { preferences.notifGoal = it }
                call.doubleArg("heightCm")?.let { preferences.heightCm = it.toFloat() }
                call.doubleArg("weightKg")?.let { preferences.weightKg = it.toFloat() }
                call.doubleArg("paceSpeedMps")?.let { preferences.paceSpeedMps = it.toFloat() }
                call.doubleArg("paceMet")?.let { preferences.paceMet = it.toFloat() }
                notifyDataChanged()
                result.success(true)
            }

            "getConfig" -> result.success(
                mapOf(
                    "goal" to preferences.notifGoal,
                    "heightCm" to preferences.heightCm.toDouble(),
                    "weightKg" to preferences.weightKg.toDouble(),
                    "paceSpeedMps" to preferences.paceSpeedMps.toDouble(),
                    "paceMet" to preferences.paceMet.toDouble(),
                ),
            )

            "getMedals" -> result.success(preferences.getMedals())

            "unlockMedal" -> {
                val name = call.argument<String>("name")
                val at = call.longArg("atMs") ?: System.currentTimeMillis()
                if (name == null) {
                    result.error("INVALID_ARGS", "name bị thiếu", null)
                    return
                }

                result.success(preferences.unlockMedal(name, at))
            }

            else -> result.notImplemented()
        }
    }

    private fun isSensorAvailable(): Boolean {
        val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        return sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER) != null
    }

    private fun hasPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACTIVITY_RECOGNITION,
            ) == PackageManager.PERMISSION_GRANTED

    private fun hourlySteps(): List<Map<String, Any>> =
        preferences.getAllHourSteps()
            .toSortedMap()
            .map { (hourStart, steps) ->
                mapOf(
                    "hourStartMs" to hourStart,
                    "steps" to steps,
                    "activeMinutes" to preferences.getHourActiveMinutes(hourStart),
                )
            }

    private fun dailySteps(): Map<String, Int> =
        preferences.getAllDaySteps().mapKeys { (dayStart, _) -> dayStart.toString() }

    private fun notifyDataChanged() = StepCounterForegroundService.refresh(context)

    private fun MethodCall.longArg(key: String): Long? = argument<Number>(key)?.toLong()

    private fun MethodCall.intArg(key: String): Int? = argument<Number>(key)?.toInt()

    private fun MethodCall.doubleArg(key: String): Double? = argument<Number>(key)?.toDouble()
}
