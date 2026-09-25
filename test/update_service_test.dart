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
    // versiSaatIni = 1.0.0
    test('1.0.1 > 1.0.0 → ada update', () {
      expect(UpdateService.adaUpdate(_info('1.0.1')), isTrue);
    });

    test('2.0.0 > 1.0.0 → ada update', () {
      expect(UpdateService.adaUpdate(_info('2.0.0')), isTrue);
    });

    test('1.0.0 == 1.0.0 → tidak ada update', () {
      expect(UpdateService.adaUpdate(_info('1.0.0')), isFalse);
    });

    test('1.0.0 < 1.1.0 → tidak ada update', () {
      expect(UpdateService.adaUpdate(_info('1.0.0')), isFalse);
      expect(UpdateService.adaUpdate(_info('0.9.9')), isFalse);
    });
  });
}

InfoUpdate _info(String versi) =>
    UpdateService.parseRelease({'tag_name': 'v$versi', 'html_url': 'x', 'assets': []});
