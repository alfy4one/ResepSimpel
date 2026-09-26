import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service untuk kirim feedback user ke GitHub Issues repo alfy4one/ResepSimpel.
/// Token hardcode (public_repo scope) — aman untuk tugas sekolah, tapi untuk
/// produksi sebaiknya pakai backend proxy.
class FeedbackService {
  // TODO: Ganti dengan GitHub PAT milikmu (scope: public_repo / repo)
  // Dapatkan di: https://github.com/settings/tokens
  static const _token = 'YOUR_GITHUB_PAT_HERE';
  static const _repoOwner = 'alfy4one';
  static const _repoName = 'ResepSimpel';

  /// Kirim feedback sebagai GitHub Issue baru.
  /// Returns: (sukses: bool, pesan: String)
  static Future<(bool, String)> kirimFeedback({
    required String nama,
    required String email,
    required String pesan,
  }) async {
    try {
      final url = Uri.parse('https://api.github.com/repos/$_repoOwner/$_repoName/issues');
      
      final body = jsonEncode({
        'title': 'Feedback dari $nama',
        'body': '**Email:** $email\n\n$pesan',
        'labels': ['feedback'],
      });

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        return (true, 'Terima kasih! Feedback kamu sudah terkirim.');
      } else {
        return (false, 'Gagal mengirim feedback (status ${response.statusCode})');
      }
    } catch (e) {
      return (false, 'Gagal mengirim feedback: $e');
    }
  }
}
