import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_resep/main.dart';
import 'package:app_resep/data/resep_data.dart';

void main() {
  testWidgets('HomePage renders without throwing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: const Scaffold(body: HomePage())),
    );
    await tester.pump(); // let first frame settle
    expect(tester.takeException(), isNull,
        reason: 'HomePage threw during build');

    // header + carousel text harusnya ada
    expect(find.text('ResepSimpel'), findsOneWidget);
    expect(find.text('Mau masak apa hari ini?'), findsOneWidget);
    expect(find.text('Resep Pilihan untuk Kamu'), findsOneWidget);

    // tunggu auto-slide timer (4s) + animasi 400ms
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull,
        reason: 'HomePage threw after auto-slide tick');

    // manual swipe kanan
    await tester.drag(find.byType(PageView), const Offset(-200, 0));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull,
        reason: 'HomePage threw after manual swipe');
  });

  test('sanity: data 100 resep + foto path valid', () {
    expect(daftarResep.length, 100);
    for (final r in daftarResep) {
      expect(r.nama, isNotEmpty);
      expect(r.bahan, isNotEmpty);
      expect(r.langkah, isNotEmpty);
      expect(r.fotoPath, isNotNull);
      expect(r.fotoPath!.startsWith('assets/'), isTrue);
    }
  });
}
