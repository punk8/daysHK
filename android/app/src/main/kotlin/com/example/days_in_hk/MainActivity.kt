package com.example.days_in_hk

import android.Manifest
import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Build
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingClient
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "days_in_hk/geofence"
    private val geofenceRequestId = "hk_boundary_wakeup"
    private lateinit var geofencingClient: GeofencingClient

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        geofencingClient = LocationServices.getGeofencingClient(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "getStatus" -> result.success(statusPayload())
                "requestAlwaysAuthorization" -> {
                    requestAlwaysAuthorization(result)
                }
                "startMonitoring" -> {
                    startMonitoring(result)
                }
                "stopMonitoring" -> {
                    stopMonitoring(result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestAlwaysAuthorization(result: MethodChannel.Result) {
        if (!isLocationEnabled()) {
            result.success(statusPayload("unavailable", "Android 定位服务未开启。"))
            return
        }

        if (hasRequiredLocationPermission()) {
            result.success(statusPayload("ready", "已获得前台和后台定位权限，可启动后台检测。"))
            return
        }

        if (hasFineLocationPermission()) {
            result.success(backgroundPermissionPayload())
            return
        }

        result.success(statusPayload("unavailable", "请先允许使用期间定位权限，再开启后台自动检测。"))
    }

    @SuppressLint("MissingPermission")
    private fun startMonitoring(result: MethodChannel.Result) {
        if (!isLocationEnabled()) {
            result.success(statusPayload("unavailable", "Android 定位服务未开启。"))
            return
        }

        if (!hasFineLocationPermission()) {
            result.success(statusPayload("unavailable", "请先允许使用期间定位权限，再启动后台自动检测。"))
            return
        }

        if (!hasBackgroundLocationPermission()) {
            result.success(backgroundPermissionPayload())
            return
        }

        val geofence = Geofence.Builder()
            .setRequestId(geofenceRequestId)
            .setCircularRegion(22.3193, 114.1694, 50000f)
            .setExpirationDuration(Geofence.NEVER_EXPIRE)
            .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER or Geofence.GEOFENCE_TRANSITION_EXIT)
            .build()

        val request = GeofencingRequest.Builder()
            .setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER)
            .addGeofence(geofence)
            .build()

        geofencingClient.addGeofences(request, geofencePendingIntent())
            .addOnSuccessListener {
                NativeGeofenceStore.setMonitoringStarted(this, true)
                result.success(statusPayload("running", "Android Geofencing API 已启动，等待系统 enter / exit 事件。"))
            }
            .addOnFailureListener { error ->
                result.success(statusPayload("unavailable", "Android Geofencing API 启动失败：${error.localizedMessage ?: "未知错误"}"))
            }
    }

    private fun stopMonitoring(result: MethodChannel.Result) {
        geofencingClient.removeGeofences(geofencePendingIntent())
            .addOnCompleteListener {
                NativeGeofenceStore.setMonitoringStarted(this, false)
                result.success(statusPayload("stopped", "Android 后台检测已停止。"))
            }
    }

    private fun statusPayload(
        forcedStatus: String? = null,
        forcedMessage: String? = null
    ): Map<String, Any?> {
        if (!isLocationEnabled()) {
            return withLastEvent(
                "status" to "unavailable",
                "message" to "Android 定位服务未开启。"
            )
        }

        if (!hasFineLocationPermission()) {
            return withLastEvent(
                "status" to "unavailable",
                "message" to "请先允许使用期间定位权限，再开启后台自动检测。"
            )
        }

        if (!hasBackgroundLocationPermission()) {
            return backgroundPermissionPayload()
        }

        if (forcedStatus != null && forcedMessage != null) {
            return withLastEvent("status" to forcedStatus, "message" to forcedMessage)
        }

        if (NativeGeofenceStore.isMonitoringStarted(this)) {
            return withLastEvent(
                "status" to "running",
                "message" to "Android Geofencing API 运行中，最近事件会在系统触发后显示。"
            )
        }

        return withLastEvent(
            "status" to "ready",
            "message" to "Android 后台检测通道已注册，可启动 Geofencing API。"
        )
    }

    private fun withLastEvent(vararg pairs: Pair<String, Any?>): Map<String, Any?> {
        val payload = pairs.toMap().toMutableMap()
        payload["lastEvent"] = NativeGeofenceStore.lastEvent(this)
        return payload
    }

    private fun hasRequiredLocationPermission(): Boolean {
        return hasFineLocationPermission() && hasBackgroundLocationPermission()
    }

    private fun hasFineLocationPermission(): Boolean {
        return hasPermission(Manifest.permission.ACCESS_FINE_LOCATION)
    }

    private fun hasBackgroundLocationPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return true
        }
        return hasPermission(Manifest.permission.ACCESS_BACKGROUND_LOCATION)
    }

    private fun backgroundPermissionPayload(): Map<String, Any?> {
        return withLastEvent(
            "status" to "needsBackgroundPermission",
            "message" to "Android 11 及以上需要前往系统设置，将位置信息改为“始终允许”，才能启用后台自动检测。"
        )
    }

    private fun hasPermission(permission: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true
        }
        return checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
    }

    private fun isLocationEnabled(): Boolean {
        val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        return locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
            locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
    }

    private fun geofencePendingIntent(): PendingIntent {
        val intent = Intent(this, GeofenceBroadcastReceiver::class.java)
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        return PendingIntent.getBroadcast(this, 1001, intent, flags)
    }
}
