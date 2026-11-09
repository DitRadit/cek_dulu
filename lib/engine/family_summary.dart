import 'labels.dart';
import 'models.dart';
import 'sign_defs.dart';

/// Ringkasan untuk pendamping keluarga.
///
/// Sengaja tidak memuat isi pesan asli, nama, atau gambar. Hanya tingkat
/// risiko, tanda yang terdeteksi, dan entitas yang sudah disamarkan.
String buildFamilySummary(RiskResult r) {
  final b = StringBuffer();
  b.writeln('Halo, saya memakai aplikasi Cek Dulu.');
  b.writeln('Saya menerima pesan yang hasilnya: ${levelLabel(r.level)}.');
  if (r.signIds.isNotEmpty) {
    b.writeln('Tanda yang terdeteksi:');
    for (final id in r.signIds.take(4)) {
      b.writeln('- ${kSignDefs[id]!.label}');
    }
  }
  if (r.maskedAccounts.isNotEmpty) {
    b.writeln('Rekening (disamarkan): ${r.maskedAccounts.join(', ')}');
  }
  if (r.hosts.isNotEmpty) {
    b.writeln('Situs yang disebut: ${r.hosts.take(2).join(', ')}');
  }
  b.writeln('Mohon telepon saya sebelum saya mengirim uang atau data apa pun.');
  b.write(kFootnote);
  return b.toString();
}
