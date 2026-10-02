import 'package:flutter/material.dart';
import '../models/resep.dart';
import '../data/resep_data.dart';
import '../data/bahan_populer.dart';
import 'resep_detail_page.dart';

// Design tokens (sama seperti page lain — tiap file punya salinannya)
const cLatar = Color(0xFFE3F2FD);
const cPutih = Colors.white;
const cBiruTerang = Color(0xFF90CAF9);
const cBiruVivid = Color(0xFF2196F3);
const cBiruPekat = Color(0xFF0D47A1);
const cTeksMuted = Color(0xFF5E6C81);

/// Berapa bahan dari [dipilih] yang ada di [resep], dan yang mana yang kurang.
/// Match pakai substring pada teks bahan apa adanya ("bawang putih" ikut
/// cocok dengan "bawang putih (haluskan)") — ga perlu parse jumlah/satuan.
({int punya, List<String> kurang}) cocokDapur(Resep resep, List<String> dipilih) {
  final isi = resep.bahan.map((b) => b.toLowerCase()).toList();
  final kurang = <String>[];
  var punya = 0;
  for (final b in dipilih) {
    if (isi.any((x) => x.contains(b.toLowerCase()))) {
      punya++;
    } else {
      kurang.add(b);
    }
  }
  return (punya: punya, kurang: kurang);
}

/// Resep yang cocok >=1 bahan pilihan, diurutkan dari paling lengkap; seri
/// dipecah oleh jumlah bahan (resep simpel lebih dulu).
List<Resep> urutDapur(List<Resep> semua, List<String> dipilih) {
  if (dipilih.isEmpty) return const [];
  final list = semua.where((r) => cocokDapur(r, dipilih).punya > 0).toList();
  list.sort((a, b) {
    final c = cocokDapur(b, dipilih).punya.compareTo(cocokDapur(a, dipilih).punya);
    return c != 0 ? c : a.bahan.length.compareTo(b.bahan.length);
  });
  return list;
}

class DapurPintarPage extends StatefulWidget {
  const DapurPintarPage({super.key});

  @override
  State<DapurPintarPage> createState() => _DapurPintarPageState();
}

class _DapurPintarPageState extends State<DapurPintarPage> {
  final Set<String> _dipilih = <String>{};

  @override
  Widget build(BuildContext context) {
    final hasil = urutDapur(daftarResep, _dipilih.toList());

    return Scaffold(
      backgroundColor: cLatar,
      appBar: AppBar(
        title: const Text(
          'Dapur Pintar',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: cBiruPekat,
        foregroundColor: cPutih,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pilih bahan yang ada di dapurmu',
            style: TextStyle(color: cBiruPekat, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          // Summary bar di ATAS: jumlah hasil + Reset selalu kelihatan
          // (dulu di bawah 38 chip, jadi tenggelam & ga bisa dipatet).
          Row(
            children: [
              Expanded(
                child: Text(
                  _dipilih.isEmpty
                      ? 'Belum ada bahan dipilih'
                      : '${hasil.length} resep cocok',
                  style: const TextStyle(color: cBiruPekat, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              if (_dipilih.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _dipilih.clear()),
                  child: const Text('Reset', style: TextStyle(color: cBiruPekat)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_dipilih.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Pilih minimal satu bahan di bawah.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cTeksMuted, fontSize: 14),
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Chip bahan per grup
          for (final grup in daftarBahanPopuler) ...[
            Text(
              grup.judul,
              style: const TextStyle(color: cTeksMuted, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final b in grup.bahan) _chip(b),
              ],
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 8), // law of proximity: 32 antar seksi
          // Hasil
          if (_dipilih.isNotEmpty && hasil.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Belum ada resep yang cocok.\nCoba pilih bahan lain.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cTeksMuted, fontSize: 14),
                ),
              ),
            )
          else
            for (final resep in hasil)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _kartuResep(context, resep),
              ),
        ],
      ),
    );
  }

  Widget _chip(String bahan) {
    final aktif = _dipilih.contains(bahan);
    return FilterChip(
      label: Text(bahan),
      selected: aktif,
      showCheckmark: false,
      backgroundColor: cPutih,
      selectedColor: cBiruVivid,
      side: BorderSide(color: aktif ? cBiruVivid : cBiruTerang),
      labelStyle: TextStyle(
        color: aktif ? cPutih : cBiruPekat,
        fontSize: 13,
        fontWeight: aktif ? FontWeight.w700 : FontWeight.w400,
      ),
      onSelected: (v) => setState(() => v ? _dipilih.add(bahan) : _dipilih.remove(bahan)),
    );
  }

  Widget _kartuResep(BuildContext context, Resep resep) {
    final c = cocokDapur(resep, _dipilih.toList());
    final lengkap = c.kurang.isEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResepDetailPage(resep: resep)),
      ),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: cPutih,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Container(
              width: 120,
              height: 120,
              color: cBiruTerang,
              child: resep.fotoPath != null
                  ? Hero(
                      tag: 'resep-${resep.nama}',
                      child: Image.asset(
                        resep.fotoPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _logo(40),
                      ),
                    )
                  : _logo(40),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      resep.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cBiruPekat,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Badge: lengkap (padat) vs kurang (outline abu)
                    if (lengkap)
                      _badge('Lengkap', filled: true)
                    else ...[
                      _badge('Kurang ${c.kurang.length} bahan', filled: false),
                      const SizedBox(height: 8),
                      Text(
                        'kurang: ${c.kurang.join(', ')}',
                        style: const TextStyle(fontSize: 12, color: cTeksMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String teks, {required bool filled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? cBiruPekat : Colors.transparent,
        border: filled ? null : Border.all(color: cTeksMuted),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        teks,
        style: TextStyle(
          color: filled ? cPutih : cTeksMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Widget _logo(double size) => SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/logo_resepsimpel.webp',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
