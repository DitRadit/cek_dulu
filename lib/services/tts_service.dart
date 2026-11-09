import 'package:flutter_tts/flutter_tts.dart';

/// Penjelasan lewat suara untuk Mode Lansia (bahasa Indonesia).
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    await _tts.setLanguage('id-ID');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    _ready = true;
  }

  Future<void> speak(String text) async {
    await _init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
