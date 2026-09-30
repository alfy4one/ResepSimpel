// Menghasilkan golden PNG ukuran HP (390x844 @3x) untuk preview ke alf.
// Jalankan: flutter test test/screenshots_test.dart --update-goldens
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_resep/main.dart';

Future<void> _masukSearch(WidgetTester tester) async {
  await tester.tap(find.text('Search'));
  // WAJIB pumpAndSettle: ada animasi page transition (fade+slide 300ms).
  // Dulu cuma pump() -> frame Home yang ke-capture, jadi state1/2/3 hasilnya
  // identik dan golden-nya jadi guard mati.
  await tester.pumpAndSettle();
}

void _setViewHP(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  testWidgets('home state 0: design home (header + hero + kategori)', (tester) async {
    _setViewHP(tester);
    await tester.pumpWidget(const AppResep());
    await expectLater(find.byType(AppResep), matchesGoldenFile('goldens/state0.png'));
  });

  // ---- Search states -------------------------------------------------------
  // CATATAN: 3 golden ini dulu identik satu sama lain karena tap Search
  // tidak di-settle (cuma pump()), jadi yang ke-capture frame Home.
  // Guard di bawah (golden bukan duplikat) menjaga supaya tidak terulang.
  testWidgets('search state 1: daftar resep dummy (default)', (tester) async {
    _setViewHP(tester);
    await tester.pumpWidget(const AppResep());
    await _masukSearch(tester);
    await expectLater(find.byType(AppResep), matchesGoldenFile('goldens/state1.png'));
  });

  testWidgets('search state 2: ngetik "tu" (filter)', (tester) async {
    _setViewHP(tester);
    await tester.pumpWidget(const AppResep());
    await _masukSearch(tester);
    await tester.enterText(find.byType(TextField), 'tu');
    await tester.pumpAndSettle();
    await expectLater(find.byType(AppResep), matchesGoldenFile('goldens/state2.png'));
  });

  testWidgets('search state 3: ngetik "kangkung" (1 hasil)', (tester) async {
    _setViewHP(tester);
    await tester.pumpWidget(const AppResep());
    await _masukSearch(tester);
    await tester.enterText(find.byType(TextField), 'kangkung');
    await tester.pumpAndSettle();
    await expectLater(find.byType(AppResep), matchesGoldenFile('goldens/state3.png'));
  });

  testWidgets('settings state 4: design settings (2 seksi + 4 item)', (tester) async {
    _setViewHP(tester);
    await tester.pumpWidget(const AppResep());
    await tester.tap(find.text('Settings'));
    await tester.pump();
    await expectLater(find.byType(AppResep), matchesGoldenFile('goldens/state4.png'));
  });

  testWidgets('about state 5: halaman tentang aplikasi (konten kelompok)', (tester) async {
    _setViewHP(tester);
    await tester.pumpWidget(const AppResep());
    await tester.tap(find.text('Settings'));
    await tester.pump();
    // viewport HP 844px: item "Tentang Aplikasi" masih di atas nav bar, langsung tap
    await tester.tap(find.text('Tentang Aplikasi'));
    await tester.pumpAndSettle();
    await expectLater(find.byType(AppResep), matchesGoldenFile('goldens/state5.png'));
  });

  // Guard: golden basi pernah lolos karena state1/2/3 ketuker file yang sama
  // (commit 8e2143b "hapus chip kategori Search"). Test ini cegah terulang:
  // 3 state Search WAJIB punya isi berbeda satu sama lain.
  test('golden state1/2/3 bukan file duplikat', () {
    final isi = ['state1', 'state2', 'state3']
        .map((s) => File('test/goldens/$s.png').readAsBytesSync())
        .toList();
    expect(isi[1], isNot(equals(isi[0])),
        reason: 'state1 (default) == state2 (ngetik "tu") -> golden duplikat');
    expect(isi[2], isNot(equals(isi[0])),
        reason: 'state1 (default) == state3 (ngetik "kangkung") -> golden duplikat');
    expect(isi[2], isNot(equals(isi[1])),
        reason: 'state2 == state3 -> golden duplikat');
  });

  test('golden Home (state0) beda dari golden Search (state1)', () {
    final home = File('test/goldens/state0.png').readAsBytesSync();
    final search = File('test/goldens/state1.png').readAsBytesSync();
    expect(home, isNot(equals(search)),
        reason: 'Home dan Search harus halaman berbeda');
  });
}
