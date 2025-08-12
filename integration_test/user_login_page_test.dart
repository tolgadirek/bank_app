import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bank_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UserLoginPage Integration', () {
    testWidgets('Başarılı giriş → HomePage yönlendirme', (tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Kayıt sayfasına git
      await tester.tap(find.text("Become a Costumer"),);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Geri dön
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Email & şifre gir → başarılı kullanıcı bilgilerini koy
      await tester.enterText(find.byType(TextFormField).at(0), 'tolga@gmail.com',);
      await tester.enterText(find.byType(TextFormField).at(1), '123456',);

      // Log In
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // HomePage’e geçtiğini doğrula
      expect(find.textContaining('Hello'), findsOneWidget);
    });



    testWidgets('Hatalı giriş → Snackbar görünür', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text("Settings"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Log Out"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(find.byType(TextFormField).at(0), 'wrong@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');

      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Boş form → validator hataları görünür', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('This field is required'), findsNWidgets(2));
    });
  });
}
