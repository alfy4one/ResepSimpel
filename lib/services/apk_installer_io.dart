import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Download APK + pasang via ACTION_VIEW (Android).
/// Bagian io-nya dipisah lewat conditional import supaya build web tetap aman.
class ApkInstaller {
  /// Unduh [url] ke folder Download publik, return path file.
  /// ponytail: Download dir bisa gagal di Android 14+ profil scoped-storage ketat;
  /// upgrade path: ganti ke getExternalStorageDirectory() (app dir, selalu writable).
  static Future<String> unduh(String url, {void Function(double)? onProgress}) async {
    final dir = await getDownloadsDirectory();
    final file = File('${dir?.path ?? ''}/ResepSimpel.apk');
    final req = await http.Client().send(http.Request('GET', Uri.parse(url)));
    if (req.statusCode != 200) {
      throw Exception('Download gagal (status ${req.statusCode})');
    }
    final total = int.tryParse(req.headers['content-length'] ?? '') ?? 0;
    var terkumpul = 0;
    final bos = file.openWrite();
    await req.stream
        .listen(
      (data) {
        terkumpul += data.length;
        onProgress?.call(total > 0 ? terkumpul / total : 0);
        bos.add(data);
      },
      onDone: bos.close,
      cancelOnError: true,
    )
        .asFuture<void>();
    return file.path;
  }

  /// Pasang APK: buka intent ACTION_VIEW ke installer sistem (muncul dialog
  /// "izin install dari sumber tidak dikenal" sekali di Android).
  static Future<void> pasang(String path) async {
    await OpenFilex.open(path);
  }
}
