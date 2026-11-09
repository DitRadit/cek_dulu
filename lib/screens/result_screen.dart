import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../engine/labels.dart';
import '../engine/models.dart';
import '../engine/sign_defs.dart';
import '../services/family_service.dart';
import '../services/tts_service.dart';
import '../widgets/common.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.record});
  final ScanRecord record;

  @override
  Widget build(BuildContext context) {
    final senior = AppScope.of(context).senior;
    return senior
        ? _SeniorResult(record: record)
        : _StandardResult(record: record);
  }
}

// ---------------------------------------------------------------------------
// Tampilan standar
// ---------------------------------------------------------------------------

class _StandardResult extends StatelessWidget {
  const _StandardResult({required this.record});
  final ScanRecord record;

  RiskResult get r => record.result;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final level = r.level;
    final showReport = level != RiskLevel.low;

    return Scaffold(
      appBar: AppBar(title: const AppTitle(subtitle: 'Hasil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _LevelBanner(level: level),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.help_outline, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Kenapa?',
                      style: headStyle(20, weight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(r.why, style: bodyStyle(16, height: 1.5)),
                if (_chips().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Tanda terdeteksi',
                    style: headStyle(
                      14,
                      weight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: _chips()),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.security,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Yang disarankan',
                      style: headStyle(20, weight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final s in r.steps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          adviceIcon(s.kind),
                          size: 22,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            s.text,
                            style: bodyStyle(16, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => sendToFamily(r, state.companion),
            icon: const Icon(Icons.diversity_1),
            label: const Text('Tanya keluarga'),
          ),
          if (showReport) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: openReportChannel,
              icon: const Icon(Icons.campaign_outlined),
              label: const Text('Lapor ke kanal resmi (IASC)'),
            ),
          ],
          const SizedBox(height: 4),
          TextButton(
            onPressed: () async {
              await state.markFine(record.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dicatat di ponsel Anda. Terima kasih.'),
                ),
              );
            },
            child: const Text('Ini bukan penipuan'),
          ),
          const Footnote(),
        ],
      ),
    );
  }

  List<Widget> _chips() {
    return [
      for (final a in r.maskedAccounts)
        InfoChip(icon: Icons.account_balance, text: 'Rekening: $a'),
      for (final id in r.signIds)
        if (id != 'rekening_disebut')
          InfoChip(
            icon: kindIcon(kSignDefs[id]!.kind),
            text: kSignDefs[id]!.label,
          ),
      for (final h in r.hosts.take(2))
        InfoChip(icon: Icons.link, text: 'Situs: $h'),
    ];
  }
}

class _LevelBanner extends StatelessWidget {
  const _LevelBanner({required this.level});
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    final c = levelColor(level);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: levelBg(level),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.withAlpha(90)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            child: Icon(levelIcon(level), color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  levelLabel(level),
                  style: headStyle(
                    level == RiskLevel.low ? 17 : 22,
                    color: c,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  levelSubtitle(level),
                  style: bodyStyle(14, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mode Lansia
// ---------------------------------------------------------------------------

class _SeniorResult extends StatefulWidget {
  const _SeniorResult({required this.record});
  final ScanRecord record;

  @override
  State<_SeniorResult> createState() => _SeniorResultState();
}

class _SeniorResultState extends State<_SeniorResult> {
  final _tts = TtsService();

  RiskResult get r => widget.record.result;

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  String get _headline {
    switch (r.level) {
      case RiskLevel.high:
        return 'HATI-HATI';
      case RiskLevel.medium:
        return 'PERIKSA DULU';
      case RiskLevel.low:
        return 'TIDAK ADA TANDA';
    }
  }

  String get _subline {
    switch (r.level) {
      case RiskLevel.high:
        return 'Ini kemungkinan besar penipuan';
      case RiskLevel.medium:
        return 'Ada tanda yang mencurigakan';
      case RiskLevel.low:
        return 'Tidak ditemukan tanda bahaya yang kami kenali';
    }
  }

  SignDef? get _top => r.signIds.isEmpty ? null : kSignDefs[r.signIds.first];

  String get _spoken {
    final t = _top;
    final body = t == null
        ? r.why
        : '${t.seniorLead}${t.seniorBold}${t.seniorTail} ${t.seniorDont}';
    return '$_headline. $_subline. $body';
  }

  Future<void> _askFamily() async {
    final state = AppScope.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mark_chat_read_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Pesan Siap Dikirim',
              textAlign: TextAlign.center,
              style: headStyle(24),
            ),
            const SizedBox(height: 8),
            Text(
              'Ringkasan pesan sudah disiapkan untuk dikirim ke WhatsApp keluarga Anda. '
              'Isi pesan asli tidak ikut terkirim.',
              textAlign: TextAlign.center,
              style: bodyStyle(18, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 64,
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  sendToFamily(r, state.companion);
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'Buka WhatsApp Sekarang',
                  textAlign: TextAlign.center,
                  style: headStyle(18, color: Colors.white),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Kembali',
                style: headStyle(18, weight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = levelColor(r.level);
    final t = _top;
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        appBar: AppBar(title: const AppTitle(subtitle: 'Mode Lansia')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Banner status.
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(levelIcon(r.level), color: Colors.white, size: 56),
                  const SizedBox(height: 8),
                  Text(
                    _headline,
                    textAlign: TextAlign.center,
                    style: headStyle(32, color: Colors.white, height: 1.25),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subline,
                    textAlign: TextAlign.center,
                    style: bodyStyle(
                      20,
                      weight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Pendamping.
            SectionCard(
              color: AppColors.primaryContainer,
              child: Row(
                children: [
                  const BrandMark(size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pendamping Cek Dulu',
                          style: headStyle(
                            18,
                            weight: FontWeight.w600,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'Kami mendampingi Anda membaca pesan ini dengan tenang.',
                          style: bodyStyle(
                            16,
                            color: AppColors.onPrimaryContainer,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Penjelasan.
            SectionCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (t != null)
                    Text.rich(
                      TextSpan(
                        style: bodyStyle(
                          22,
                          weight: FontWeight.w500,
                          height: 1.45,
                        ),
                        children: [
                          TextSpan(text: t.seniorLead),
                          TextSpan(
                            text: t.seniorBold,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(text: t.seniorTail),
                        ],
                      ),
                    )
                  else
                    Text(
                      r.why,
                      style: bodyStyle(
                        22,
                        weight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  if (t != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.riskHighBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '🚫 ${t.seniorDont}',
                        style: headStyle(
                          24,
                          color: AppColors.riskHigh,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 68,
              child: OutlinedButton.icon(
                onPressed: () => _tts.speak(_spoken),
                icon: const Icon(Icons.volume_up, size: 30),
                label: Text(
                  'Dengarkan Penjelasan',
                  style: headStyle(20, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 68,
              child: FilledButton.icon(
                onPressed: _askFamily,
                icon: const Icon(Icons.family_restroom, size: 30),
                label: Text(
                  'Tanya Keluarga',
                  style: headStyle(20, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Footnote(),
          ],
        ),
      ),
    );
  }
}
