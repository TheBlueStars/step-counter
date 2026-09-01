package com.example.project.preferences

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit
import com.example.project.constants.StepCounterConstants
import com.example.project.utils.StepTimeUtils

/**
 * Toàn bộ dữ liệu bước chân được lưu bằng SharedPreferences:
 *  - steps_<hourStart>  : số bước trong 1 giờ (giữ 30 ngày gần nhất)
 *  - active_<hourStart> : số phút có hoạt động trong 1 giờ
 *  - day_<dayStart>     : tổng số bước 1 ngày (không xoá, dùng cho streak/thống kê dài hạn)
 *  - medal_<name>       : thời điểm mở khoá huy hiệu
 */
class StepCounterPreferences(context: Context) {

    private val prefs: SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    private var lastPrunedHour = -1L

    var lastRaw: Float
        get() = prefs.getFloat(KEY_LAST_RAW, -1f)
        set(value) = prefs.edit { putFloat(KEY_LAST_RAW, value) }

    var lastActiveMinute: Long
        get() = prefs.getLong(KEY_LAST_ACTIVE_MINUTE, -1L)
        set(value) = prefs.edit { putLong(KEY_LAST_ACTIVE_MINUTE, value) }

    var isServiceEnabled: Boolean
        get() = prefs.getBoolean(KEY_SERVICE_ENABLED, false)
        set(value) = prefs.edit { putBoolean(KEY_SERVICE_ENABLED, value) }

    var isPaused: Boolean
        get() = prefs.getBoolean(KEY_PAUSED, false)
        set(value) = prefs.edit { putBoolean(KEY_PAUSED, value) }

    var pausedAt: Long
        get() = prefs.getLong(KEY_PAUSED_AT, -1L)
        set(value) = prefs.edit { putLong(KEY_PAUSED_AT, value) }

    var notifGoal: Int
        get() = prefs.getInt(KEY_NOTIF_GOAL, DEFAULT_GOAL)
        set(value) = prefs.edit { putInt(KEY_NOTIF_GOAL, value) }

    var heightCm: Float
        get() = prefs.getFloat(KEY_HEIGHT_CM, StepCounterConstants.DEFAULT_HEIGHT_CM)
        set(value) = prefs.edit { putFloat(KEY_HEIGHT_CM, value) }

    var weightKg: Float
        get() = prefs.getFloat(KEY_WEIGHT_KG, StepCounterConstants.DEFAULT_WEIGHT_KG)
        set(value) = prefs.edit { putFloat(KEY_WEIGHT_KG, value) }

    var paceSpeedMps: Float
        get() = prefs.getFloat(KEY_PACE_SPEED_MPS, StepCounterConstants.DEFAULT_PACE_SPEED_MPS)
        set(value) = prefs.edit { putFloat(KEY_PACE_SPEED_MPS, value) }

    var paceMet: Float
        get() = prefs.getFloat(KEY_PACE_MET, StepCounterConstants.DEFAULT_PACE_MET)
        set(value) = prefs.edit { putFloat(KEY_PACE_MET, value) }

    var lifetimeSteps: Int
        get() = prefs.getInt(KEY_LIFETIME_STEPS, 0)
        set(value) = prefs.edit { putInt(KEY_LIFETIME_STEPS, value.coerceAtLeast(0)) }

    fun resetBaseline() = prefs.edit { remove(KEY_LAST_RAW) }

    fun getHourSteps(hourStart: Long): Int = prefs.getInt(KEY_STEPS + hourStart, 0)

    fun setHourSteps(hourStart: Long, steps: Int) {
        prefs.edit { putInt(KEY_STEPS + hourStart, steps.coerceAtLeast(0)) }
        if (hourStart == lastPrunedHour) return

        lastPrunedHour = hourStart
        pruneOldHours(hourStart)
    }

    fun getHourActiveMinutes(hourStart: Long): Int = prefs.getInt(KEY_ACTIVE + hourStart, 0)

    fun setHourActiveMinutes(hourStart: Long, minutes: Int) {
        prefs.edit { putInt(KEY_ACTIVE + hourStart, minutes.coerceAtLeast(0)) }
    }

    fun removeHour(hourStart: Long) {
        prefs.edit {
            remove(KEY_STEPS + hourStart)
            remove(KEY_ACTIVE + hourStart)
        }
    }

    fun getAllHourSteps(): Map<Long, Int> = buildMap {
        for ((key, value) in prefs.all) {
            if (!key.startsWith(KEY_STEPS) || value !is Int) continue
            val hourStart = key.removePrefix(KEY_STEPS).toLongOrNull() ?: continue
            put(hourStart, value)
        }
    }


