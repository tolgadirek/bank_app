import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bank_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full Integration: Login → Accounts → Account Detail → TransactionsPage', (tester) async {
    // Uygulamayı başlat
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Login
    await tester.enterText(find.byType(TextFormField).at(0), 'tolga@gmail.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Accounts sayfasına git
    await tester.tap(find.text("Account Transactions ➔").first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // TransactionsPage doğrulaması
    expect(find.text('Trex Bank'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Hata yok
    expect(find.textContaining('Error'), findsNothing);

    // Boş mesaj mı?
    final emptyFinderByKey = find.byKey(const ValueKey('transactions_empty'));
    final emptyFinderByText = find.text('There is no any transaction.');
    final isEmptyShown = emptyFinderByKey.evaluate().isNotEmpty || emptyFinderByText.evaluate().isNotEmpty;

    // En az bir işlem tutarı yazısı var mı? (örn: +1000 TL, +1000.0 TL, -200 TL, -200,00 TL)
    final amountLikeFinder = find.byWidgetPredicate((w) {
      if (w is Text) {
        final s = (w.data ?? '').trim();
        return RegExp(r'^[\+\-]?\d{1,3}([.,]?\d{3})*([.,]\d+)?\s*TL$').hasMatch(s);
      }
      return false;
    });
    final hasAnyAmount = amountLikeFinder.evaluate().isNotEmpty;

    expect(isEmptyShown || hasAnyAmount, true,
        reason: 'TransactionsPage’de ne boş mesaj ne de herhangi bir işlem tutarı bulunamadı.');
  });
}
