import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruzgar_gunlugu/main.dart';

void main() {
  testWidgets('Ana ekran açılıyor ve temel widgetlar doğru', (
    WidgetTester tester,
  ) async {
    // Uygulamayı başlat
    await tester.pumpWidget(RuzgarGunluguApp());

    // AppBar başlığı var mı?
    expect(find.text('Rüzgar Günlüğü'), findsOneWidget);

    // FloatingActionButton var mı?
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Dummy listede 3 kart var mı?
    expect(find.byType(Card), findsNWidgets(3));

    // Her kartın başlık ve note kısmı doğru mu kontrol (opsiyonel)
    expect(find.text('Ayvalık'), findsOneWidget);
    expect(find.text('Rüzgar çok tatlıydı'), findsOneWidget);
  });
}
