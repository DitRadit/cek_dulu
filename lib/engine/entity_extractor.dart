import 'models.dart';

enum OrgCategory { bank, wallet, gov, courier, market, telco }

class OrgInfo {
  const OrgInfo(this.name, this.cat, this.pattern, this.domains);
  final String name;
  final OrgCategory cat;
  final String pattern;
  final List<String> domains;
}

/// Daftar kecil untuk demo. Perluas lewat pembaruan aturan berkala.
/// Domain resmi harus diverifikasi ulang sebelum dipakai di produksi.
const List<OrgInfo> kOrgs = [
  OrgInfo('BCA', OrgCategory.bank, r'\bbca\b', ['bca.co.id', 'klikbca.com']),
  OrgInfo('BRI', OrgCategory.bank, r'\bbri\b', ['bri.co.id']),
  OrgInfo('BNI', OrgCategory.bank, r'\bbni\b', ['bni.co.id']),
  OrgInfo('Mandiri', OrgCategory.bank, r'\bmandiri\b', ['bankmandiri.co.id']),
  OrgInfo('BTN', OrgCategory.bank, r'\bbtn\b', ['btn.co.id']),
  OrgInfo('BSI', OrgCategory.bank, r'\bbsi\b', ['bankbsi.co.id']),
  OrgInfo('CIMB Niaga', OrgCategory.bank, r'\bcimb\b', ['cimbniaga.co.id']),
  OrgInfo('GoPay', OrgCategory.wallet, r'\bgopay\b', [
    'gopay.co.id',
    'gojek.com',
  ]),
  OrgInfo('OVO', OrgCategory.wallet, r'\bovo\b', ['ovo.id']),
  OrgInfo('OJK', OrgCategory.gov, r'\bojk\b', ['ojk.go.id']),
  OrgInfo('Bank Indonesia', OrgCategory.gov, r'bank\s+indonesia', ['bi.go.id']),
  OrgInfo('Kepolisian', OrgCategory.gov, r'\b(polisi|polri|kepolisian)\b', [
    'polri.go.id',
  ]),
  OrgInfo('Kejaksaan', OrgCategory.gov, r'\bkejaksaan\b', ['kejaksaan.go.id']),
  OrgInfo('BPJS', OrgCategory.gov, r'\bbpjs\b', [
    'bpjs-kesehatan.go.id',
    'bpjsketenagakerjaan.go.id',
  ]),
  OrgInfo('DJP', OrgCategory.gov, r'\bdjp\b', ['pajak.go.id']),
  OrgInfo('JNE', OrgCategory.courier, r'\bjne\b', ['jne.co.id']),
  OrgInfo('J&T', OrgCategory.courier, r'\bj\s?&\s?t\b|\bjnt\b', ['jet.co.id']),
  OrgInfo('SiCepat', OrgCategory.courier, r'\bsicepat\b', ['sicepat.com']),
  OrgInfo('AnterAja', OrgCategory.courier, r'\banteraja\b', ['anteraja.id']),
  OrgInfo('Pos Indonesia', OrgCategory.courier, r'pos\s+indonesia', [
    'posindonesia.co.id',
  ]),
  OrgInfo('Shopee', OrgCategory.market, r'\bshopee(pay)?\b', [
    'shopee.co.id',
    'shopee.com',
  ]),
  OrgInfo('Tokopedia', OrgCategory.market, r'\btokopedia\b', ['tokopedia.com']),
  OrgInfo('Lazada', OrgCategory.market, r'\blazada\b', ['lazada.co.id']),
  OrgInfo('Telkomsel', OrgCategory.telco, r'\btelkomsel\b', ['telkomsel.com']),
  OrgInfo('Indosat', OrgCategory.telco, r'\bindosat\b', ['indosat.com']),
];

const Set<String> kShorteners = {
  'bit.ly',
  'tinyurl.com',
  's.id',
  'cutt.ly',
  't.ly',
  'rebrand.ly',
  'shorturl.at',
  'is.gd',
  'ow.ly',
  'rb.gy',
  'tiny.cc',
};

