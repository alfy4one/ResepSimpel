// Smoke test: home design + search filter + chip filter + about
// (update 2026-09-25: data 100 resep Menu.txt, kategori Simpel/Sayuran/Protein/Sehat)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_resep/main.dart';

void main() {
  testWidgets('app resep: home design + search filter', (tester) async {
    await tester.pumpWidget(const AppResep());

    // tab Home: design penuh (header + hero + kategori)
    expect(find.text('ResepSimpel'), findsOneWidget);
    expect(find.text('Mau masak apa hari ini?'), findsOneWidget);
    expect(find.text('Resep Pilihan untuk Kamu'), findsOneWidget);
    expect(find.text('Simpel'), findsOneWidget);
    expect(find.text('Sayuran'), findsOneWidget);
    // Scroll ke bawah: drag ListView utama langsung (halaman home cuma
    // punya 1 ListView; carousel PageView di dalam ListView ga bisa di-drag
    // sebagai target scroll-nya sendiri)
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.text('Sehat'), findsOneWidget);
    expect(find.text('Protein'), findsOneWidget);

    // 3 tab nav ada
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // tab Search: daftar resep langsung tampil (nggak kosong, tanpa perlu pencet)
    await tester.tap(find.text('Search'));
    await tester.pump();
    expect(find.text('Tempe Orek'), findsOneWidget); // item ke-1 data 100 resep
    expect(find.text('Langkah: Semua'), findsOneWidget);
    expect(find.text('Bahan tertentu'), findsOneWidget);

    // ngetik spesifik -> 1 hasil, match NAMA saja
    await tester.enterText(find.byType(TextField), 'kangkung');
    await tester.pump();
    expect(find.text('Tumis Kangkung'), findsOneWidget);
    expect(find.text('Tempe Orek'), findsNothing);

    // query ga nemu -> empty state
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('Tidak ada resep ditemukan'), findsOneWidget);
  });

  testWidgets('filter chips berfungsi: dialog bahan tertentu tersaring', (tester) async {
    await tester.pumpWidget(const AppResep());
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    // Chip "Bahan tertentu" -> dialog
    await tester.tap(find.text('Bahan tertentu'));
    await tester.pumpAndSettle();
    expect(find.text('Tampilkan resep yang memuat bahan tertentu'), findsOneWidget);

    // aktifkan filter bahan + isi "kangkung"
    await tester.tap(find.text('Tampilkan resep yang memuat bahan tertentu'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'kangkung');
    await tester.pump();

    // terapkan -> hasil tersaring
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    expect(find.text('Tumis Kangkung'), findsOneWidget);
    expect(find.text('Tumis Kangkung Telur Orak-Arik'), findsOneWidget);
    expect(find.text('Tempe Orek'), findsNothing);
    expect(find.text('Bahan: kangkung'), findsOneWidget); // label chip aktif
  });

  testWidgets('tentang aplikasi: navigasi + konten kelompok', (tester) async {
    await tester.pumpWidget(const AppResep());

    // masuk Settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // scroll ke item terakhir
    await tester.scrollUntilVisible(find.text('Tentang Aplikasi'), 100,
        scrollable: find.byType(Scrollable));
    // geser lagi: scrollUntilVisible berhenti pas item nyentuh viewport,
    // posisinya bisa ketimpa NavigationBar (tap-nya jadi kena nav, bukan card)
    await tester.drag(find.byType(Scrollable), const Offset(0, -80));
    await tester.pumpAndSettle();

    // tap item "Tentang Aplikasi"
    await tester.tap(find.text('Tentang Aplikasi'));
    await tester.pumpAndSettle();

    // About page berhasil dibuka
    expect(find.widgetWithText(AppBar, 'Tentang Aplikasi'), findsOneWidget);

    // Scroll + assert nama tim
    final scaffold = find.byType(Scaffold).last;
    await tester.dragUntilVisible(
      find.text('Alfiansyah'),
      scaffold,
      const Offset(0, -50),
    );
    expect(find.text('Alfiansyah'), findsOneWidget);
    expect(find.text('Ainun Zahra'), findsOneWidget);
  });
}
