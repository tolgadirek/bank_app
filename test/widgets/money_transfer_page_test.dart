// test/widget/money_transfer_page_test.dart
import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/cubit/transactions_cubit.dart';
import 'package:bank_app/ui/view/money_transfer_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockBankAccountsCubit extends MockCubit<BankAccountState>
    implements BankAccountsCubit {}

class MockTransactionCubit extends MockCubit<TransactionState>
    implements TransactionCubit {}

class FakeBankAccountState extends Fake implements BankAccountState {}
class FakeTransactionState extends Fake implements TransactionState {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBankAccountState());
    registerFallbackValue(FakeTransactionState());
  });

  group('MoneyTransferPage widget', () {
    late MockBankAccountsCubit bankCubit;
    late MockTransactionCubit txCubit;

    final accounts = [
      AccountModel(
        id: 7,
        name: 'Main TL',
        accountNumber: '1234567890',
        iban: 'TR00000000000000',
        balance: 2500.75,
        createdAt: DateTime.now(),
      ),
      AccountModel(
        id: 9,
        name: 'Savings',
        accountNumber: '9876543210',
        iban: 'TR00000000000001',
        balance: 5000.00,
        createdAt: DateTime.now(),
      ),
    ];

    Widget makeTestable() {
      return MultiBlocProvider(
        providers: [
          BlocProvider<BankAccountsCubit>.value(value: bankCubit),
          BlocProvider<TransactionCubit>.value(value: txCubit),
        ],
        child: ScreenUtilInit(
          designSize: const Size(412, 732),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return const MaterialApp(
              home: MoneyTransferPage(),
            );
          },
        ),
      );
    }

    setUp(() {
      bankCubit = MockBankAccountsCubit();
      txCubit = MockTransactionCubit();

      // İlk state olarak BankAccountLoaded döndür
      when(() => bankCubit.state)
          .thenReturn(BankAccountLoaded(accounts: accounts));

      // Stream + initialState ayarla
      whenListen(
        bankCubit,
        Stream<BankAccountState>.fromIterable([
          BankAccountLoaded(accounts: accounts),
        ]),
        initialState: BankAccountLoaded(accounts: accounts),
      );

      // validate ve create için varsayılan başarılı davranış
      when(() => txCubit.validateTransactionDetails(
        any(),
        any(),
        any(),
        relatedIban: any(named: 'relatedIban'),
        relatedFirstName: any(named: 'relatedFirstName'),
        relatedLastName: any(named: 'relatedLastName'),
      )).thenAnswer((_) async => true);

      when(() => txCubit.createTransaction(
        any(),
        any(),
        any(),
        relatedIban: any(named: 'relatedIban'),
        relatedFirstName: any(named: 'relatedFirstName'),
        relatedLastName: any(named: 'relatedLastName'),
      )).thenAnswer((_) async {});
    });

    testWidgets('Form alanları render olur ve hesap dropdown’u dolar',
            (tester) async {
          await tester.pumpWidget(makeTestable());
          await tester.pumpAndSettle();

          expect(find.text('Sending Account'), findsWidgets);
          expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
          expect(find.text('Receiver First Name:'), findsOneWidget);
          expect(find.text('Receiver Last Name:'), findsOneWidget);
          expect(find.text('Receiver IBAN:'), findsOneWidget);
          expect(find.text('Amount:'), findsOneWidget);
        });

    testWidgets('Doğrulama hatası: hesap seçilmezse uyarı verir',
            (tester) async {
          await tester.pumpWidget(makeTestable());
          await tester.pumpAndSettle();

          await tester.enterText(
              find.widgetWithText(TextFormField, 'Receiver First Name'), 'Ahmet');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Receiver Last Name'), 'Yılmaz');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Receiver IBAN'),
              'TR0001000200030004');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Amount'), '100');

          await tester.tap(find.text('Send'));
          await tester.pumpAndSettle();

          expect(find.text('Please select an account'), findsOneWidget);
        });

    testWidgets(
        'Hesap seç, formu doldur, onay dialogu açılır ve createTransaction doğru argümanlarla çağrılır',
            (tester) async {
          await tester.pumpWidget(makeTestable());
          await tester.pumpAndSettle();

          // Hesap seç
          await tester.tap(find.byType(DropdownButtonFormField<int>));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Main TL - 2500.75 TL').last);
          await tester.pumpAndSettle();

          // Form doldur
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Receiver First Name'), 'Ayşe');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Receiver Last Name'), 'Kara');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Receiver IBAN'),
              'TR110000000000000000000001');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Amount'), '250');

          // Gönder → onay dialogu
          await tester.tap(find.text('Send'));
          await tester.pumpAndSettle();

          final dialogFinder = find.byType(AlertDialog);

          expect(find.descendant(of: dialogFinder, matching: find.text('Money Transfer')), findsOneWidget);
          expect(find.descendant(of: dialogFinder, matching: find.text('Main TL')), findsOneWidget);
          expect(find.descendant(of: dialogFinder, matching: find.text('Ayşe')), findsOneWidget);
          expect(find.descendant(of: dialogFinder, matching: find.text('Kara')), findsOneWidget);
          expect(find.descendant(of: dialogFinder, matching: find.text('TR110000000000000000000001')), findsOneWidget);
          expect(find.descendant(of: dialogFinder, matching: find.text('250 TL')), findsOneWidget);

          // Dialog içinden "Send"
          await tester.tap(find.widgetWithText(TextButton, 'Send'));
          await tester.pumpAndSettle();

          verify(() => txCubit.createTransaction(
            7,
            'TRANSFER_OUT',
            250.0,
            relatedIban: 'TR110000000000000000000001',
            relatedFirstName: 'Ayşe',
            relatedLastName: 'Kara',
          )).called(1);
        });

    testWidgets('Transaction başarılı olduğunda Success dialogu gösterilir',
            (tester) async {
          await tester.pumpWidget(makeTestable());
          await tester.pumpAndSettle();

          // Hesap seçimi
          await tester.tap(find.byType(DropdownButtonFormField<int>));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Savings - 5000.0 TL').last);
          await tester.pumpAndSettle();

          // Form
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Receiver First Name'), 'Mehmet');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Receiver Last Name'), 'Demir');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Receiver IBAN'),
              'TR220000000000000000000002');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Amount'), '1000');

          // Gönder ve onay
          await tester.tap(find.text('Send'));
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(TextButton, 'Send'));
          await tester.pumpAndSettle();

          // Success dialogu çıkmalı
          expect(find.text('Success'), findsOneWidget);
          expect(find.text('Your transaction has been completed successfully.'),
              findsOneWidget);
        });
  });
}