const Set<String> kChatHosts = {
  'wa.me',
  'chat.whatsapp.com',
  't.me',
  'telegram.me',
};

const Set<String> kOddTlds = {
  'xyz',
  'top',
  'click',
  'site',
  'online',
  'icu',
  'cfd',
  'vip',
  'buzz',
  'sbs',
  'monster',
  'lol',
  'rest',
  'cc',
};

final RegExp _urlRe = RegExp(
  r'(?:https?:\/\/|www\.)[^\s<>"]+|\b[a-z0-9][a-z0-9\-]*(?:\.[a-z0-9\-]+)*\.(?:com|net|org|id|xyz|top|click|site|online|icu|cfd|vip|link|info|app|shop|store|live|me|ly|gl|at|cc|io|sbs|buzz)(?:\/[^\s<>"]*)?',
  caseSensitive: false,
);

final RegExp _digitRunRe = RegExp(r'\+?\d(?:[\s\-.]?\d){7,15}');
final RegExp _phoneRe = RegExp(r'^(?:62|0)8\d{8,12}$');
final RegExp _thousandRe = RegExp(r'^\d{1,3}(?:\.\d{3})+$');
final RegExp _refContextRe = RegExp(
  r'(resi|awb|pesanan|order|invoice|ref|tracking|no\.?\s*id)\W*\w*\W*$',
);

String hostOf(String url) {
  var s = url.toLowerCase();
  s = s.replaceFirst(RegExp(r'^https?:\/\/'), '');
  s = s.replaceFirst(RegExp(r'^www\.'), '');
  final i = s.indexOf(RegExp(r'[\/?#:]'));
  if (i >= 0) s = s.substring(0, i);
  return s;
}

bool isOfficialHost(String host, Iterable<OrgInfo> orgs) {
  if (host == 'go.id' || host.endsWith('.go.id')) return true;
  for (final o in orgs) {
    for (final d in o.domains) {
      if (host == d || host.endsWith('.$d')) return true;
    }
  }
  return false;
}

List<OrgInfo> findOrgs(String lowerText) {
  return [
    for (final o in kOrgs)
      if (RegExp(o.pattern).hasMatch(lowerText)) o,
  ];
}

Entities extractEntities(String lowerText) {
  final urls = <String>[];
  final hosts = <String>[];
  var rest = lowerText;

  for (final m in _urlRe.allMatches(lowerText).toList()) {
    if (m.start > 0 && lowerText[m.start - 1] == '@') continue;
    var u = m.group(0)!;
    u = u.replaceFirst(RegExp(r'''[.,;:!?)"']+$'''), '');
    if (u.isEmpty) continue;
    urls.add(u);
    final h = hostOf(u);
    if (!hosts.contains(h)) hosts.add(h);
  }
  for (final u in urls) {
    rest = rest.replaceAll(u, ' ');
  }

  final accounts = <String>[];
  final phones = <String>[];
  for (final m in _digitRunRe.allMatches(rest)) {
    final raw = m.group(0)!;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (_thousandRe.hasMatch(raw.trim())) continue;
    if (_phoneRe.hasMatch(digits)) {
      if (!phones.contains(digits)) phones.add(digits);
      continue;
    }
    if (digits.length < 9 || digits.length > 16) continue;
    final before = rest.substring(0, m.start);
    final tail = before.length > 16
        ? before.substring(before.length - 16)
        : before;
    if (RegExp(r'rp\.?\s*$').hasMatch(tail)) continue;
    if (_refContextRe.hasMatch(tail)) continue;
    if (!accounts.contains(digits)) accounts.add(digits);
  }

  return Entities(
    accounts: accounts,
    phones: phones,
    urls: urls,
    hosts: hosts,
    orgs: [for (final o in findOrgs(lowerText)) o.name],
  );
}

String maskAccount(String d) {
  if (d.length >= 8) return '${d.substring(0, 4)}-${d.substring(4, 8)}-xx';
  return '${d.substring(0, 2)}xx';
}

String maskPhone(String d) {
  if (d.length < 8) return 'xxxx';
  return '${d.substring(0, 4)}xxxx${d.substring(d.length - 2)}';
}
