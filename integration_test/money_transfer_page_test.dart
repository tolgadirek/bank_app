import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bank_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Money Transfer Full Integration', () {
    testWidgets('Login → MoneyTransferPage → Transfer → Success → HomePage', (tester) async {

          // Uygulamayı başlat
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Login ekranında giriş yap
          await tester.enterText(
              find.byType(TextFormField).at(0), 'tolga@gmail.com'); // Email
          await tester.enterText(
              find.byType(TextFormField).at(1), '123456'); // Password
          await tester.tap(find.text('Log In'));
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // HomePage üzerinde "Money Transfer" butonuna git
          await tester.tap(find.text("Money Transfer"));
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Dropdown'dan gönderen hesabı seç
          await tester.tap(find.byType(DropdownButtonFormField<int>));
          await tester.pumpAndSettle();
          await tester.tap(find.textContaining('TL').last);
          await tester.pumpAndSettle();

          // Form alanlarını doldur
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Receiver First Name'), 'Sabit');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Receiver Last Name'), 'Boyoglu');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Receiver IBAN'),
              'TR00019427473628');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Amount'), '250');

          // Gönder butonuna bas → Onay dialogu açılır
          await tester.tap(find.text('Send'));
          await tester.pumpAndSettle();

          expect(find.byType(AlertDialog), findsOneWidget);
          expect(find.text('Money Transfer'), findsOneWidget);

          // Dialog içinden "Send" butonuna bas
          await tester.tap(find.widgetWithText(TextButton, 'Send'));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Success dialogu görünsün
          expect(find.text('Success'), findsOneWidget);
          expect(find.text('Your transaction has been completed successfully.'),
              findsOneWidget);

          // Success dialogunda "Ok" butonuna bas → HomePage’e dön
          await tester.tap(find.widgetWithText(TextButton, 'Ok'));
          await tester.pumpAndSettle(const Duration(seconds: 3));

          expect(find.textContaining('Hello'), findsOneWidget); // HomePage kontrol
    });
  });
}
