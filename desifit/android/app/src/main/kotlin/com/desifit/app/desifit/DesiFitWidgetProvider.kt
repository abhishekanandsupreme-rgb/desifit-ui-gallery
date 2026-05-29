package com.desifit.app.desifit

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlin.math.max

class DesiFitWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)

        // Read string representations of values to avoid typecasting errors
        val sattuStreakStr = widgetData.getString("sattuStreak", "0") ?: "0"
        val proteinHitStr = widgetData.getString("proteinHit", "0.0") ?: "0.0"
        val proteinGoalStr = widgetData.getString("proteinGoal", "60.0") ?: "60.0"
        val caloriesConsumedStr = widgetData.getString("caloriesConsumed", "0.0") ?: "0.0"
        val caloriesTargetStr = widgetData.getString("caloriesTarget", "2000.0") ?: "2000.0"

        val sattuStreak = sattuStreakStr.toIntOrNull() ?: 0
        val proteinHit = proteinHitStr.toDoubleOrNull() ?: 0.0
        val proteinGoal = proteinGoalStr.toDoubleOrNull() ?: 60.0
        val caloriesConsumed = caloriesConsumedStr.toDoubleOrNull() ?: 0.0
        val caloriesTarget = caloriesTargetStr.toDoubleOrNull() ?: 2000.0

        val remainingCalories = max(0.0, caloriesTarget - caloriesConsumed)

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // Update text content
            views.setTextViewText(R.id.widget_streak_value, "$sattuStreak ${if (sattuStreak == 1) "Day" else "Days"}")
            views.setTextViewText(R.id.widget_calories_value, "${remainingCalories.toInt()} kcal")
            views.setTextViewText(R.id.widget_protein_value, "${proteinHit.toInt()}g / ${proteinGoal.toInt()}g")

            // Tap layout to open main activity (launch Flutter application)
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            // Use Immutable PendingIntent with FLAG_UPDATE_CURRENT
            val pendingIntent = PendingIntent.getActivity(
                context, 
                0, 
                intent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
