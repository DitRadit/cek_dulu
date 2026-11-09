import 'package:flutter/material.dart';

import '../engine/models.dart';

/// Warna dari DESIGN.md (Stitch). Hijau utama #0F6E56.
class AppColors {
  static const primary = Color(0xFF0F6E56);
  static const primaryContainer = Color(0xFFE3F2EE);
  static const onPrimaryContainer = Color(0xFF002117);
  static const background = Color(0xFFF4F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFEDF4FF);
  static const riskHigh = Color(0xFFC0392B);
  static const riskHighBg = Color(0xFFFFDAD6);
  static const riskMedium = Color(0xFFE08A00);
  static const riskMediumBg = Color(0xFFFFF0D6);
  static const riskNeutral = Color(0xFF3B6EA5);
  static const riskNeutralBg = Color(0xFFDEE9F8);
  static const textPrimary = Color(0xFF1D2733);
  static const textSecondary = Color(0xFF5B6672);
  static const outline = Color(0xFFBEC9C3);
}

/// Judul, label, dan tombol memakai Montserrat.
TextStyle headStyle(
  double size, {
  FontWeight weight = FontWeight.w700,
  Color? color,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'Montserrat',
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    height: height,
  );
}

/// Isi teks memakai Plus Jakarta Sans (sesuai ekspor Stitch).
/// Font dibundel di assets/fonts (offline). Untuk Poppins, ganti file dan
/// nama family di pubspec.yaml serta di sini.
TextStyle bodyStyle(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    height: height,
  );
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    surface: AppColors.surface,
    error: AppColors.riskHigh,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'PlusJakartaSans',
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: headStyle(18, weight: FontWeight.w600),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: headStyle(16, weight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: headStyle(16, weight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        minimumSize: const Size.fromHeight(48),
        textStyle: headStyle(14, weight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(
        bodyStyle(12, weight: FontWeight.w500),
      ),
    ),
  );
}

Color levelColor(RiskLevel l) {
  switch (l) {
    case RiskLevel.high:
      return AppColors.riskHigh;
    case RiskLevel.medium:
      return AppColors.riskMedium;
    case RiskLevel.low:
      return AppColors.riskNeutral;
  }
}

Color levelBg(RiskLevel l) {
  switch (l) {
    case RiskLevel.high:
      return AppColors.riskHighBg;
    case RiskLevel.medium:
      return AppColors.riskMediumBg;
    case RiskLevel.low:
      return AppColors.riskNeutralBg;
  }
}

/// Selalu ikon + teks, tidak pernah warna saja. Level rendah memakai ikon
/// pencarian (bukan centang) supaya tidak terbaca sebagai jaminan.
IconData levelIcon(RiskLevel l) {
  switch (l) {
    case RiskLevel.high:
      return Icons.warning_rounded;
    case RiskLevel.medium:
      return Icons.info_rounded;
    case RiskLevel.low:
      return Icons.search_rounded;
  }
}

IconData kindIcon(SignKind k) {
  switch (k) {
    case SignKind.account:
      return Icons.account_balance;
    case SignKind.money:
      return Icons.payments_outlined;
    case SignKind.time:
      return Icons.schedule;
    case SignKind.key:
      return Icons.key_off_outlined;
    case SignKind.link:
      return Icons.link_off;
    case SignKind.app:
      return Icons.install_mobile;
    case SignKind.person:
      return Icons.person_search_outlined;
    case SignKind.work:
      return Icons.work_outline;
    case SignKind.invest:
      return Icons.trending_up;
    case SignKind.gift:
      return Icons.card_giftcard;
    case SignKind.threat:
      return Icons.report_outlined;
    case SignKind.courier:
      return Icons.local_shipping_outlined;
    case SignKind.call:
      return Icons.call_outlined;
  }
}

IconData adviceIcon(SignKind k) {
  switch (k) {
    case SignKind.money:
    case SignKind.app:
      return Icons.block;
    case SignKind.key:
      return Icons.key_off_outlined;
    case SignKind.link:
      return Icons.link_off;
    case SignKind.person:
    case SignKind.call:
      return Icons.call_outlined;
    default:
      return Icons.check_circle_outline;
  }
}
