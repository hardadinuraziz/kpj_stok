import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kpj/main.dart';

void main() {
  testWidgets('requires valid credentials before showing dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const KenanApp(enableFirebase: false));

    expect(find.text('Login Akun'), findsOneWidget);
    expect(find.text('Daftar Stok Produk'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'salah');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'salah');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Username atau password salah.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'kenanputrajaya');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'kpj2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Stok Produk'), findsWidgets);
    expect(find.text('Daftar Stok Produk'), findsOneWidget);
    expect(find.text('KRIPIK TEMPE ONE'), findsOneWidget);
  });
}
