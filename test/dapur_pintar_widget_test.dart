import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_resep/main.dart';
import 'package:app_resep/pages/dapur_pintar_page.dart';

Widget _app() => const MaterialApp(home: DapurPintarPage());

void main() {
  testWidgets('kosong: header + prompt', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Belum ada bahan dipilih'), findsOneWidget);
    expect(find.text('Pilih minimal satu bahan di bawah.'), findsOneWidget);
  });

  testWidgets('pilih bahan → jumlah hasil muncul', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('bawang putih'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada bahan dipilih'), findsNothing);
    expect(find.textContaining('resep cocok'), findsOneWidget);
  });

  testWidgets('hasil list bisa di-scroll tanpa overflow', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('bawang putih'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('reset → balik kosong (tombol di summary bar atas)', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('bawang putih'));
    await tester.pumpAndSettle();
    expect(find.textContaining('resep cocok'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Reset'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada bahan dipilih'), findsOneWidget);
    expect(find.textContaining('resep cocok'), findsNothing);
  });

  testWidgets('Home punya entry Dapur Pintar yang bisa dibuka', (tester) async {
    await tester.pumpWidget(const AppResep());
    await tester.pumpAndSettle();
    expect(find.text('Dapur Pintar'), findsWidgets);
    await tester.tap(find.text('Mau masak? Pilih bahan yang ada di dapurmu'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih bahan yang ada di dapurmu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
