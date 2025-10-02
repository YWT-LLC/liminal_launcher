package net.empathetech.liminal

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log

import androidx.annotation.NonNull

import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel

import java.io.ByteArrayOutputStream
import java.io.File

//* Main *//

class MainActivity : FlutterFragmentActivity() {
  private val METHOD_CHANNEL: String = "net.empathetech.liminal/query"
  private val EVENT_CHANNEL: String = "net.empathetech.liminal/app_events"

  private var appEventStreamHandler: AppEventStreamHandler? = null

  override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
    return FlutterActivityLaunchConfigs.BackgroundMode.transparent
  }

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    // MethodChannel (calls from Flutter to Android) config //

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "getApps" -> {
          try{
            result.success(getInstalledApps())
          } catch (e: Exception) {
            result.error("APPS_ERROR", "Could not retrieve installed apps", e.message)
          }
        }
        "launchApp" -> {
          try {
            val packageName: String? = call.argument<String>("packageName")

            if (packageName != null) {
              launchApp(packageName)
              result.success(true)
            } else {
              result.error("INVALID_PACKAGE", "null package name", null)
            }
          } catch (e: Exception) {
            result.error("LAUNCH_ERROR", "Could not launch app", e.message)
          }
        }
        "openSettings" -> {
          try {
            val packageName: String? = call.argument<String>("packageName")

            if (packageName != null) {
              openSettings(packageName)
              result.success(true)
            } else {
              result.error("INVALID_PACKAGE", "null package name", null)
            }
          } catch (e: Exception) {
            result.error("LAUNCH_ERROR", "Could not open settings", e.message)
          }
        }
        "deleteApp" -> {
          try {
            val packageName: String? = call.argument<String>("packageName")
            
            if (packageName != null) {
              deleteApp(packageName)
              result.success(true)
            } else {
              result.error("INVALID_PACKAGE", "null package name", null)
            }
          } catch (e: Exception) {
            result.error("DELETE_ERROR", "Could not uninstall app", e.message)
          }
        }
        else -> result.notImplemented() 
      }
    }

    // EventChannel (events from Android to Flutter) config //

    appEventStreamHandler = AppEventStreamHandler(applicationContext)
    EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(appEventStreamHandler)
  }

  // Main helpers //

  private fun getInstalledApps(): List<Map<String, Any?>> {
    val getIntent = Intent(Intent.ACTION_MAIN, null)
    getIntent.addCategory(Intent.CATEGORY_LAUNCHER)

    val appInfoList = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      packageManager.queryIntentActivities(getIntent, PackageManager.ResolveInfoFlags.of(0L))
    } else {
      @Suppress("DEPRECATION")
      packageManager.queryIntentActivities(getIntent, 0)
    }

    val apps = mutableListOf<Map<String, Any?>>()
    for (appInfo in appInfoList) {
      val app = mutableMapOf<String, Any?>()

      val packageName = appInfo.activityInfo.packageName
      val packageInfo: PackageInfo = packageManager.getPackageInfo(packageName, 0)
      val applicationInfo: ApplicationInfo = packageManager.getApplicationInfo(packageName, 0)

      app["package"] = packageName
      app["label"] = appInfo.loadLabel(packageManager).toString()
      app["icon"] = drawableToByteArray(appInfo.loadIcon(packageManager))
      
      val isSystemApp: Boolean = (applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
      app["removable"] = !isSystemApp

      app["installDate"] = packageInfo.firstInstallTime

      val apkPath = applicationInfo.publicSourceDir
      app["packageSize"] = File(apkPath).length()

      apps.add(app)
    }
    return apps
  }

  private fun launchApp(packageName: String) {
    val launchIntent: Intent? = packageManager.getLaunchIntentForPackage(packageName)
    if (launchIntent != null) startActivity(launchIntent)
  }

  private fun openSettings(packageName: String) {
    val infoIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
    infoIntent.data = Uri.fromParts("package", packageName, null)
    infoIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    startActivity(infoIntent)
  }

  private fun deleteApp(packageName: String) {
    val deleteIntent = Intent(Intent.ACTION_DELETE)
    deleteIntent.data = Uri.fromParts("package", packageName, null)
    deleteIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    startActivity(deleteIntent)
  }
}

