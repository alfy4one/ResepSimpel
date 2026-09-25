import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'data/resep_data.dart';
import 'models/resep.dart';
import 'pages/kategori_list_page.dart';
import 'pages/resep_detail_page.dart';
// In-app update: di web pakai stub, di Android/VM pakai versi io (download + install)
import 'services/apk_installer_stub.dart'
    if (dart.library.io) 'services/apk_installer_io.dart';
import 'services/update_service.dart';

void main() => runApp(const AppResep());

// 25 resep sayur (nama dari file foto di ~/Downloads/foto/)
const List<String> resep = [
  'Sayur Bening Bayam', 'Tumis Kangkung', 'Sayur Asem', 'Capcay',
  'Tumis Wortel Buncis', 'Sayur Lodeh', 'Tumis Sawi Hijau', 'Tumis Kol',
  'Tumis Tauge', 'Sayur Sop', 'Tumis Pare', 'Tumis Labu Siam',
  'Tumis Genjer', 'Tumis Daun Singkong', 'Tumis Kacang Panjang',
  'Sayur Bening Oyong', 'Tumis Brokoli', 'Tumis Kembang Kol',
  'Sayur Bobor Bayam', 'Tumis Terong', 'Tumis Pakcoy', 'Tumis Jagung Muda',
  'Sayur Bening Labu Siam', 'Tumis Rebung', 'Tumis Tahu Sayuran',
];

// Palet app — palet biru Material (swatch 2026-09-24), aturan:
//  Warna 60-30-10:
//   60%  #E3F2FD + putih  (latar + card, permukaan dominan)
//   30%  #90CAF9          (hero, pill nav aktif, chip, strip)
//   10%  #2196F3 + #0D47A1 (aksen ikon; header, teks utama, tombol, nav aktif)
//  Layout:
//   8 point spacing — semua padding/margin/spacing kelipatan 8 (8/16/24/32)
//   Law of proximity — elemen satu seksi lebih rapat (8-16), antar seksi lebih lebar (24-32)
//   Vertical rhythm — hirarki vertikal kontras: antar blok page 32, antar card 24, dalam seksi 8-16
const Color cLatar = Color(0xFFE3F2FD);
const Color cPutih = Colors.white;
const Color cBiruTerang = Color(0xFF90CAF9);
const Color cBiruVivid = Color(0xFF2196F3);
const Color cBiruPekat = Color(0xFF0D47A1); // teks utama/header/tombol/nav aktif (kontras 7.5-8.6:1)
const Color cTeksUtama = cBiruPekat; // alias
const Color cTeksMuted = Color(0xFF5E6C81); // hint/muted (kontras 4.8:1 di atas putih)

