import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bank_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AccountDetailPage Integration', () {
    testWidgets('Transactions navigation & delete dialog', (tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login ekranını geç
      await tester.enterText(find.byType(TextFormField).at(0), 'tolga@gmail.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle(const Duration(seconds: 3)); // API bekle

      // PageView içinde sağa kaydır
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // İlgili hesabı tıkla
      final accountFinder = find.textContaining('My Current Account 3');
      expect(accountFinder, findsOneWidget); // Önce var mı kontrol et
      await tester.tap(accountFinder);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Account Detail sayfasını doğrula
      expect(find.text('Account Detail'), findsOneWidget);

      // Transactions butonuna git (spesifik scrollable hedefle)
      await tester.scrollUntilVisible(
        find.text('Account Transactions'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Account Transactions'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Geri dön
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Delete Account butonuna git (spesifik scrollable hedefle)
      await tester.scrollUntilVisible(
        find.text('Delete Account'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Dialog kontrolü
      expect(find.text('Cannot Delete'), findsOneWidget);
      expect(find.text('This account has a non-zero balance'), findsOneWidget);

      // Dialogu kapat
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();
      expect(find.text('Cannot Delete'), findsNothing);
    });
  });
}
