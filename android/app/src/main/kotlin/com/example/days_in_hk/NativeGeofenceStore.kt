package com.example.days_in_hk

import android.content.Context

object NativeGeofenceStore {
    private const val preferencesName = "days_in_hk_native_geofence"
    private const val monitoringStartedKey = "monitoring_started"
    private const val transitionKey = "last_transition"
    private const val detectedAtKey = "last_detected_at"
    private const val latitudeKey = "last_latitude"
    private const val longitudeKey = "last_longitude"
    private const val accuracyKey = "last_accuracy"

    fun isMonitoringStarted(context: Context): Boolean {
        return preferences(context).getBoolean(monitoringStartedKey, false)
    }

    fun setMonitoringStarted(context: Context, started: Boolean) {
        preferences(context).edit().putBoolean(monitoringStartedKey, started).apply()
    }

    fun saveLastEvent(
        context: Context,
        transition: String,
        detectedAt: String,
        latitude: Double?,
        longitude: Double?,
        accuracyMeters: Double?,
    ) {
        val editor = preferences(context).edit()
            .putString(transitionKey, transition)
            .putString(detectedAtKey, detectedAt)

        if (latitude == null) {
            editor.remove(latitudeKey)
        } else {
            editor.putFloat(latitudeKey, latitude.toFloat())
        }

        if (longitude == null) {
            editor.remove(longitudeKey)
        } else {
            editor.putFloat(longitudeKey, longitude.toFloat())
        }

        if (accuracyMeters == null) {
            editor.remove(accuracyKey)
        } else {
            editor.putFloat(accuracyKey, accuracyMeters.toFloat())
        }

        editor.apply()
    }

    fun lastEvent(context: Context): Map<String, Any?>? {
        val prefs = preferences(context)
        val transition = prefs.getString(transitionKey, null) ?: return null
        val detectedAt = prefs.getString(detectedAtKey, null) ?: return null
        return mapOf(
            "transition" to transition,
            "detectedAt" to detectedAt,
            "source" to "android_geofencing_api",
            "latitude" to optionalFloat(prefs, latitudeKey),
            "longitude" to optionalFloat(prefs, longitudeKey),
            "accuracyMeters" to optionalFloat(prefs, accuracyKey),
        )
    }

    private fun preferences(context: Context) =
        context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)

    private fun optionalFloat(
        prefs: android.content.SharedPreferences,
        key: String,
    ): Double? {
        if (!prefs.contains(key)) {
            return null
        }
        return prefs.getFloat(key, 0f).toDouble()
    }
}
