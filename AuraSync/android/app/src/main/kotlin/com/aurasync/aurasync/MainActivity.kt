package com.aurasync.aurasync

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), SensorEventListener {
    private val CHANNEL = "aurasync/sensors"
    private var methodChannel: MethodChannel? = null
    
    private var sensorManager: SensorManager? = null
    private var lightSensor: Sensor? = null
    private var pressureSensor: Sensor? = null
    private var magneticSensor: Sensor? = null

    private var latestLight: Float? = null
    private var latestPressure: Float? = null
    private var latestMagnetic: Float? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        lightSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_LIGHT)
        pressureSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_PRESSURE)
        magneticSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startSensors" -> {
                    registerListeners()
                    result.success(null)
                }
                "stopSensors" -> {
                    unregisterListeners()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun registerListeners() {
        sensorManager?.let { sm ->
            lightSensor?.let { sm.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL) }
            pressureSensor?.let { sm.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL) }
            magneticSensor?.let { sm.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL) }
        }
    }

    private fun unregisterListeners() {
        sensorManager?.unregisterListener(this)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return
        
        when (event.sensor.type) {
            Sensor.TYPE_LIGHT -> {
                latestLight = event.values[0]
            }
            Sensor.TYPE_PRESSURE -> {
                latestPressure = event.values[0]
            }
            Sensor.TYPE_MAGNETIC_FIELD -> {
                val x = event.values[0]
                val y = event.values[1]
                val z = event.values[2]
                latestMagnetic = Math.sqrt((x * x + y * y + z * z).toDouble()).toFloat()
            }
        }

        val dataMap = mutableMapOf<String, Double>()
        latestLight?.let { dataMap["light"] = it.toDouble() }
        latestPressure?.let { dataMap["pressure"] = it.toDouble() }
        latestMagnetic?.let { dataMap["magnetometer"] = it.toDouble() }

        if (dataMap.isNotEmpty()) {
            runOnUiThread {
                methodChannel?.invokeMethod("onSensorChanged", dataMap)
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // No-op
    }

    override fun onPause() {
        super.onPause()
        unregisterListeners()
    }
}
