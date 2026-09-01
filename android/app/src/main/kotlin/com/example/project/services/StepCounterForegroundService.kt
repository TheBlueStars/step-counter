package com.example.project.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.example.project.MainActivity
import com.example.project.preferences.StepCounterPreferences
import com.example.project.sensor.StepObserver
import com.example.project.sensor.StepSensorHub
import com.example.project.utils.StepMetricsUtils
import java.text.NumberFormat
import java.util.Locale

class StepCounterForegroundService : Service() {

    private lateinit var preferences: StepCounterPreferences
    private var stepObserver: StepObserver? = null

    override fun onCreate() {
        super.onCreate()
        preferences = StepCounterPreferences(applicationContext)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startAsForeground(preferences.todaySteps())

        if (intent?.action == ACTION_REFRESH) {
            return START_STICKY
        }

        if (stepObserver == null) {
            val observer: StepObserver = { _, _, _ -> updateNotification(preferences.todaySteps()) }

            if (!StepSensorHub.addObserver(applicationContext, preferences, observer)) {
                Log.e(TAG, "thiết bị không có cảm biến TYPE_STEP_COUNTER")
                stopSelf()
                return START_NOT_STICKY
            }

            stepObserver = observer
        }

        preferences.isServiceEnabled = true
        return START_STICKY
    }

    override fun onDestroy() {
        stepObserver?.let { StepSensorHub.removeObserver(it) }
        stepObserver = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun startAsForeground(steps: Int) {
        createChannel()
        val notification = buildNotification(steps)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun updateNotification(steps: Int) {
        notificationManager.notify(NOTIFICATION_ID, buildNotification(steps))
    }

    private fun buildNotification(steps: Int): Notification {
        val goal = preferences.notifGoal
        val percent = if (goal > 0) (steps * 100 / goal).coerceIn(0, 100) else 0
        val calories = StepMetricsUtils.calories(
            steps = steps,
            heightCm = preferences.heightCm.toDouble(),
            weightKg = preferences.weightKg.toDouble(),
            speedMps = preferences.paceSpeedMps.toDouble(),
            met = preferences.paceMet.toDouble(),
        )
        val formatter = NumberFormat.getIntegerInstance(Locale.getDefault())

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(applicationInfo.icon)
            .setContentTitle("${formatter.format(steps)} / ${formatter.format(goal)} steps")
            .setContentText(String.format(Locale.getDefault(), "%.1f kcal", calories))
            .setProgress(100, percent, false)
            .setContentIntent(contentIntent())
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun contentIntent(): PendingIntent = PendingIntent.getActivity(
        this,
        0,
        Intent(this, MainActivity::class.java)
            .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        if (notificationManager.getNotificationChannel(CHANNEL_ID) != null) return

        notificationManager.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, "Step Counter", NotificationManager.IMPORTANCE_LOW)
                .apply { setShowBadge(false) },
        )
    }

    private val notificationManager: NotificationManager
        get() = getSystemService(NOTIFICATION_SERVICE) as NotificationManager

    companion object {
        private const val TAG = "StepCounterService"
        private const val CHANNEL_ID = "step_counter_service"
        private const val NOTIFICATION_ID = 6431

        const val ACTION_REFRESH = "com.example.project.action.REFRESH"

        /** Cập nhật lại thông báo khi dữ liệu đổi (đổi mục tiêu, sửa số bước...). */
        fun refresh(context: Context) {
            if (!StepCounterPreferences(context).isServiceEnabled) return

            start(context, ACTION_REFRESH)
        }

        fun start(context: Context, action: String? = null): Boolean = try {
            val intent = Intent(context, StepCounterForegroundService::class.java)
                .apply { action?.let { setAction(it) } }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent) != null
            } else {
                context.startService(intent) != null
            }
        } catch (e: Exception) {
            Log.e(TAG, "startForegroundService thất bại", e)
            false
        }

        fun stop(context: Context) {
            StepCounterPreferences(context).isServiceEnabled = false
            context.stopService(Intent(context, StepCounterForegroundService::class.java))
        }
    }
}
