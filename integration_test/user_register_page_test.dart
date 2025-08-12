import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bank_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UserRegisterPage Integration', () {
    testWidgets('Başarılı kayıt → HomePage yönlendirme', (tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Kayıt sayfasına git
      await tester.tap(find.text("Become a Costumer"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Formu doldur
      await tester.enterText(find.byType(TextFormField).at(0), 'Tolga');
      await tester.enterText(find.byType(TextFormField).at(1), 'Direk');
      await tester.enterText(find.byType(TextFormField).at(2), '01234567890');
      await tester.enterText(find.byType(TextFormField).at(3), 'tolga@trex.com');
      await tester.enterText(find.byType(TextFormField).at(4), '123456');

      // Kayıt ol
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // HomePage’e geçtiğini doğrula
      expect(find.textContaining('Hello'), findsOneWidget);
    });

    testWidgets('Boş form → validator hataları görünür', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text("Settings"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Log Out"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text("Become a Costumer"));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('This field is required'), findsNWidgets(5));
    });
  });
}
