import 'package:flutter_test/flutter_test.dart';
import 'package:cek_dulu/engine/family_summary.dart';
import 'package:cek_dulu/engine/models.dart';
import 'package:cek_dulu/engine/risk_engine.dart';
import 'package:cek_dulu/engine/sign_defs.dart';

const engine = RiskEngine();

const highCases = <String, String>{
  'hadiah':
      'Selamat! Anda memenangkan hadiah Rp 50 juta. Transfer biaya admin '
      'Rp 500.000 ke rekening BCA 1234-5678-90 HARI INI agar hadiah dicairkan.',
  'apk': 'Paket anda gagal dikirim. Lihat foto resi di file Resi_JNE.apk',
  'otp': 'Halo, kami dari BRI. Mohon kirimkan kode OTP yang Anda terima untuk verifikasi.',
  'keluarga':
      'Mah ini nomor baru aku ya. Tolong transfer dulu Rp 2.000.000 ke '
      'rekening 7654321098 BNI, nanti aku ganti.',
  'tautan_palsu':
      'OJK: Rekening Anda akan diblokir hari ini. Verifikasi di '
      'http://ojk-verifikasi.xyz/login',
};

const mediumCases = <String, String>{
  'kerja':
      'Info kerja part time, gaji Rp 300rb per hari, tanpa pengalaman. '
      'Hubungi wa.me/6281234567890',
};

const lowCases = <String, String>{
  'notifikasi_bank':
      'BCA: Transaksi transfer Rp 500.000 berhasil. JANGAN BERIKAN '
      'kode OTP/PIN Anda kepada siapa pun termasuk pihak BCA.',
  'kurir_biasa':
      'Paket Anda dengan resi JP1234567890 sedang dalam perjalanan dan '
      'akan tiba hari ini. Terima kasih telah memakai J&T.',
  'promo_resmi':
      'Promo 11.11 Shopee! Diskon hingga 50% hari ini. '
      'Cek di https://shopee.co.id/promo',
  'chat_biasa': 'Bu, nanti malam aku pulang jam 8 ya.',
  'otp_login':
      'Kode OTP telah dikirim ke nomor Anda. Masukkan kode OTP untuk masuk.',
};

void main() {
  group('risiko tinggi', () {
    highCases.forEach((name, text) {
      test(name, () {
        expect(engine.analyze(text).level, RiskLevel.high);
      });
    });
  });

  group('perlu hati-hati', () {
    mediumCases.forEach((name, text) {
      test(name, () {
        expect(engine.analyze(text).level, RiskLevel.medium);
      });
    });
  });

  group('tidak ditemukan tanda bahaya', () {
    lowCases.forEach((name, text) {
      test(name, () {
        expect(engine.analyze(text).level, RiskLevel.low);
      });
    });
  });

  test('permintaan OTP tidak salah dibaca sebagai permintaan transfer', () {
    final r = engine.analyze(highCases['otp']!);
    expect(r.signIds.contains('minta_otp'), isTrue);
    expect(r.signIds.contains('minta_transfer'), isFalse);
  });

  test('rekening disamarkan', () {
    final r = engine.analyze(highCases['hadiah']!);
    expect(r.maskedAccounts, ['1234-5678-xx']);
  });

  test('ringkasan keluarga tidak memuat isi pesan asli', () {
    final r = engine.analyze(highCases['hadiah']!);
    final s = buildFamilySummary(r);
    expect(s.contains('1234-5678-90'), isFalse);
    expect(s.contains('Rp 50 juta'), isFalse);
  });

  test('aturan penulisan: tidak ada kata aman atau pasti di teks UI', () {
    final banned = RegExp(r'\b(aman|pasti|safe)\b', caseSensitive: false);
    for (final d in kSignDefs.values) {
      for (final s in [
        d.label,
        d.title,
        d.explain,
        d.seniorLead,
        d.seniorBold,
        d.seniorTail,
        d.seniorDont,
      ]) {
        expect(banned.hasMatch(s), isFalse, reason: s);
      }
    }
    for (final text in [
      ...highCases.values,
      ...mediumCases.values,
      ...lowCases.values,
    ]) {
      final r = engine.analyze(text);
      expect(banned.hasMatch(r.why), isFalse, reason: r.why);
      for (final st in r.steps) {
        expect(banned.hasMatch(st.text), isFalse, reason: st.text);
      }
    }
  });
}