//* Events *//
// Receiver //

class AppEventReceiver(private val eventSink: EventSink?) : BroadcastReceiver() {
  override fun onReceive(context: Context?, intent: Intent?) {
    if (intent == null) return

    val packageName = intent.data?.schemeSpecificPart
    if (packageName == null) return

    when (intent.action) {
      Intent.ACTION_PACKAGE_ADDED -> {
        val isUpdate = intent.getBooleanExtra(Intent.EXTRA_REPLACING, false)
        if (!isUpdate) {
          val appDetails = getAppDetails(context, packageName)
          if (appDetails != null) eventSink?.success(mapOf("eventType" to "installed", "appInfo" to appDetails))
        }
      }
      Intent.ACTION_PACKAGE_REMOVED -> {
        val isUpdate = intent.getBooleanExtra(Intent.EXTRA_REPLACING, false)
        if (!isUpdate) eventSink?.success(mapOf("eventType" to "uninstalled", "packageName" to packageName))
      }
    }
  }

  private fun getAppDetails(context: Context?, packageName: String): Map<String, Any?>? {
    if (context == null) return null
    val packageManager = context.packageManager

    try {
      val app = mutableMapOf<String, Any?>()

      val packageInfo: PackageInfo = packageManager.getPackageInfo(packageName, 0)
      val applicationInfo: ApplicationInfo = packageManager.getApplicationInfo(packageName, 0)

      app["package"] = packageName
      app["label"] = packageManager.getApplicationLabel(applicationInfo).toString()
      app["icon"] = drawableToByteArray(packageManager.getApplicationIcon(applicationInfo))

      val isSystemApp: Boolean = (applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
      app["removable"] = !isSystemApp

      app["installDate"] = packageInfo.firstInstallTime

      val apkPath = applicationInfo.publicSourceDir
      app["packageSize"] = File(apkPath).length()

      return app
    } catch (e: PackageManager.NameNotFoundException) {
      Log.e("AppDetails", "App with package $packageName not found.", e)
      return null
    }
  }
}

// Stream handler //

class AppEventStreamHandler(private val context: Context) : EventChannel.StreamHandler {
  private var appEventReceiver: AppEventReceiver? = null

  override fun onListen(arguments: Any?, events: EventSink?) {
    if (events == null) return

    appEventReceiver = AppEventReceiver(events)
    val intentFilter = IntentFilter().apply {
      addAction(Intent.ACTION_PACKAGE_ADDED)
      addAction(Intent.ACTION_PACKAGE_REMOVED)
      addDataScheme("package")
    }
    
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      context.registerReceiver(appEventReceiver, intentFilter, Context.RECEIVER_EXPORTED)
    } else {
      @Suppress("DEPRECATION")
      context.registerReceiver(appEventReceiver, intentFilter)
    }
  }

  override fun onCancel(arguments: Any?) {
    if (appEventReceiver != null) {
      context.unregisterReceiver(appEventReceiver)
      appEventReceiver = null
    }
  }
}

//* Shared *//

private fun drawableToByteArray(drawable: Drawable?): ByteArray? {
  if (drawable == null) return null
  
  if (drawable is BitmapDrawable) {
    val bitmap: Bitmap = drawable.bitmap
    val stream = ByteArrayOutputStream()

    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
    return stream.toByteArray()
  }

  val bitmap = Bitmap.createBitmap(
    drawable.intrinsicWidth,
    drawable.intrinsicHeight,
    Bitmap.Config.ARGB_8888
  )

  val canvas = Canvas(bitmap)
  drawable.setBounds(0, 0, canvas.width, canvas.height)
  drawable.draw(canvas)

  val stream = ByteArrayOutputStream()
  bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
  return stream.toByteArray()
}