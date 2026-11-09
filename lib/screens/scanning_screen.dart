import 'dart:io';

import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../engine/risk_engine.dart';
import '../services/ocr_service.dart';
import '../widgets/common.dart';
import 'result_screen.dart';

/// Sumber pemeriksaan: gambar (lewat OCR) atau teks yang dibagikan langsung.
class ScanSource {
  const ScanSource.image(String path) : imagePath = path, text = null;
  const ScanSource.text(String value) : text = value, imagePath = null;

  final String? imagePath;
  final String? text;
}

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key, required this.source});
  final ScanSource source;

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final state = AppScope.of(context);
    final started = DateTime.now();
    String text;
    try {
      text =
          widget.source.text ??
          await OcrService().read(widget.source.imagePath!);
    } catch (_) {
      _fail('Gambar ini tidak bisa dibaca. Coba pilih tangkapan layar lain.');
      return;
    }
    if (_cancelled || !mounted) return;
    if (text.trim().length < 8) {
      _fail(
        'Teks pada gambar sulit dibaca. Coba tangkapan layar yang lebih jelas.',
      );
      return;
    }

    final result = const RiskEngine().analyze(text);
    final record = ScanRecord(
      id: started.microsecondsSinceEpoch.toString(),
      at: DateTime.now(),
      result: result,
    );
    await state.addRecord(record);

    // Beri jeda singkat supaya layar tidak berkedip pada pemeriksaan cepat.
    final elapsed = DateTime.now().difference(started);
    const minShow = Duration(milliseconds: 1200);
    if (elapsed < minShow) await Future<void>.delayed(minShow - elapsed);
    if (_cancelled || !mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultScreen(record: record)),
    );
  }

  void _fail(String message) {
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.source.imagePath;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _cancelled = true;
      },
      child: Scaffold(
        appBar: AppBar(title: const AppTitle(subtitle: 'Memeriksa')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (imagePath != null)
                  Container(
                    height: 190,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(imagePath), fit: BoxFit.cover),
                        Positioned(
                          left: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xCC1D2733),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Tangkapan layar',
                              style: bodyStyle(
                                12,
                                weight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                const SizedBox(
                  width: 96,
                  height: 96,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text('Sedang memeriksa…', style: headStyle(22)),
                const SizedBox(height: 8),
                Text(
                  'Meneliti susunan kata dan tanda yang mencurigakan.',
                  textAlign: TextAlign.center,
                  style: bodyStyle(14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                SectionCard(
                  color: AppColors.primaryContainer,
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Privasi On-Device',
                              style: headStyle(
                                14,
                                weight: FontWeight.w600,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              'Gambar diproses di ponsel Anda dan tidak dikirim ke server.',
                              style: bodyStyle(
                                13,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Batal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
