package com.example.project.utils

import java.util.Calendar

object StepTimeUtils {

    fun hourStartMillis(timestampMillis: Long): Long =
        Calendar.getInstance().apply {
            timeInMillis = timestampMillis
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis

    fun dayStartMillis(timestampMillis: Long): Long =
        Calendar.getInstance().apply {
            timeInMillis = timestampMillis
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis

    fun weekStartMillis(timestampMillis: Long): Long {
        val calendar = Calendar.getInstance().apply {
            timeInMillis = dayStartMillis(timestampMillis)
        }
        calendar.add(Calendar.DAY_OF_YEAR, -weekdayIndex(timestampMillis))

        return calendar.timeInMillis
    }

    fun weekdayIndex(timestampMillis: Long): Int {
        val calendar = Calendar.getInstance().apply {
            timeInMillis = timestampMillis
        }

        return (calendar.get(Calendar.DAY_OF_WEEK) + 5) % 7
    }
}
