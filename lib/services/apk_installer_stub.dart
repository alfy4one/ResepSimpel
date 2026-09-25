/// Stub untuk web: in-app update (download + install APK) hanya di Android.
class ApkInstaller {
  static Future<String> unduh(String url, {void Function(double)? onProgress}) async {
    throw UnsupportedError('Update in-app hanya tersedia di Android.');
  }

  static Future<void> pasang(String path) async {
    throw UnsupportedError('Update in-app hanya tersedia di Android.');
  }
}
