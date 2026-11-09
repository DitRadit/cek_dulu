import 'entity_extractor.dart';
import 'models.dart';
import 'sign_defs.dart';

/// Mesin penilaian risiko berbasis aturan. Berjalan sepenuhnya di perangkat.
///
/// Prinsip: hanya memberi indikasi, tidak pernah menyatakan sesuatu "aman".
/// Hasil rendah berarti "tidak ditemukan tanda bahaya yang kami kenali".
class RiskEngine {
  const RiskEngine();

  static final RegExp _moneyReq = RegExp(
    r'(?:transfer|kirim|setor|bayar|tf)(?:kan)?\s+(?:\w+\s+){0,4}?(?:dulu|terlebih\s+dahulu|lebih\s+dulu|duluan)'
    r'|biaya\s+(?:admin|administrasi|pengiriman|pajak|klaim|aktivasi|verifikasi|asuransi|pendaftaran|pelatihan)'
    r'|pajak\s+hadiah'
    r'|\b(?:deposit|modal\s+awal|saldo\s+awal)\b'
    r'|(?:tolong|mohon|harap|silakan|segera|minta)\s+(?:\w+\s+){0,3}?(?:transfer|setor|bayar|kirim(?:kan)?\s+(?:uang|dana|saldo|pulsa|rp))',
  );

  static final RegExp _prize = RegExp(
    r'selamat.{0,60}(?:menang|terpilih|mendapat|berhak)'
    r'|\banda\s+(?:me)?menang'
    r'|\bundian\b|\bpemenang\b'
    r'|hadiah\s+(?:utama|uang|mobil|motor|rp)'
    r'|\bhadiah\b.{0,40}\brp',
  );

  static final RegExp _urgency = RegExp(
    r'hari\s+ini|segera|dalam\s+\d+\s*(?:jam|menit|hari)|batas\s+waktu|paling\s+lambat'
    r'|sekarang\s+juga|buruan|terakhir|kedaluwarsa|kadaluarsa|hangus'
    r'|akan\s+(?:di)?(?:tutup|blokir|bekukan)|jika\s+tidak',
  );

  static final RegExp _otpWord = RegExp(
    r'\botp\b|kode\s+(?:verifikasi|rahasia|sms|keamanan)|\bpin\b|password|kata\s+sandi|\bcvv\b',
  );
  static final RegExp _otpVerb = RegExp(
    r'\b(?:kirim(?:kan)?|berikan|sebutkan|bagikan|balas|infokan|foto)\b',
  );
  static final RegExp _otpNeg = RegExp(
    r'jangan|tidak\s+(?:akan\s+)?(?:pernah\s+)?(?:meminta|minta)|waspada|rahasiakan|hindari|bukan\s+kepada',
  );

  static final RegExp _apk = RegExp(r'\bapk\b|\.apk');

  static final RegExp _petugasWord = RegExp(
    r'petugas|bea\s+cukai|penyidik|pengadilan',
  );
  static final RegExp _scare = RegExp(
    r'(?:anda|rekening|nomor|kartu|akun)\b.{0,50}(?:terkait|terlibat|tersangka|diblokir|dibekukan'
    r'|akan\s+(?:di)?(?:blokir|tutup|bekukan)|pencucian\s+uang|narkoba|kasus|pidana|denda|tilang)',
  );

  static final RegExp _family = RegExp(
    r'(?:ini|nomor)\s+(?:\w+\s+){0,2}?(?:baru|ganti)|ganti\s+nomor'
    r'|nomor\s+(?:lama\s+)?(?:hilang|rusak|diblokir)'
    r'|\b(?:mah|mama|mamah|pah|papa|papah|bu|ibu|pak|bapak|bunda|ayah|kak|mas|mbak)\b.{0,60}\b(?:pinjam|pinjem|transfer|bayarin|talangin)',
  );

