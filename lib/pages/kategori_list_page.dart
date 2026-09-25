import 'package:flutter/material.dart';
import '../models/resep.dart';
import '../data/resep_data.dart';
import 'resep_detail_page.dart';

// Design tokens
const cLatar = Color(0xFFE3F2FD);
const cPutih = Colors.white;
const cBiruTerang = Color(0xFF90CAF9);
const cBiruVivid = Color(0xFF2196F3);
const cBiruPekat = Color(0xFF0D47A1);
const cTeksUtama = Color(0xFF212121);
const cTeksMuted = Color(0xFF757575);

class KategoriListPage extends StatelessWidget {
  final String kategori;
  const KategoriListPage({super.key, required this.kategori});

  @override
  Widget build(BuildContext context) {
    final resepList = daftarResep.where((r) => r.kategori == kategori).toList();

    return Scaffold(
      backgroundColor: cLatar,
      appBar: AppBar(
        title: Text(
          'Resep $kategori',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: cBiruPekat,
        foregroundColor: cPutih,
        elevation: 0,
      ),
      body: resepList.isEmpty
          ? const Center(
              child: Text(
                'Belum ada resep',
                style: TextStyle(color: cTeksMuted, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: resepList.length,
              itemBuilder: (context, index) {
                final resep = resepList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildKartuResep(context, resep),
                );
              },
            ),
    );
  }

  Widget _buildKartuResep(BuildContext context, Resep resep) {
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
            // Foto resep
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
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.restaurant, size: 40, color: cBiruPekat),
                      ),
                    )
                  : const Icon(Icons.restaurant, size: 40, color: cBiruPekat),
            ),
            // Info resep
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
                        color: cTeksUtama,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.restaurant_menu, size: 14, color: cTeksMuted),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${resep.bahan.length} bahan',
                            style: const TextStyle(fontSize: 12, color: cTeksMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.list_alt, size: 14, color: cTeksMuted),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${resep.langkah.length} langkah',
                            style: const TextStyle(fontSize: 12, color: cTeksMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
