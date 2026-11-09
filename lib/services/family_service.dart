import 'package:url_launcher/url_launcher.dart';

import '../core/app_state.dart';
import '../core/constants.dart';
import '../engine/family_summary.dart';
import '../engine/models.dart';

/// Mengirim ringkasan termasker lewat WhatsApp. Pengguna tetap menekan
/// "kirim" sendiri di WhatsApp, jadi tidak ada pengiriman otomatis.
Future<bool> sendToFamily(RiskResult result, Companion? companion) async {
  final text = Uri.encodeComponent(buildFamilySummary(result));
  final base = companion == null
      ? 'https://wa.me/'
      : 'https://wa.me/${companion.phone}';
  return launchUrl(
    Uri.parse('$base?text=$text'),
    mode: LaunchMode.externalApplication,
  );
}

Future<bool> openReportChannel() {
  return launchUrl(Uri.parse(kIascUrl), mode: LaunchMode.externalApplication);
}
