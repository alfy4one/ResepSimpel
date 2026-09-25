import 'package:app_resep/main.dart' show filterResep;
import 'package:app_resep/models/resep.dart';
import 'package:flutter_test/flutter_test.dart';

Resep _r(String nama, List<String> bahan, List<String> langkah) =>
    Resep(nama: nama, bahan: bahan, langkah: langkah);

void main() {
  // kategori per getter Resep: Kukus→Sehat, Goreng→Simpel, Tumis→Sayuran,
  // tempe/tahu (tanpa kata sebelumnya)→Protein
  final data = [
    _r('Tempe Telur Dadar', ['tempe', '3 butir telur ayam', 'kecap', 'bawang', 'minyak'],
        ['a', 'b', 'c', 'd']), // Protein, 5 bahan, 4 langkah
    _r('Kembang Tahu', ['tahu', 'garam', 'minyak'],
        ['a', 'b', 'c', 'd', 'e', 'f']), // Protein, 3 bahan, 6 langkah
    _r('Tumis Kangkung',
        ['kangkung', 'bawang merah', 'bawang putih', 'cabai', 'gula', 'garam', 'kecap', 'minyak'],
        ['a', 'b']), // Sayuran, 8 bahan, 2 langkah
    _r('Tempe Kukus', ['tempe', 'bawang', 'kecap', 'garam'],
        ['a', 'b', 'c', 'd', 'e']), // Sehat, 4 bahan, 5 langkah
  ];

  test('query match NAMA saja, bukan bahan', () {
    final h = filterResep(semua: data, query: 'ayam');
    expect(h, isEmpty, reason: '"ayam" cuma di bahan, ga boleh nongol apa pun');
  });

  test('query match nama case-insensitive', () {
    final h = filterResep(semua: data, query: 'tempe');
    expect(h.length, 2);
    expect(h.every((r) => r.nama.toLowerCase().contains('tempe')), isTrue);
  });

  test('filter bahan tertentu', () {
    final h = filterResep(semua: data, bahan: 'telur');
    expect(h.map((r) => r.nama), ['Tempe Telur Dadar']);
  });

  test('maxLangkah', () {
    final h = filterResep(semua: data, maxLangkah: 4);
    expect(h.map((r) => r.nama), ['Tempe Telur Dadar', 'Tumis Kangkung']);
  });

  test('maxBahan', () {
    final h = filterResep(semua: data, maxBahan: 4);
    expect(h.map((r) => r.nama), ['Kembang Tahu', 'Tempe Kukus']);
  });

  test('sort langkah desc', () {
    final h = filterResep(semua: data, sortLangkah: 'desc');
    expect(h.map((r) => r.langkah.length), [6, 5, 4, 2]);
  });

  test('sort bahan asc', () {
    final h = filterResep(semua: data, sortBahan: 'asc');
    expect(h.map((r) => r.bahan.length), [3, 4, 5, 8]);
  });

  test('kombinasi: bahan + sort langkah asc', () {
    final h = filterResep(semua: data, bahan: 'tempe', sortLangkah: 'asc');
    expect(h.map((r) => r.nama), ['Tempe Telur Dadar', 'Tempe Kukus']);
  });

  test('tanpa filter = semua, urutan asal', () {
    final h = filterResep(semua: data);
    expect(h.length, 4);
    expect(h.map((r) => r.nama).first, 'Tempe Telur Dadar');
  });
}
