import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../services/share_service.dart';
import '../widgets/common.dart';
import '../widgets/companion_sheet.dart';
import 'result_screen.dart';
import 'scanning_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  final _share = ShareService();

  @override
  void initState() {
    super.initState();
    // Pintu masuk "Bagikan": gambar atau teks dari aplikasi lain.
    _share.listen(_handleShared);
    _share.initial().then((item) {
      if (item != null) _handleShared(item);
    });
  }

  void _handleShared(SharedItem item) {
    if (!mounted) return;
    _openScan(item.isImage
        ? ScanSource.image(item.value)
        : ScanSource.text(item.value));
  }

  void _openScan(ScanSource source) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScanningScreen(source: source)),
    );
  }

  Future<void> _pickFromGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x == null || !mounted) return;
    _openScan(ScanSource.image(x.path));
  }

  @override
  void dispose() {
    _share.dispose();
    super.dispose();
  }

  Future<void> _onNav(int i) async {
    final state = AppScope.of(context);
    if (i == 1) {
      await _pickFromGallery();
    } else if (i == 2) {
      await state.setSenior(!state.senior);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            state.senior ? 'Mode Lansia dinyalakan' : 'Mode Lansia dimatikan'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(subtitle: 'Beranda'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text('Cek Dulu', style: headStyle(22)),
          const SizedBox(height: 4),
          Text('Ragu dengan pesan? Bagikan tangkapan layarnya ke sini.',
              style: bodyStyle(14, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          _HeroCard(onPick: _pickFromGallery),
          const SizedBox(height: 20),
          _HistorySection(state: state),
          const SizedBox(height: 16),
          _SeniorToggle(state: state),
          const SizedBox(height: 12),
          _FamilyCard(state: state),
          const SizedBox(height: 12),
          const Footnote(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.senior ? 2 : 0,
        onDestinationSelected: _onNav,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.document_scanner_outlined), label: 'Pindai'),
          NavigationDestination(
              icon: Icon(Icons.accessibility_new), label: 'Mode Lansia'),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onPick});
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: AppColors.primaryContainer,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.health_and_safety,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Perlindungan Cepat',
                        style: headStyle(16,
                            weight: FontWeight.w600,
                            color: AppColors.onPrimaryContainer)),
                    Text('Kenali bujukan dan tautan mencurigakan',
                        style: bodyStyle(12,
                            weight: FontWeight.w500,
                            color: AppColors.onPrimaryContainer)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Bagikan tangkapan layar SMS, WhatsApp, atau bukti transfer yang '
            'mencurigakan. Gambar diproses di ponsel Anda.',
            style:
                bodyStyle(14, color: AppColors.onPrimaryContainer, height: 1.4),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Pilih dari galeri'),
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final items = state.history;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Riwayat Pemeriksaan',
                style: headStyle(18, weight: FontWeight.w600)),
            Text('${items.length} tersimpan',
                style: bodyStyle(12,
                    weight: FontWeight.w500, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          SectionCard(
            child: Text(
              'Belum ada pemeriksaan. Bagikan tangkapan layar ke Cek Dulu '
              'atau pilih dari galeri.',
              style: bodyStyle(14, color: AppColors.textSecondary, height: 1.4),
            ),
          )
        else
          for (final r in items.take(5)) ...[
            _HistoryTile(record: r),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record});
  final ScanRecord record;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ResultScreen(record: record)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: headStyle(16, weight: FontWeight.w600)),
                      Text(record.subtitle,
                          style: bodyStyle(14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(timeAgo(record.at),
                    style: bodyStyle(12,
                        weight: FontWeight.w500,
                        color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RiskChip(level: record.result.level),
                  ),
                ),
                Text('Rincian',
                    style: headStyle(14,
                        weight: FontWeight.w600,
                        color: const Color(0xFF2C6197))),
                const Icon(Icons.chevron_right,
                    size: 18, color: Color(0xFF2C6197)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeniorToggle extends StatelessWidget {
  const _SeniorToggle({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
                color: AppColors.primaryContainer, shape: BoxShape.circle),
            child:
                const Icon(Icons.elderly, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mode Lansia',
                    style: headStyle(16, weight: FontWeight.w600)),
                Text('Teks lebih besar, penjelasan suara, tombol sederhana',
                    style: bodyStyle(13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: state.senior, onChanged: state.setSenior),
        ],
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  const _FamilyCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final c = state.companion;
    return SectionCard(
      color: AppColors.surfaceLow,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.primaryContainer, shape: BoxShape.circle),
            child: const Icon(Icons.family_restroom,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pendamping Keluarga',
                    style: headStyle(14, weight: FontWeight.w600)),
                Text(
                  c == null
                      ? 'Pilih kontak terpercaya untuk ditanya'
                      : 'Kontak: ${c.name}',
                  style: bodyStyle(12,
                      weight: FontWeight.w500, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(72, 40),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            onPressed: () => showCompanionSheet(context),
            child: Text(c == null ? 'Atur' : 'Ubah'),
          ),
        ],
      ),
    );
  }
}
