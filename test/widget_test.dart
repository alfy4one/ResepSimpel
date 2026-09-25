// Smoke test: nav 3 tab + perilaku search (update 2026-09-23):
// daftar dummy selalu tampil (nggak kosong), filter as-you-type TANPA limit.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_resep/main.dart';

void main() {
  testWidgets('app resep: 3 tab, home design, search filter dummy', (tester) async {
    await tester.pumpWidget(const AppResep());

    // tab Home: design penuh (header + hero + 4 kategori)
    expect(find.text('ResepSimpel'), findsOneWidget);
    expect(find.text('Mau masak apa hari ini?'), findsOneWidget);
    expect(find.text('Resep Pilihan untuk Kamu'), findsOneWidget);
    expect(find.text('Tempe'), findsOneWidget);
    expect(find.text('Tahu'), findsOneWidget);
    // Telur/Sayuran di bawah viewport 600px -> scroll dulu (lazy list)
    await tester.scrollUntilVisible(find.text('Sayuran'), 200,
        scrollable: find.byType(Scrollable));
    expect(find.text('Telur'), findsOneWidget);
    expect(find.text('Sayuran'), findsOneWidget);

    // 3 tab nav ada
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // tab Search: daftar resep langsung tampil (nggak kosong, tanpa perlu pencet)
    await tester.tap(find.text('Search'));
    await tester.pump();
    expect(find.text('Sayur Bening Bayam'), findsOneWidget);
    expect(find.text('Capcay'), findsOneWidget); // item ke-4: dulu kepotong limit 3

    // ngetik "tu" -> semua match, tanpa limit 3
    await tester.enterText(find.byType(TextField), 'tu');
    await tester.pump();
    expect(find.text('Tumis Kangkung'), findsOneWidget);
    expect(find.text('Tumis Kol'), findsOneWidget); // match ke-4: dulu terpotong
    expect(find.text('Sayur Asem'), findsNothing); // bukan match

    // lanjut ngetik spesifik -> 1 hasil
    await tester.enterText(find.byType(TextField), 'kangkung');
    await tester.pump();
    expect(find.text('Tumis Kangkung'), findsOneWidget);
    expect(find.text('Tumis Wortel Buncis'), findsNothing);

    // query ga nemu -> empty state
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('Tidak ada resep ditemukan'), findsOneWidget);
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