class AppResep extends StatelessWidget {
  const AppResep({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Resep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: cLatar,
        colorScheme: ColorScheme.fromSeed(seedColor: cBiruTerang),
      ),
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  ShellState createState() => ShellState();
}

class ShellState extends State<Shell> {
  int _index = 0;
  static const _pages = [HomePage(), SearchPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? cBiruPekat : cTeksMuted,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: cPutih,
          indicatorColor: cBiruTerang,
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
            color: states.contains(WidgetState.selected) ? cBiruPekat : cTeksMuted,
          )),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

// ===== HOME PAGE (design mockup 2026-09-23) =====
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final next = (_currentPage + 1) % 3;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carouselResep = daftarResep.take(3).toList();
    return SafeArea(
      child: Column(
        children: [
          // Header: logo + nama + tagline
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cBiruTerang,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.restaurant, color: cBiruPekat, size: 22),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ResepSimpel',
                        style: TextStyle(color: cBiruPekat, fontSize: 17, fontWeight: FontWeight.w700, height: 1.1),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Resep sederhana untuk hidup lebih sehat',
                        style: TextStyle(color: cTeksMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Konten
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Hero banner carousel - pakai 3 resep pertama dengan foto asli
                SizedBox(
                  height: 128,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _restartTimer();
                    },
                    itemCount: carouselResep.length,
                    itemBuilder: (context, index) {
                      final resep = carouselResep[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResepDetailPage(resep: resep)),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(top: 16, right: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cBiruTerang,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        index == 0 ? 'Mau masak apa hari ini?' : index == 1 ? 'Resep cepat & mudah' : 'Masakan rumahan favorit',
                                        style: const TextStyle(color: cBiruPekat, fontSize: 18, fontWeight: FontWeight.w700),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Flexible(
                                      child: Text(
                                        index == 0 ? 'Pilih bahan utama dan temukan resepnya' : index == 1 ? 'Siap dalam 30 menit' : 'Lezat & bergizi',
                                        style: const TextStyle(color: cBiruPekat, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  // dot indicators
                                  Row(
                                    children: List.generate(carouselResep.length, (i) => Container(
                                      width: 8,
                                      height: 8,
                                      margin: EdgeInsets.only(right: i < carouselResep.length - 1 ? 8 : 0),
                                      decoration: BoxDecoration(
                                        color: i == _currentPage ? cBiruPekat : cBiruPekat.withValues(alpha: 0.35),
                                        shape: BoxShape.circle,
                                      ),
                                    )),
                                  ),
                                ],
                              ),
                            ),
                            // Foto resep asli (1:1 square)
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: cBiruVivid,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: resep.fotoPath != null
                                  ? Image.asset(
                                      resep.fotoPath!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.restaurant, size: 32, color: cPutih),
                                    )
                                  : Icon(Icons.restaurant, size: 32, color: cPutih),
                            ),
                          ],
                        ),
                      ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Resep Pilihan untuk Kamu',
                  style: TextStyle(color: cBiruPekat, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                // Grid 2 kolom: Simpel & Sayuran
                Row(
                  children: [
                    Expanded(child: _kartuKategori(context, 'Simpel', Icons.restaurant_menu, cBiruTerang, 72)),
                    const SizedBox(width: 16),
                    Expanded(child: _kartuKategori(context, 'Sayuran', Icons.eco, cLatar, 72)),
                  ],
                ),
                const SizedBox(height: 16),
                // Grid 2 kolom: Protein & Sehat
                Row(
                  children: [
                    Expanded(child: _kartuKategori(context, 'Protein', Icons.egg_alt, cBiruTerang, 72)),
                    const SizedBox(width: 16),
                    Expanded(child: _kartuKategori(context, 'Sehat', Icons.favorite, cLatar, 72)),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Kartu kategori bahan (foto real di atas + strip label di bawah)
Widget _kartuKategori(BuildContext context, String nama, IconData ikon, Color warnaFoto, double tinggiFoto) {
  // ikon di area foto: latar biru terang->ikon pekat, latar pucat->ikon vivid
  final ikonFoto = warnaFoto == cBiruTerang ? cBiruPekat : cBiruVivid;
  
  // Hitung resep per kategori
  final resepList = daftarResep.where((r) => r.kategori == nama).toList();
  final jumlah = resepList.length;
  final fotoContoh = resepList.isNotEmpty && resepList.first.fotoPath != null ? resepList.first.fotoPath! : null;
  
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KategoriListPage(kategori: nama)),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: cPutih,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: tinggiFoto,
            color: warnaFoto,
            alignment: Alignment.center,
            child: fotoContoh != null
                ? Image.asset(
                    fotoContoh,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.restaurant, size: 28, color: ikonFoto),
                  )
                : Icon(Icons.restaurant, size: 28, color: ikonFoto),
          ),
          Container(
            color: cLatar,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: cPutih,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(ikon, size: 16, color: cBiruPekat),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(color: cBiruPekat, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text('$jumlah resep', style: const TextStyle(color: cTeksMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ===== SEARCH PAGE (mirip KategoriListPage) =====
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<Resep> _filteredResep() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return daftarResep;
    return daftarResep.where((r) => 
      r.nama.toLowerCase().contains(q) ||
      r.bahan.any((b) => b.toLowerCase().contains(q))
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _filteredResep();
    return SafeArea(
      child: Column(
        children: [
          // Search bar (pill)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 56,
              decoration: BoxDecoration(
                color: cPutih,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: cTeksUtama, size: 22),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: cTeksUtama),
                      decoration: const InputDecoration(
                        hintText: 'Cari resep...',
                        hintStyle: TextStyle(color: cTeksMuted),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Hasil list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: hasil.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada resep ditemukan',
                        style: TextStyle(color: cTeksMuted, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: hasil.length,
                      itemBuilder: (context, index) {
                        final resep = hasil[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildKartuResep(context, resep),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Reuse card from KategoriListPage
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

// ===== SETTINGS PAGE (design mockup 2026-09-24) =====
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header biru
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
          decoration: const BoxDecoration(
            color: cBiruPekat,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Container(
                width: 280,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
        ),
        // Body
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 24),
              _labelSeksi('Versi'),
              const SizedBox(height: 8),
              _itemSettings(Icons.info_outline, 'Versi Aplikasi', trailing: Text('v${UpdateService.versiSaatIni}', style: const TextStyle(color: cTeksMuted, fontSize: 15))),
              const SizedBox(height: 8),
              _itemSettings(
                Icons.download_outlined,
                'Periksa Pembaruan',
                trailing: _tombolOutline('Cek Pembaruan'),
                onTap: () => _periksaUpdate(context),
              ),
              const SizedBox(height: 32),
              _labelSeksi('Bantuan & Informasi'),
              const SizedBox(height: 8),
              _itemSettings(Icons.chat_bubble_outline, 'Hubungi Kami', trailing: _tombolOutline('Kirim Pesan')),
              const SizedBox(height: 8),
              _itemSettings(
                Icons.person_outline,
                'Tentang Aplikasi',
                trailing: _tombolOutline('Selengkapnya'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===== ALUR IN-APP UPDATE (cek GitHub → dialog changelog → download → install) =====
Future<void> _periksaUpdate(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  navigator.push(DialogRoute<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      title: Text('Memeriksa pembaruan...'),
      content: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    ),
  ));
  try {
    final info = await UpdateService.cekUpdate();
    navigator.pop();
    if (!UpdateService.adaUpdate(info)) {
      messenger.showSnackBar(
        SnackBar(content: Text('Sudah versi terbaru (v${UpdateService.versiSaatIni})')),
      );
      return;
    }
    await navigator.push(
      MaterialPageRoute(builder: (_) => _DialogUpdate(info)),
    );
  } on BelumRilisException {
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Belum ada rilis di GitHub — kamu pakai versi terbaru.')),
    );
  } catch (e) {
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text('Gagal memeriksa: $e')));
  }
}

/// Dialog info update + changelog dari field `body` release.
class _DialogUpdate extends StatelessWidget {
  final InfoUpdate info;
  const _DialogUpdate(this.info);

  @override
  Widget build(BuildContext context) {
    final changelog = info.changelog?.trim() ?? '';
    return AlertDialog(
      title: const Text('Pembaruan tersedia',
          style: TextStyle(fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Versi baru: v${info.versi}'),
          if (changelog.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Catatan rilis', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Text(changelog,
                    style: const TextStyle(fontSize: 14, color: cTeksUtama)),
              ),
            ),
          ],
          if (kIsWeb) ...[
            const SizedBox(height: 16),
            const Text('Download & install pembaruan hanya tersedia di Android.',
                style: TextStyle(fontSize: 12, color: cTeksMuted)),
          ] else if (info.apkUrl == null) ...[
            const SizedBox(height: 16),
            const Text('Belum ada APK di rilis ini.',
                style: TextStyle(fontSize: 12, color: cTeksMuted)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Nanti saja'),
        ),
        if (!kIsWeb && info.apkUrl != null)
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: cBiruVivid, foregroundColor: cPutih),
            onPressed: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.push(
                  MaterialPageRoute(builder: (_) => _DialogUnduh(info.apkUrl!)));
            },
            child: const Text('Download & Install'),
          ),
      ],
    );
  }
}

/// Dialog progres download APK, lalu trigger install (ACTION_VIEW).
class _DialogUnduh extends StatefulWidget {
  final String url;
  const _DialogUnduh(this.url);

  @override
  State<_DialogUnduh> createState() => _DialogUnduhState();
}

class _DialogUnduhState extends State<_DialogUnduh> {
  double _progres = 0;

  @override
  void initState() {
    super.initState();
    _unduh();
  }

  Future<void> _unduh() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await ApkInstaller.unduh(widget.url,
          onProgress: (p) {
        if (mounted) setState(() => _progres = p.clamp(0.0, 1.0));
      });
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('APK siap, membuka installer...')),
      );
      navigator.pop();
      await ApkInstaller.pasang(path);
    } on UnsupportedError {
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Update in-app hanya tersedia di Android.')),
      );
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('Gagal download: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mengunduh APK...',
          style: TextStyle(fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(minHeight: 6, value: _progres),
          const SizedBox(height: 8),
          Text('(${(_progres * 100).round()}%)',
              style: const TextStyle(fontSize: 12, color: cTeksMuted)),
          const SizedBox(height: 8),
          const Text(
            'Setelah selesai, instalernya akan muncul otomatis di HP.',
            style: TextStyle(fontSize: 12, color: cTeksMuted),
          ),
        ],
      ),
    );
  }
}

// Label section (pill biru)
Widget _labelSeksi(String teks) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: cBiruPekat,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      teks,
      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );
}

