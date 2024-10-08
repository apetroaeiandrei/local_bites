package com.kotsukotsu.local

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "flavor"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getFlavor") {
                result.success(BuildConfig.FLAVOR)
            } else {
                result.notImplemented()
            }
        }
    }
}