  static final RegExp _job = RegExp(
    r'kerja\s+(?:paruh\s+waktu|sampingan|online|dari\s+rumah)|part\s*-?\s*time'
    r'|gaji\s+(?:rp\.?\s*)?(?:harian|per\s+hari|\d)'
    r'|rp\.?\s*[\d.,]+\s*(?:rb|ribu|k|jt|juta)?\s*(?:per|\/)\s*hari'
    r'|tanpa\s+(?:pengalaman|modal|interview|syarat)'
    r'|like\s+(?:dan|&)\s+(?:subscribe|follow)|tugas\s+(?:harian|like)|\bkomisi\b',
  );

  static final RegExp _invest = RegExp(
    r'(?:dijamin|garansi).{0,20}(?:untung|profit|cuan|return|balik\s+modal)'
    r'|(?:untung|profit|cuan|keuntungan|return).{0,30}(?:\d{2,}\s*%|harian|per\s+hari|mingguan)'
    r'|robot\s+trading|investasi\s+(?:bodong|cepat)',
  );

  static final RegExp _threat = RegExp(
    r'(?:data|kontak).{0,25}(?:disebar|sebar|dikirim\s+ke)|penagih|debt\s*collector|\bpinjol\b'
    r'|akan\s+(?:kami\s+)?(?:laporkan|sebarkan)',
  );

  static final RegExp _courier = RegExp(
    r'paket\s+anda|\bresi\b|gagal\s+(?:di)?kirim|alamat\s+(?:anda\s+)?(?:tidak\s+lengkap|salah)|konfirmasi\s+alamat|\bkurir\b',
  );

  RiskResult analyze(String rawText) {
    final t = rawText.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    final ent = extractEntities(t);
    final orgs = findOrgs(t);
    final hit = <String>{};

    bool has(RegExp r) => r.hasMatch(t);

    // Permintaan uang.
    final money = has(_moneyReq);
    if (money) hit.add('minta_transfer');
    if (has(_prize)) hit.add('hadiah');
    if (has(_urgency)) hit.add('tekanan_waktu');

    // OTP: periksa per kalimat supaya peringatan resmi
    // ("jangan berikan kode OTP") tidak dianggap permintaan.
    final sentences = t.split(RegExp(r'[!?\n]+|\.(?=\s|$)'));
    for (final s in sentences) {
      if (_otpWord.hasMatch(s) &&
          _otpVerb.hasMatch(s) &&
          !_otpNeg.hasMatch(s)) {
        hit.add('minta_otp');
        break;
      }
    }

    final apk = has(_apk);
    if (apk) hit.add('apk');

    // Tautan.
    var offHost = false;
    for (final h in ent.hosts) {
      if (kShorteners.contains(h)) hit.add('tautan_pendek');
      if (kChatHosts.contains(h)) hit.add('ajakan_chat');
      final dot = h.lastIndexOf('.');
      if (dot >= 0 && kOddTlds.contains(h.substring(dot + 1))) {
        hit.add('alamat_janggal');
      }
      if (!isOfficialHost(h, kOrgs)) offHost = true;
    }
    if (orgs.isNotEmpty && ent.hosts.isNotEmpty) {
      final unofficial = ent.hosts.any((h) => !isOfficialHost(h, orgs));
      if (unofficial) hit.add('tautan_tidak_resmi');
    }

    // Mengaku petugas.
    final govOrBank = orgs.any(
      (o) => o.cat == OrgCategory.gov || o.cat == OrgCategory.bank,
    );
    if ((govOrBank || has(_petugasWord)) && has(_scare)) {
      hit.add('mengaku_petugas');
    }

    if (has(_family)) hit.add('nomor_baru');
    final job = has(_job);
    if (job) hit.add('tawaran_kerja');
    if (has(_invest)) hit.add('untung_besar');
    if (has(_threat)) hit.add('ancaman_data');

    // Pesan paket baru dianggap janggal bila disertai tautan tak resmi atau APK.
    final courierCtx =
        has(_courier) || orgs.any((o) => o.cat == OrgCategory.courier);
    if (courierCtx && (apk || offHost)) hit.add('paket_tautan');

    // Rekening hanya dihitung bila ada permintaan uang di sekitarnya.
    final moneyContext = hit.any(
      (id) => const {
        'minta_transfer',
        'hadiah',
        'nomor_baru',
        'tawaran_kerja',
        'untung_besar',
      }.contains(id),
    );
    final accountsFlagged = ent.accounts.isNotEmpty && moneyContext;
    if (accountsFlagged) hit.add('rekening_disebut');

    // Skor.
    var score = 0;
    for (final id in hit) {
      score += kSignDefs[id]!.weight;
    }
    var floor = 0;
    void bump(bool cond, int v) {
      if (cond && v > floor) floor = v;
    }

    bump(hit.contains('hadiah') && hit.contains('minta_transfer'), 75);
    bump(apk, 70);
    bump(hit.contains('minta_otp'), 60);
    bump(hit.contains('nomor_baru') && hit.contains('minta_transfer'), 70);
    bump(hit.contains('tawaran_kerja') && hit.contains('minta_transfer'), 65);
    bump(
      hit.contains('mengaku_petugas') &&
          (hit.contains('minta_transfer') || accountsFlagged),
      65,
    );
    if (floor > score) score = floor;
    if (score > 100) score = 100;

    final level = score >= 60
        ? RiskLevel.high
        : (score >= 30 ? RiskLevel.medium : RiskLevel.low);

    final ordered = hit.toList()
      ..sort((a, b) => kSignDefs[b]!.weight.compareTo(kSignDefs[a]!.weight));

    return RiskResult(
      level: level,
      score: score,
      signIds: ordered,
      why: _buildWhy(level, ordered),
      steps: _buildSteps(level, hit, accountsFlagged),
      maskedAccounts: accountsFlagged
          ? [for (final a in ent.accounts) maskAccount(a)]
          : [],
      maskedPhones: [for (final p in ent.phones) maskPhone(p)],
      hosts: ent.hosts,
    );
  }

