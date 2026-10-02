import 'package:app_resep/pages/dapur_pintar_page.dart' show cocokDapur, urutDapur;
import 'package:app_resep/models/resep.dart';
import 'package:app_resep/data/resep_data.dart';
import 'package:app_resep/data/bahan_populer.dart';
import 'package:flutter_test/flutter_test.dart';

Resep _r(String nama, List<String> bahan) =>
    Resep(nama: nama, bahan: bahan, langkah: ['a', 'b']);

void main() {
  final data = [
    _r('Telur Dadar', ['telur', 'bawang putih', 'garam', 'minyak']),
    _r('Orek Telur', ['telur', 'bawang merah', 'kecap manis', 'minyak']),
    _r('Tumis Kangkung', ['kangkung', 'bawang putih', 'garam', 'minyak']),
    _r('Nasi Putih', ['beras', 'air']),
  ];

  test('cocokDapur: hitung punya & bahan kurang', () {
    final c = cocokDapur(data.first, ['telur', 'garam', 'kentang']);
    expect(c.punya, 2, reason: 'telur + garam ada, kentang tidak');
    expect(c.kurang, ['kentang']);
  });

  test('cocokDapur: substring ikut cocok ("bawang putih (haluskan)")', () {
    final c = cocokDapur(
      _r('Uji', ['2 siung bawang putih (haluskan)', '100g tempe']),
      ['bawang putih', 'tahu'],
    );
    expect(c.punya, 1, reason: 'bawang putih ketemu di teks bahan berantakan');
    expect(c.kurang, ['tahu']);
  });

  test('cocokDapur: case-insensitive', () {
    final c = cocokDapur(_r('Uji', ['Bawang Putih']), ['bawang putih']);
    expect(c.punya, 1);
  });

  test('urutDapur: pilihan kosong = tidak ada hasil', () {
    expect(urutDapur(data, []), isEmpty);
  });

  test('urutDapur: hanya resep yang punya >=1 bahan pilihan', () {
    final h = urutDapur(data, ['telur']).map((r) => r.nama);
    expect(h, ['Telur Dadar', 'Orek Telur']);
    expect(h, isNot(contains('Nasi Putih')));
  });

  test('urutDapur: urut dari paling lengkap', () {
    final pilih = ['telur', 'bawang putih', 'bawang merah'];
    final h = urutDapur(data, pilih);
    // Telur Dadar 2 · Orek Telur 2 · Kangkung 1 · Nasi Putih 0 (buang)
    expect(h.map((r) => cocokDapur(r, pilih).punya), [2, 2, 1],
        reason: 'skor bahan diminish harus menurun');
    expect(h.map((r) => r.nama), containsAll(['Telur Dadar', 'Orek Telur']));
    expect(h.last.nama, 'Tumis Kangkung');
  });

  test('urutDapur: seri dipecah bahan paling sedikit dulu', () {
    final h = urutDapur([_r('Panjang', ['telur', 'air', 'garam']), _r('Pendek', ['telur'])], ['telur']);
    expect(h.map((r) => r.nama), ['Pendek', 'Panjang']);
  });

  test('data nyata: tiap bahan populer ada di >=1 resep', () {
    for (final grup in daftarBahanPopuler) {
      for (final b in grup.bahan) {
        expect(
          urutDapur(daftarResep, [b]),
          isNotEmpty,
          reason: 'bahan "$b" (grup ${grup.judul}) ga ada di recipe mana pun — chip mati',
        );
      }
    }
  });

  test('data nyata: 100 resep ter-cover oleh daftar bahan populer', () {
    final semuaBahan = daftarBahanPopuler.expand((g) => g.bahan).toList();
    final terjangkau = urutDapur(daftarResep, semuaBahan).length;
    expect(terjangkau, greaterThanOrEqualTo(90),
        reason: 'hampir semua resep harus bisa dimasukin dari chip yang ada');
  });
}
