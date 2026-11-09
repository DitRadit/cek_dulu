/// Model data untuk mesin penilaian risiko.
/// File ini murni Dart (tanpa Flutter) supaya mudah diuji.

enum RiskLevel { high, medium, low }

/// Jenis tanda, dipetakan ke ikon di lapisan UI.
enum SignKind {
  account,
  money,
  time,
  key,
  link,
  app,
  person,
  work,
  invest,
  gift,
  threat,
  courier,
  call,
}

/// Definisi satu tanda (aturan) yang bisa terdeteksi.
class SignDef {
  const SignDef({
    required this.id,
    required this.kind,
    required this.weight,
    required this.label,
    required this.title,
    required this.explain,
    required this.seniorLead,
    required this.seniorBold,
    required this.seniorTail,
    required this.seniorDont,
  });

  final String id;
  final SignKind kind;
  final int weight;

  /// Label singkat untuk chip, contoh: "Minta transfer uang".
  final String label;

  /// Judul riwayat, contoh: "Pesan hadiah atau undian".
  final String title;

  /// Frasa diawali kata kerja, dipakai menyusun kalimat "Kenapa?".
  final String explain;

  /// Kalimat Mode Lansia: [seniorLead] + [seniorBold] + [seniorTail].
  final String seniorLead;
  final String seniorBold;
  final String seniorTail;

  /// Larangan besar untuk Mode Lansia, contoh: "Jangan kirim uang."
  final String seniorDont;
}

class Entities {
  Entities({
    required this.accounts,
    required this.phones,
    required this.urls,
    required this.hosts,
    required this.orgs,
  });

  /// Hanya digit, tanpa pemisah.
  final List<String> accounts;
  final List<String> phones;
  final List<String> urls;
  final List<String> hosts;
  final List<String> orgs;
}

class Advice {
  const Advice(this.kind, this.text);
  final SignKind kind;
  final String text;
}

class RiskResult {
  RiskResult({
    required this.level,
    required this.score,
    required this.signIds,
    required this.why,
    required this.steps,
    required this.maskedAccounts,
    required this.maskedPhones,
    required this.hosts,
  });

  final RiskLevel level;
  final int score;
  final List<String> signIds;
  final String why;
  final List<Advice> steps;
  final List<String> maskedAccounts;
  final List<String> maskedPhones;
  final List<String> hosts;

  Map<String, dynamic> toJson() => {
    'level': level.name,
    'score': score,
    'signIds': signIds,
    'why': why,
    'steps': [
      for (final s in steps) {'k': s.kind.name, 't': s.text},
    ],
    'maskedAccounts': maskedAccounts,
    'maskedPhones': maskedPhones,
    'hosts': hosts,
  };

  factory RiskResult.fromJson(Map<String, dynamic> j) => RiskResult(
    level: RiskLevel.values.byName(j['level'] as String),
    score: j['score'] as int,
    signIds: List<String>.from(j['signIds'] as List),
    why: j['why'] as String,
    steps: [
      for (final s in (j['steps'] as List))
        Advice(
          SignKind.values.byName((s as Map)['k'] as String),
          s['t'] as String,
        ),
    ],
    maskedAccounts: List<String>.from(j['maskedAccounts'] as List),
    maskedPhones: List<String>.from(j['maskedPhones'] as List),
    hosts: List<String>.from(j['hosts'] as List),
  );
}