    fun getDayGoal(dayStart: Long): Int = prefs.getInt(KEY_GOAL + dayStart, notifGoal)

    fun setDayGoal(dayStart: Long, goal: Int) {
        prefs.edit { putInt(KEY_GOAL + dayStart, goal.coerceAtLeast(1)) }
    }

    fun getAllDayGoals(): Map<Long, Int> = buildMap {
        for ((key, value) in prefs.all) {
            if (!key.startsWith(KEY_GOAL) || value !is Int) continue
            val dayStart = key.removePrefix(KEY_GOAL).toLongOrNull() ?: continue
            put(dayStart, value)
        }
    }

    fun getDaySteps(dayStart: Long): Int = prefs.getInt(KEY_DAY + dayStart, 0)

    fun setDaySteps(dayStart: Long, steps: Int) {
        prefs.edit { putInt(KEY_DAY + dayStart, steps.coerceAtLeast(0)) }
    }

    fun addDaySteps(dayStart: Long, delta: Int) {
        if (delta == 0) return

        setDaySteps(dayStart, getDaySteps(dayStart) + delta)
        lifetimeSteps += delta
    }

    fun getAllDaySteps(): Map<Long, Int> = buildMap {
        for ((key, value) in prefs.all) {
            if (!key.startsWith(KEY_DAY) || value !is Int) continue
            val dayStart = key.removePrefix(KEY_DAY).toLongOrNull() ?: continue
            put(dayStart, value)
        }
    }

    fun todaySteps(timestampMillis: Long = System.currentTimeMillis()): Int =
        getDaySteps(StepTimeUtils.dayStartMillis(timestampMillis))

    fun recomputeDay(dayStart: Long): Int {
        var total = 0
        for (hour in 0 until StepCounterConstants.HOURS_PER_DAY) {
            total += getHourSteps(dayStart + hour * StepCounterConstants.HOUR_MILLIS)
        }

        val previous = getDaySteps(dayStart)
        setDaySteps(dayStart, total)
        lifetimeSteps += total - previous
        return total
    }

    fun clearDay(dayStart: Long) {
        for (hour in 0 until StepCounterConstants.HOURS_PER_DAY) {
            removeHour(dayStart + hour * StepCounterConstants.HOUR_MILLIS)
        }

        lifetimeSteps -= getDaySteps(dayStart)
        setDaySteps(dayStart, 0)
        resetBaseline()
    }

    fun getMedals(): Map<String, Long> = buildMap {
        for ((key, value) in prefs.all) {
            if (!key.startsWith(KEY_MEDAL) || value !is Long) continue
            put(key.removePrefix(KEY_MEDAL), value)
        }
    }

    fun unlockMedal(name: String, atMillis: Long): Boolean {
        if (prefs.contains(KEY_MEDAL + name)) return false

        prefs.edit { putLong(KEY_MEDAL + name, atMillis) }
        return true
    }

    private fun pruneOldHours(currentHourStart: Long) {
        val cutoff = currentHourStart - RETENTION_HOURS * StepCounterConstants.HOUR_MILLIS
        prefs.edit {
            for (key in prefs.all.keys) {
                if (!key.startsWith(KEY_STEPS) && !key.startsWith(KEY_ACTIVE)) continue
                val hourStart = key.substringAfter('_', "").toLongOrNull() ?: continue
                if (hourStart < cutoff) remove(key)
            }
        }
    }

    private companion object {
        const val PREFS_NAME = "step_counter_prefs"
        const val KEY_LAST_RAW = "last_raw"
        const val KEY_LAST_ACTIVE_MINUTE = "last_active_minute"
        const val KEY_SERVICE_ENABLED = "service_enabled"
        const val KEY_PAUSED = "paused"
        const val KEY_PAUSED_AT = "paused_at"
        const val KEY_NOTIF_GOAL = "notif_goal"
        const val KEY_HEIGHT_CM = "profile_height_cm"
        const val KEY_WEIGHT_KG = "profile_weight_kg"
        const val KEY_PACE_SPEED_MPS = "profile_pace_speed_mps"
        const val KEY_PACE_MET = "profile_pace_met"
        const val KEY_LIFETIME_STEPS = "lifetime_steps"
        const val KEY_STEPS = "steps_"
        const val KEY_ACTIVE = "active_"
        const val KEY_DAY = "day_"
        const val KEY_GOAL = "goal_"
        const val KEY_MEDAL = "medal_"
        const val RETENTION_HOURS = 24 * 30
        const val DEFAULT_GOAL = 10000
    }
}