  String _buildWhy(RiskLevel level, List<String> ordered) {
    if (level == RiskLevel.low) {
      return 'Kami tidak menemukan tanda bahaya yang kami kenali. '
          'Ini bukan jaminan, jadi tetap periksa pengirimnya lewat kanal resmi '
          'sebelum mengirim uang atau data.';
    }
    final top = [for (final id in ordered.take(3)) kSignDefs[id]!.explain];
    final joined = top.length == 1
        ? top.first
        : '${top.sublist(0, top.length - 1).join(', ')}, dan ${top.last}';
    if (level == RiskLevel.high) {
      return 'Pesan ini $joined.';
    }
    return 'Ada indikasi bahwa pesan ini $joined.';
  }

  List<Advice> _buildSteps(RiskLevel level, Set<String> hit, bool accounts) {
    if (level == RiskLevel.low) {
      return const [
        Advice(
          SignKind.call,
          'Tetap periksa pengirim lewat kanal resmi sebelum mengirim uang atau data',
        ),
        Advice(
          SignKind.money,
          'Jika ada bukti transfer, cek mutasi rekening Anda sendiri',
        ),
      ];
    }
    final steps = <Advice>[];
    if (hit.contains('minta_transfer') || accounts || hit.contains('hadiah')) {
      steps.add(
        const Advice(
          SignKind.money,
          'Jangan transfer uang ke rekening tersebut',
        ),
      );
    }
    if (hit.contains('apk')) {
      steps.add(
        const Advice(
          SignKind.app,
          'Jangan pasang file aplikasi (APK) dari pesan ini',
        ),
      );
    }
    if (hit.any(
      (id) => const {
        'tautan_pendek',
        'alamat_janggal',
        'tautan_tidak_resmi',
        'paket_tautan',
      }.contains(id),
    )) {
      steps.add(const Advice(SignKind.link, 'Jangan buka tautan di pesan ini'));
    }
    if (hit.contains('nomor_baru')) {
      steps.add(
        const Advice(
          SignKind.person,
          'Telepon keluarga Anda di nomor lama untuk memastikan',
        ),
      );
    }
    steps.add(
      const Advice(SignKind.key, 'Jangan berikan kode OTP atau data pribadi'),
    );
    steps.add(
      const Advice(
        SignKind.call,
        'Hubungi pihak resmi lewat kanal resminya, bukan lewat nomor di pesan',
      ),
    );
    return steps.take(5).toList();
  }
}
