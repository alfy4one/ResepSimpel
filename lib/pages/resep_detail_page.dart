import 'package:flutter/material.dart';
import '../models/resep.dart';

// Design tokens
const cLatar = Color(0xFFE3F2FD);
const cPutih = Colors.white;
const cBiruTerang = Color(0xFF90CAF9);
const cBiruVivid = Color(0xFF2196F3);
const cBiruPekat = Color(0xFF0D47A1);
const cTeksUtama = Color(0xFF212121);
const cTeksMuted = Color(0xFF757575);

class ResepDetailPage extends StatelessWidget {
  final Resep resep;
  const ResepDetailPage({super.key, required this.resep});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cLatar,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: cBiruPekat,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 8, 4),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                  color: cPutih,
                  // Panah kembali: dasar putih + bayangan hitam biar keliatan
                  // di atas foto mana pun (putih polos bisa nyamar di photo terang)
                  shadows: const [
                    Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1.5, 1.5)),
                  ],
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                resep.nama,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cPutih,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              background: _buildFotoResep(resep),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Bahan', resep.bahan),
                  const SizedBox(height: 24),
                  _buildSection('Langkah', resep.langkah),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotoResep(Resep resep) {
    if (resep.fotoPath != null) {
      return Hero(
        tag: 'resep-${resep.nama}',
        child: Image.asset(
          resep.fotoPath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: cBiruTerang,
            alignment: Alignment.center,
            child: const Icon(Icons.restaurant, size: 80, color: cBiruPekat),
          ),
        ),
      );
    }
    return Container(
      color: cBiruTerang,
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant, size: 80, color: cBiruPekat),
    );
  }

  Widget _buildSection(String judul, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cPutih,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: cBiruVivid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cBiruPekat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: cLatar,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$idx',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: cBiruPekat,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: cTeksUtama,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
