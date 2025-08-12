import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bank_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsPage Full Integration Test', () {
    testWidgets(
        'Login → SettingsPage → Bilgileri Güncelle → Log Out → Login Page',
            (tester) async {
          // Uygulamayı başlat
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Login ekranı - email & password gir
          await tester.enterText(
              find.byType(TextFormField).at(0), 'tolga@gmail.com');
          await tester.enterText(find.byType(TextFormField).at(1), '123456');
          await tester.tap(find.text('Log In'));
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // SettingsPage’e git
          await tester.tap(find.text('Settings'));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Form alanlarını güncelle
          await tester.enterText(
              find.widgetWithText(TextFormField, 'First Name'), 'Tolga');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Last Name'), 'Direk');
          await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'),
              '01234567890');

          // Save butonuna bas
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          await tester.tap(find.text("Ok"));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Güncellenmiş veriyi kontrol et
          expect(find.text('Tolga'), findsOneWidget);
          expect(find.text('Direk'), findsOneWidget);
          expect(find.text('01234567890'), findsOneWidget);

          // Log Out butonuna bas
          await tester.tap(find.text('Log Out'));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Login sayfasına dönmüş mü kontrol et
          expect(find.text('Log in'), findsOneWidget);
        });
  });
}
