import 'models.dart';

/// Label tingkat risiko. Tidak ada label yang menyatakan "aman".
String levelLabel(RiskLevel l) {
  switch (l) {
    case RiskLevel.high:
      return 'Risiko Tinggi';
    case RiskLevel.medium:
      return 'Perlu Hati-hati';
    case RiskLevel.low:
      return 'Tidak ditemukan tanda bahaya yang kami kenali';
  }
}

/// Kalimat pendek di bawah label pada layar hasil.
String levelSubtitle(RiskLevel l) {
  switch (l) {
    case RiskLevel.high:
      return 'Ditemukan beberapa tanda penipuan yang kami kenali';
    case RiskLevel.medium:
      return 'Ada tanda yang perlu Anda periksa dulu';
    case RiskLevel.low:
      return 'Tetap periksa pengirim lewat kanal resmi';
  }
}

const String kFootnote = 'Hasil ini indikasi, bukan putusan.';
