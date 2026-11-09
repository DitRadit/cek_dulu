import 'package:flutter/services.dart';

/// Isi yang dibagikan dari aplikasi lain: gambar (path file) atau teks.
class SharedItem {
  const SharedItem({required this.isImage, required this.value});
  final bool isImage;
  final String value;
}

/// Jembatan ke MainActivity.kt lewat MethodChannel.
class ShareService {
  static const MethodChannel _channel = MethodChannel('cek_dulu/share');

  static SharedItem? _parse(Object? raw) {
    if (raw is! Map) return null;
    final type = raw['type'];
    final value = raw['value'];
    if (type is! String || value is! String || value.isEmpty) return null;
    return SharedItem(isImage: type == 'image', value: value);
  }

  /// Isi yang membuka aplikasi (aplikasi belum berjalan saat dibagikan).
  Future<SharedItem?> initial() async {
    try {
      return _parse(await _channel.invokeMethod<Object?>('getInitial'));
    } catch (_) {
      return null;
    }
  }

  /// Isi yang dibagikan saat aplikasi sudah terbuka.
  void listen(void Function(SharedItem item) onItem) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'shared') {
        final item = _parse(call.arguments);
        if (item != null) onItem(item);
      }
      return null;
    });
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
  }
}
