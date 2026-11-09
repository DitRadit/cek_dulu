import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';

/// Lembar pengaturan pendamping keluarga. Wajib persetujuan eksplisit.
Future<void> showCompanionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _CompanionSheet(),
  );
}

class _CompanionSheet extends StatefulWidget {
  const _CompanionSheet();

  @override
  State<_CompanionSheet> createState() => _CompanionSheetState();
}

class _CompanionSheetState extends State<_CompanionSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _consent = false;
  String? _error;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final c = AppScope.of(context).companion;
    if (c != null) {
      _name.text = c.name;
      _phone.text = '0${c.phone.substring(2)}';
      _consent = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final state = AppScope.of(context);
    final name = _name.text.trim();
    final phone = normalizePhone(_phone.text);
    if (name.isEmpty) {
      setState(() => _error = 'Isi nama pendamping.');
      return;
    }
    if (phone == null) {
      setState(
        () => _error = 'Nomor WhatsApp belum benar. Contoh: 0812 3456 7890',
      );
      return;
    }
    if (!_consent) {
      setState(() => _error = 'Centang persetujuan dulu.');
      return;
    }
    await state.setCompanion(Companion(name, phone));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _remove() async {
    await AppScope.of(context).setCompanion(null);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final hasCompanion = AppScope.of(context).companion != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + inset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pendamping Keluarga',
              style: headStyle(20, weight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Saat Anda menekan "Tanya keluarga", ringkasan yang sudah disamarkan '
              'dikirim lewat WhatsApp ke kontak ini. Isi pesan asli tidak ikut terkirim.',
              style: bodyStyle(14, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama pendamping',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor WhatsApp',
                hintText: '0812 3456 7890',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _consent,
              onChanged: (v) => setState(() => _consent = v ?? false),
              title: Text(
                'Saya setuju ringkasan yang sudah disamarkan dikirim ke kontak ini '
                'hanya saat saya menekan "Tanya keluarga".',
                style: bodyStyle(14, height: 1.35),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: bodyStyle(
                    13,
                    color: AppColors.riskHigh,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton(onPressed: _save, child: const Text('Simpan')),
            if (hasCompanion)
              TextButton(
                onPressed: _remove,
                child: const Text('Hapus pendamping'),
              ),
          ],
        ),
      ),
    );
  }
}
