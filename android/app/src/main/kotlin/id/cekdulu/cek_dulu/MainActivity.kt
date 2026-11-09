package id.cekdulu.cek_dulu

import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Menerima menu "Bagikan" (gambar atau teks) dan meneruskannya ke Dart
 * lewat MethodChannel "cek_dulu/share". Gambar disalin ke cache aplikasi
 * supaya Dart bisa membacanya sebagai file biasa.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pending: Map<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "cek_dulu/share")
        ch.setMethodCallHandler { call, result ->
            if (call.method == "getInitial") {
                result.success(pending)
                pending = null
            } else {
                result.notImplemented()
            }
        }
        channel = ch
        pending = parse(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val data = parse(intent) ?: return
        channel?.invokeMethod("shared", data)
    }

    private fun parse(i: Intent?): Map<String, String>? {
        if (i == null || i.action != Intent.ACTION_SEND) return null
        val type = i.type ?: return null
        // Tandai sudah diproses supaya tidak terbaca ulang saat aktivitas dibuat ulang.
        i.action = null

        if (type.startsWith("image/")) {
            val uri: Uri? = if (Build.VERSION.SDK_INT >= 33) {
                i.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                i.getParcelableExtra(Intent.EXTRA_STREAM)
            }
            if (uri == null) return null
            return try {
                val out = File(cacheDir, "shared_${System.currentTimeMillis()}.img")
                contentResolver.openInputStream(uri)?.use { input ->
                    out.outputStream().use { input.copyTo(it) }
                } ?: return null
                mapOf("type" to "image", "value" to out.absolutePath)
            } catch (e: Exception) {
                null
            }
        }
        if (type == "text/plain") {
            val text = i.getStringExtra(Intent.EXTRA_TEXT) ?: return null
            return mapOf("type" to "text", "value" to text)
        }
        return null
    }
}