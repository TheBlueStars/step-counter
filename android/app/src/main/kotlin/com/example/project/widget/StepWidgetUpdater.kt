package com.example.project.widget

import android.content.Context
import android.os.SystemClock
import android.util.Log
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.appwidget.updateAll
import com.example.project.widget.step_widget_2_2.StepSquareAppWidget
import com.example.project.widget.step_widget_4_2.StepAppWidget
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

object StepWidgetUpdater {

    private const val TAG = "StepWidgetUpdater"
    private const val MIN_INTERVAL_MS = 5_000L

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    @Volatile
    private var lastUpdateAt = 0L

    fun update(context: Context, force: Boolean = false) {
        val now = SystemClock.elapsedRealtime()
        if (!force && now - lastUpdateAt < MIN_INTERVAL_MS) return

        lastUpdateAt = now
        val appContext = context.applicationContext

        scope.launch {
            try {
                refresh(appContext, StepAppWidget())
                refresh(appContext, StepSquareAppWidget())
            } catch (e: Exception) {
                Log.e(TAG, "updateAll failed", e)
            }
        }
    }

    private suspend fun refresh(context: Context, widget: GlanceAppWidget) {
        GlanceAppWidgetManager(context).getGlanceIds(widget.javaClass).forEach { id ->
            updateAppWidgetState(context, id) { prefs ->
                prefs[WIDGET_REVISION] = (prefs[WIDGET_REVISION] ?: 0) + 1
            }
        }

        widget.updateAll(context)
    }
}

internal val WIDGET_REVISION = intPreferencesKey("step_widget_revision")
