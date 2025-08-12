import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bank_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ATM Transactions Full Integration', () {
    testWidgets('Login → ATM Transactions tüm senaryolar', (tester) async {
      // 1️⃣ Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 2️⃣ Login ekranını geç
      await tester.enterText(find.byType(TextFormField).at(0), 'tolga@gmail.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 3️⃣ ATM Transactions sayfasına git
      await tester.tap(find.text('ATM Transactions'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 4️⃣ Eğer hiç hesap yoksa
      if (find.text("You don't have an account.").evaluate().isNotEmpty) {
        expect(find.text("You don't have an account."), findsOneWidget);
        return;
      }

      // 5️⃣ Deposit akışı
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('TL').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '150');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Deposit'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.widgetWithText(TextButton, 'Yes').hitTestable());
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Success'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Ok'));
      await tester.pumpAndSettle(const Duration(seconds: 1));


      // 6️⃣ Withdraw akışı
      await tester.tap(find.text('ATM Transactions'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('TL').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '200');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Withdraw'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.widgetWithText(TextButton, 'Yes').hitTestable());
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Success'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Ok'));
      await tester.pumpAndSettle(const Duration(seconds: 1));


      // 7️⃣ Validation testi (amount boş olursa)
      await tester.tap(find.text('ATM Transactions'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('TL').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Deposit'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Please Enter the Amount'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
