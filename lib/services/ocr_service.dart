import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// OCR di perangkat (ML Kit). Gambar tidak dikirim ke server mana pun.
class OcrService {
  Future<String> read(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      return result.text;
    } finally {
      await recognizer.close();
    }
  }
}
