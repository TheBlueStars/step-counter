package com.example.project.services

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.example.project.MainActivity

object OpenAppAction {

    fun intent(context: Context): Intent =
        Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }

    fun pendingIntent(context: Context): PendingIntent = PendingIntent.getActivity(
        context,
        0,
        intent(context),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
}
