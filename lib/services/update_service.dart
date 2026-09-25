import 'dart:convert';
import 'package:http/http.dart' as http;

/// Dilempar saat repo belum punya release sama sekali (HTTP 404).
class BelumRilisException implements Exception {
  const BelumRilisException();
  @override
  String toString() => 'Belum ada rilis di GitHub';
}

/// Info rilis terbaru dari GitHub Releases.
class InfoUpdate {
  final String versi; // tag_name tanpa prefix 'v'
  final String? changelog; // field `body` release
  final String? apkUrl; // browser_download_url asset .apk
  final String urlRelease; // halaman release

  const InfoUpdate({
    required this.versi,
    required this.urlRelease,
    this.changelog,
    this.apkUrl,
  });
}

/// Cek versi app dari GitHub Releases (repo alfy4one/ResepSimpel).
/// `versiSaatIni` harus disinkronkan dengan `version:` di pubspec.yaml.
class UpdateService {
  static const repoOwner = 'alfy4one';
  static const repoName = 'ResepSimpel';
  static const versiSaatIni = '1.0.0';

  static Future<InfoUpdate> cekUpdate() async {
    final uri =
        Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest');
    final res = await http
        .get(uri, headers: const {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'ResepSimpel',
        })
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 404) {
      // Repo belum punya release → bukan error, kondisi wajar.
      throw const BelumRilisException();
    }
    if (res.statusCode != 200) {
      throw Exception('Gagal memeriksa pembaruan (status ${res.statusCode})');
    }
    return parseRelease(jsonDecode(res.body));
  }

  /// Parse JSON release GitHub jadi InfoUpdate (dipisah utk gampang dites).
  static InfoUpdate parseRelease(Object json) {
    final d = json as Map<String, dynamic>;
    String? apk;
    for (final a in (d['assets'] as List? ?? const [])) {
      final m = a as Map<String, dynamic>;
      if ((m['name']?.toString() ?? '').endsWith('.apk')) {
        apk = m['browser_download_url']?.toString();
        break;
      }
    }
    return InfoUpdate(
      versi: (d['tag_name']?.toString() ?? '').replaceFirst(RegExp(r'^[vV]'), ''),
      changelog: d['body']?.toString(),
      apkUrl: apk,
      urlRelease: d['html_url']?.toString() ?? '',
    );
  }

  /// true bila versi release lebih baru dari [versiSaatIni].
  static bool adaUpdate(InfoUpdate info) =>
      _bandingkanVersi(info.versi, versiSaatIni) > 0;

  /// Bandingkan dua versi a.b.c, return >0 bila [a] lebih baru.
  static int _bandingkanVersi(String a, String b) {
    final pa = a.split('.').map((x) => int.tryParse(x) ?? 0).toList();
    final pb = b.split('.').map((x) => int.tryParse(x) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x > y ? 1 : -1;
    }
    return 0;
  }
}
