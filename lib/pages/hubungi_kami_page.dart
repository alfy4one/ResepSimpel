import 'package:flutter/material.dart';
import '../main.dart' show cLatar, cPutih, cBiruVivid, cBiruPekat, cTeksUtama, cTeksMuted;
import '../services/feedback_service.dart';

/// Halaman Hubungi Kami — form feedback yang kirim ke GitHub Issues.
class HubungiKamiPage extends StatefulWidget {
  const HubungiKamiPage({super.key});

  @override
  State<HubungiKamiPage> createState() => _HubungiKamiPageState();
}

class _HubungiKamiPageState extends State<HubungiKamiPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _pesanController = TextEditingController();
  bool _sedangKirim = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sedangKirim = true);

    final (sukses, pesan) = await FeedbackService.kirimFeedback(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      pesan: _pesanController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _sedangKirim = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: sukses ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );

    if (sukses) {
      // Kosongkan form setelah berhasil
      _namaController.clear();
      _emailController.clear();
      _pesanController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cLatar,
      appBar: AppBar(
        backgroundColor: cBiruPekat,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hubungi Kami',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Ada saran atau masukan? Kirim pesan ke kami dan kami akan segera merespons.',
                style: TextStyle(color: cTeksMuted, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              
              // Field Nama
              const Text('Nama', style: TextStyle(color: cTeksUtama, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama kamu',
                  filled: true,
                  fillColor: cPutih,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Field Email
              const Text('Email', style: TextStyle(color: cTeksUtama, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Masukkan email kamu',
                  filled: true,
                  fillColor: cPutih,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                  if (!v.contains('@')) return 'Email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Field Pesan
              const Text('Pesan', style: TextStyle(color: cTeksUtama, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pesanController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan kamu di sini...',
                  filled: true,
                  fillColor: cPutih,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Pesan wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // Tombol Kirim
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _sedangKirim ? null : _kirim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cBiruVivid,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _sedangKirim
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Kirim Pesan',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
