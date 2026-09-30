import 'package:flutter_test/flutter_test.dart';
import 'package:app_resep/services/update_service.dart';

void main() {
  group('UpdateService.parseRelease', () {
    test('tag v1.0.2 + body + asset apk → InfoUpdate lengkap', () {
      final info = UpdateService.parseRelease({
        'tag_name': 'v1.0.2',
        'body': '- Fitur baru\n- Bugfix search',
        'html_url': 'https://github.com/alfy4one/ResepSimpel/releases/tag/v1.0.2',
        'assets': [
          {'name': 'resep-simpel.apk', 'browser_download_url': 'https://cdn.x/a.apk'},
          {'name': 'source.zip', 'browser_download_url': 'https://cdn.x/b.zip'},
        ],
      });
      expect(info.versi, '1.0.2');
      expect(info.changelog, contains('Bugfix search'));
      expect(info.apkUrl, 'https://cdn.x/a.apk');
      expect(info.urlRelease, contains('releases'));
    });

    test('tanpa asset apk → apkUrl null (dialog tampilkan tombol download)', () {
      final info = UpdateService.parseRelease({
        'tag_name': 'v9.9.9',
        'body': null,
        'html_url': 'https://github.com/x/y/releases/tag/v9.9.9',
        'assets': <Map<String, dynamic>>[],
      });
      expect(info.apkUrl, isNull);
      expect(info.changelog, isNull);
    });
  });

  group('UpdateService.adaUpdate', () {
    // Diuji relatif terhadap versiSaatIni yang aktif, bukan angka tetap,
    // supaya test tetap valid saat versi aplikasi di-bump.
    test('versi release > versiSaatIni → ada update', () {
      expect(UpdateService.adaUpdate(_info(_nextAfter(UpdateService.versiSaatIni))), isTrue);
      expect(UpdateService.adaUpdate(_info('99.0.0')), isTrue);
    });

    test('versi release == versiSaatIni → tidak ada update', () {
      expect(UpdateService.adaUpdate(_info(UpdateService.versiSaatIni)), isFalse);
    });

    test('versi release < versiSaatIni → tidak ada update', () {
      expect(UpdateService.adaUpdate(_info('0.0.1')), isFalse);
    });
  });
}

/// Versi satu tingkat lebih besar dari [v] (mis. 1.5.0 -> 1.5.1).
String _nextAfter(String v) {
  final p = v.split('.');
  final last = int.parse(p.last) + 1;
  return '${p[0]}.${p[1]}.$last';
}

InfoUpdate _info(String versi) =>
    UpdateService.parseRelease({'tag_name': 'v$versi', 'html_url': 'x', 'assets': []});