// Item card
Widget _itemSettings(IconData ikon, String label, {required Widget trailing, VoidCallback? onTap}) {
  final card = Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
      color: cPutih,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
      ],
    ),
    child: Row(
      children: [
        Icon(ikon, size: 24, color: cTeksUtama),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: cTeksUtama, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        trailing,
      ],
    ),
  );
  
  if (onTap != null) {
    return GestureDetector(onTap: onTap, child: card);
  }
  return card;
}

// Button outline
Widget _tombolOutline(String teks) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(color: cTeksUtama, width: 1.2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      teks,
      style: const TextStyle(color: cTeksUtama, fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );
}

// ===== ABOUT PAGE (Tentang Aplikasi — tugas kelompok 2026) =====
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _deskripsi =
      'ResepSimpel adalah aplikasi resep yang memuat 25 resep masakan '
      'sayur Indonesia, disusun untuk membantu pengguna mencari dan '
      'menelusuri hidangan sayur sebagai pilihan menu makanan sehat. '
      'Aplikasi ini dibangun dengan framework Flutter dan dirancang '
      'berbasis kategori bahan serta fitur pencarian resep secara langsung.';

  static const _fitur = [
    'Menelusuri resep berdasarkan kategori bahan (tempe, tahu, telur, sayur)',
    'Pencarian resep secara langsung berdasarkan nama (real-time)',
    'Koleksi 25 resep sayur Indonesia lengkap dengan foto',
    'Informasi versi aplikasi dan pemeriksaan pembaruan',
  ];

  static const _tim = [
    'Alfiansyah',
    'Muhamad Reyhan Fahreza',
    'Muhamad Al-Gifahri',
    'Inggritd Restiana',
    'Yatsmin Dwi Anjani',
    'Ainun Zahra',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cLatar,
      appBar: AppBar(
        backgroundColor: cBiruPekat,
        elevation: 0,
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(color: cPutih, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Identitas aplikasi
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: cPutih,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cBiruTerang,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.restaurant, color: cBiruPekat, size: 30),
                ),
                const SizedBox(height: 8),
                const Text('ResepSimpel', style: TextStyle(color: cBiruPekat, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('v1.0', style: TextStyle(color: cTeksMuted, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _kartuInfo('Deskripsi', _deskripsi),
          const SizedBox(height: 24),
          _kartuInfo('Fitur Aplikasi', _fitur.join('\n'), daftar: true),
          const SizedBox(height: 24),
          _kartuInfo('Dikembangkan oleh', _tim.join('\n'), daftar: true),
          const SizedBox(height: 24),
          const Text(
            'SMK Negeri 1 Karawang — Jurusan TKJ · Kelompok 1',
            style: TextStyle(color: cTeksMuted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Kartu informasi (judul + paragraf, atau judul + list)
Widget _kartuInfo(String judul, String isi, {bool daftar = false}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cPutih,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(judul, style: const TextStyle(color: cBiruPekat, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (daftar)
          Column(
            children: [
              for (final baris in isi.split('\n'))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: cBiruVivid),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(baris, style: const TextStyle(color: cTeksMuted, fontSize: 13, height: 1.35)),
                      ),
                    ],
                  ),
                ),
            ],
          )
        else
          Text(isi, style: const TextStyle(color: cTeksMuted, fontSize: 13, height: 1.45)),
      ],
    ),
  );
}
