import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../engine/labels.dart';
import '../engine/models.dart';

/// Kartu putih dengan sudut membulat (16 sampai 20 dp, sesuai DESIGN.md).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1D2733),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Logo kecil: perisai hijau dalam lingkaran.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.shield, color: Colors.white, size: size * 0.6),
    );
  }
}

/// Judul aplikasi + nama layar, dipakai di AppBar semua layar.
class AppTitle extends StatelessWidget {
  const AppTitle({super.key, required this.subtitle});
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BrandMark(),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cek Dulu',
              style: headStyle(
                18,
                weight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              subtitle,
              style: bodyStyle(
                12,
                weight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Chip tingkat risiko: selalu ikon + teks.
class RiskChip extends StatelessWidget {
  const RiskChip({super.key, required this.level});
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: levelBg(level),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(levelIcon(level), size: 16, color: levelColor(level)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              levelLabel(level),
              style: headStyle(
                13,
                weight: FontWeight.w600,
                color: levelColor(level),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text, style: bodyStyle(14, weight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class Footnote extends StatelessWidget {
  const Footnote({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        kFootnote,
        textAlign: TextAlign.center,
        style: bodyStyle(
          12,
          weight: FontWeight.w500,
          color: AppColors.textSecondary,
        ).copyWith(fontStyle: FontStyle.italic),
      ),
    );
  }
}
