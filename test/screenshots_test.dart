// Menghasilkan golden PNG ukuran HP (390x844 @3x) untuk preview ke alf.
// Jalankan: flutter test test/screenshots_test.dart --update-goldens
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_resep/main.dart';

Future<void> _masukSearch(WidgetTester tester) async {
  await tester.tap(find.text('Search'));
  await tester.pump();
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
    await tester.pump();
    await expectLater(find.byType(AppResep), matchesGoldenFile('goldens/state2.png'));
  });

  testWidgets('search state 3: ngetik "kangkung" (1 hasil)', (tester) async {
    _setViewHP(tester);
    await tester.pumpWidget(const AppResep());
    await _masukSearch(tester);
    await tester.enterText(find.byType(TextField), 'kangkung');
    await tester.pump();
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
}
