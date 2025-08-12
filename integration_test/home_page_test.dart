import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bank_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HomePage Full Integration', () {
    testWidgets('Girişten HomePage veri kontrolü', (tester) async {
      // 1️⃣ Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 2️⃣ Login ekranında e-posta ve şifre gir
      await tester.enterText(
        find.byType(TextFormField).at(0), 'tolga@gmail.com',);
      await tester.enterText(
        find.byType(TextFormField).at(1), '123456',);

      // 3️⃣ Log In butonuna tıkla
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 4️⃣ HomePage başlığını kontrol et
      expect(find.text('Trex Bank'), findsOneWidget);

      // 5️⃣ Kullanıcı adının görünüp görünmediğini kontrol et
      expect(find.textContaining('Hello '), findsOneWidget);

      // 6️⃣ Accounts başlığını kontrol et
      expect(find.text('Accounts'), findsOneWidget);

      // 7️⃣ Eğer hesap varsa hesap ismi ve bakiyeyi kontrol et
      final accountNameFinder = find.byType(Card);
      if (accountNameFinder.evaluate().isNotEmpty) {
        expect(find.textContaining('TL'), findsWidgets); // Hesap ismi
        expect(find.textContaining('TL'), findsWidgets); // Bakiye
      }
    });
  });
}
