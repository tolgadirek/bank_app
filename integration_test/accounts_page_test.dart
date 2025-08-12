import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bank_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AccountsPage Full Integration', () {
    testWidgets('Login → AccountsPage tüm senaryolar', (tester) async {
      // 1️⃣ Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 2️⃣ Login ekranını geç
      await tester.enterText(find.byType(TextFormField).at(0), 'tolga@gmail.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 3️⃣ My Accounts sayfasını aç
      await tester.tap(find.text("My Accounts"));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ✅ UI Eleman Kontrolleri
      expect(find.text('Accounts'), findsOneWidget); // Sayfa başlığı
      expect(find.textContaining('All Accounts'), findsOneWidget); // Kart başlığı
      expect(find.text('Current Accounts'), findsOneWidget); // Bölüm başlığı
      expect(find.text('Avaliable Balance'), findsWidgets); // Hem toplam hem hesapta geçer
      expect(find.byType(Card), findsWidgets); // Kartlar var mı
      expect(find.byType(Divider), findsOneWidget);

      // ✅ Boş liste durumu testi (eğer hiç hesap yoksa)
      if (find.text("You don't have an account.").evaluate().isNotEmpty) {
        expect(find.text("You don't have an account."), findsOneWidget);
        return; // Boşsa buradan bitir
      }

      // ✅ Dolu liste durumu testi
      expect(find.textContaining('TL'), findsWidgets); // Bakiye yazıları
      expect(find.textContaining('All Accounts'), findsOneWidget);
      expect(find.textContaining('Current Accounts'), findsOneWidget);

      // ✅ Navigation testi: ilk hesaba git → geri dön
      final firstAccount = find.byType(Card).at(1); // 0 index All Accounts kartı, 1 index ilk hesap
      await tester.tap(firstAccount);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Hesap detay sayfası kontrolü
      expect(find.text('Account Detail'), findsOneWidget);

      // Geri dön
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Accounts'), findsOneWidget);

    });
  });
}
