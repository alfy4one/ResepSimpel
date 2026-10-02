// Bahan paling sering muncul di 100 resep — dipakai sebagai chip
// pilihan di halaman Dapur Pintar. Di-generate dari lib/data/resep_data.dart
// (semua item di sini terverifikasi muncul di >=1 resep).
//
// ponytail: daftar statis, bukan hasil parse. Kalau nanti nambah resep baru
// dan ada bahan umum yang belum ada di sini, tambahkan manual ke grupnya.

class GrupBahan {
  final String judul;
  final List<String> bahan;
  const GrupBahan(this.judul, this.bahan);
}

const List<GrupBahan> daftarBahanPopuler = [
  GrupBahan('Bumbu Dasar', [
    'bawang putih',
    'bawang merah',
    'garam',
    'gula',
    'gula merah',
    'lada',
    'merica bubuk',
    'kecap manis',
    'saus tiram',
    'kaldu bubuk',
    'daun salam',
    'lengkuas',
    'daun jeruk',
    'kemiri',
    'ketumbar',
    'kunyit',
  ]),
  GrupBahan('Protein', [
    'tempe',
    'tahu',
    'telur',
  ]),
  GrupBahan('Sayuran', [
    'wortel',
    'kangkung',
    'buncis',
    'labu siam',
    'kol',
    'tomat',
    'kentang',
    'brokoli',
    'bayam',
    'daun pisang',
    'sawi hijau',
    'terong',
    'timun',
  ]),
  GrupBahan('Lainnya', [
    'air',
    'minyak',
    'maizena',
    'tapioka',
    'beras',
    'santan',
  ]),
];
