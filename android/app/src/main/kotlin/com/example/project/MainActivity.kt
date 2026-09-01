package com.example.project

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import com.example.project.constants.StepCounterConstants
import com.example.project.handler.StepCounterMethodCallHandler
import com.example.project.handler.StepCounterStreamHandler
import com.example.project.preferences.StepCounterPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var permissionCallback: ((Boolean) -> Unit)? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val preferences = StepCounterPreferences(applicationContext)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, StepCounterConstants.METHOD_CHANNEL).setMethodCallHandler(
            StepCounterMethodCallHandler(
                context = applicationContext,
                preferences = preferences,
                requestMotionPermission = ::requestMotionPermission,
            ),
        )

        EventChannel(messenger, StepCounterConstants.EVENT_CHANNEL).setStreamHandler(
            StepCounterStreamHandler(applicationContext, preferences),
        )
    }

    private fun requestMotionPermission(callback: (Boolean) -> Unit) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            callback(true)
            return
        }

        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ACTIVITY_RECOGNITION,
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            callback(true)
            return
        }

        permissionCallback = callback
        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            arrayOf(
                Manifest.permission.ACTIVITY_RECOGNITION,
                Manifest.permission.POST_NOTIFICATIONS,
            )
        } else {
            arrayOf(Manifest.permission.ACTIVITY_RECOGNITION)
        }

        ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != PERMISSION_REQUEST_CODE) return

        val index = permissions.indexOf(Manifest.permission.ACTIVITY_RECOGNITION)
        val granted = index >= 0 &&
            index < grantResults.size &&
            grantResults[index] == PackageManager.PERMISSION_GRANTED

        permissionCallback?.invoke(granted)
        permissionCallback = null
    }

    private companion object {
        const val PERMISSION_REQUEST_CODE = 9001
    }
}
