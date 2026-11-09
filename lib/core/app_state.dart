import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../engine/models.dart';
import '../engine/sign_defs.dart';

/// Satu entri riwayat. Tidak menyimpan gambar maupun teks asli.
class ScanRecord {
  ScanRecord({
    required this.id,
    required this.at,
    required this.result,
    this.userSaysFine = false,
  });

  final String id;
  final DateTime at;
  final RiskResult result;
  bool userSaysFine;

  String get title {
    if (result.level == RiskLevel.low || result.signIds.isEmpty) {
      return 'Pesan tanpa tanda bahaya yang dikenali';
    }
    return kSignDefs[result.signIds.first]!.title;
  }

  String get subtitle {
    if (result.signIds.length >= 2) {
      return kSignDefs[result.signIds[1]]!.label;
    }
    if (result.signIds.length == 1)
      return kSignDefs[result.signIds.first]!.label;
    return 'Tidak ada tanda yang kami kenali';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'at': at.toIso8601String(),
    'fine': userSaysFine,
    'result': result.toJson(),
  };

  factory ScanRecord.fromJson(Map<String, dynamic> j) => ScanRecord(
    id: j['id'] as String,
    at: DateTime.parse(j['at'] as String),
    userSaysFine: (j['fine'] as bool?) ?? false,
    result: RiskResult.fromJson(Map<String, dynamic>.from(j['result'] as Map)),
  );
}

/// Pendamping keluarga. Disimpan hanya di ponsel, dengan persetujuan.
class Companion {
  const Companion(this.name, this.phone);

  final String name;

  /// Format internasional tanpa plus, contoh: 6281234567890.
  final String phone;

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};
  factory Companion.fromJson(Map<String, dynamic> j) =>
      Companion(j['name'] as String, j['phone'] as String);
}

/// Mengubah 0812... atau +62812... menjadi 62812... Mengembalikan null bila
/// bentuknya tidak masuk akal.
String? normalizePhone(String input) {
  var d = input.replaceAll(RegExp(r'\D'), '');
  if (d.startsWith('0')) d = '62${d.substring(1)}';
  if (!d.startsWith('62')) return null;
  if (d.length < 10 || d.length > 15) return null;
  return d;
}

class AppState extends ChangeNotifier {
  static const _kHistory = 'history_v1';
  static const _kSenior = 'senior_v1';
  static const _kCompanion = 'companion_v1';
  static const _maxHistory = 30;

  bool senior = false;
  List<ScanRecord> history = [];
  Companion? companion;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    senior = p.getBool(_kSenior) ?? false;
    final h = p.getString(_kHistory);
    if (h != null) {
      try {
        history = [
          for (final e in jsonDecode(h) as List)
            ScanRecord.fromJson(Map<String, dynamic>.from(e as Map)),
        ];
      } catch (_) {
        history = [];
      }
    }
    final c = p.getString(_kCompanion);
    if (c != null) {
      try {
        companion = Companion.fromJson(
          Map<String, dynamic>.from(jsonDecode(c) as Map),
        );
      } catch (_) {
        companion = null;
      }
    }
  }

  Future<void> _saveHistory() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _kHistory,
      jsonEncode([for (final r in history) r.toJson()]),
    );
  }

  Future<void> addRecord(ScanRecord r) async {
    history.insert(0, r);
    if (history.length > _maxHistory) {
      history = history.sublist(0, _maxHistory);
    }
    notifyListeners();
    await _saveHistory();
  }

  Future<void> markFine(String id) async {
    for (final r in history) {
      if (r.id == id) r.userSaysFine = true;
    }
    notifyListeners();
    await _saveHistory();
  }

  Future<void> setSenior(bool v) async {
    senior = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSenior, v);
  }

  Future<void> setCompanion(Companion? c) async {
    companion = c;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    if (c == null) {
      await p.remove(_kCompanion);
    } else {
      await p.setString(_kCompanion, jsonEncode(c.toJson()));
    }
  }

  Future<void> clearHistory() async {
    history = [];
    notifyListeners();
    await _saveHistory();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(s != null, 'AppScope tidak ditemukan');
    return s!.notifier!;
  }
}

String timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'baru saja';
  if (d.inMinutes < 60) return '${d.inMinutes} mnt lalu';
  if (d.inHours < 24) return '${d.inHours} jam lalu';
  if (d.inDays == 1) return 'Kemarin';
  return '${d.inDays} hari lalu';
}
