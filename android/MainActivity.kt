package bc.lekpad.balochi

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.view.inputmethod.InputMethodManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "bc.lekpad.balochi/settings"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Fixed: Use dartExecutor instead of dartInterface for modern Flutter SDK compatibility!
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openKeyboardSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_INPUT_METHOD_SETTINGS)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot open keyboard settings", e.localizedMessage)
                    }
                }
                "openKeyboardPicker" -> {
                    try {
                        val im = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                        im.showInputMethodPicker()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot open keyboard picker", e.localizedMessage)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
