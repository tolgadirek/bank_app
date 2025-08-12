import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/cubit/transactions_cubit.dart';
import 'package:bank_app/ui/view/atm_transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';

// ---- Mocks ----
class MockBankAccountsCubit extends Mock implements BankAccountsCubit {}
class MockTransactionCubit extends Mock implements TransactionCubit {}

void main() {
  late MockBankAccountsCubit bankCubit;
  late MockTransactionCubit txCubit;

  setUpAll(() async {
    await loadAppFonts();
  });

  setUp(() {
    bankCubit = MockBankAccountsCubit();
    txCubit = MockTransactionCubit();

    // initState içinde çağrılanlar → no-op
    when(() => bankCubit.getBankAccounts()).thenAnswer((_) async {});
    when(
          () => txCubit.validateTransactionDetails(
        any(), any(), any(),
        relatedIban: any(named: 'relatedIban'),
        relatedFirstName: any(named: 'relatedFirstName'),
        relatedLastName: any(named: 'relatedLastName'),
      ),
    ).thenAnswer((_) async => true);

    when(
          () => txCubit.createTransaction(
        any(), any(), any(),
        relatedIban: any(named: 'relatedIban'),
        relatedFirstName: any(named: 'relatedFirstName'),
        relatedLastName: any(named: 'relatedLastName'),
      ),
    ).thenAnswer((_) async {});

    // Streams boş
    when(() => bankCubit.stream).thenAnswer((_) => const Stream<BankAccountState>.empty());
    when(() => txCubit.stream).thenAnswer((_) => const Stream<TransactionState>.empty());
  });

  Widget _wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(412, 732),
      builder: (_, __) => MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<BankAccountsCubit>.value(value: bankCubit),
            BlocProvider<TransactionCubit>.value(value: txCubit),
          ],
          child: child,
        ),
      ),
    );
  }

  // ---- Test verisi ----
  final accounts = <AccountModel>[
    AccountModel(
      id: 1,
      name: 'Main TL',
      accountNumber: '1234567890',
      iban: 'TR00000000000000',
      balance: 2500.75,
      createdAt: DateTime.now(),
    ),
    AccountModel(
      id: 2,
      name: 'Savings',
      accountNumber: '9876543210',
      iban: 'TR00000000000001',
      balance: 5000.00,
      createdAt: DateTime.now(),
    ),
  ];

  // --------- GOLDENS ---------

  testGoldens('ATM Transactions - Loading', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoading());

    await tester.pumpWidgetBuilder(
      _wrap(const AtmTransactionsPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'atm_transactions_loading',
      customPump: (tester) async => await tester.pump(const Duration(milliseconds: 100)),
    );
  });

  testGoldens('ATM Transactions - Error', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountError(message: 'Failed to Load Data'));

    await tester.pumpWidgetBuilder(
      _wrap(const AtmTransactionsPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'atm_transactions_error',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('ATM Transactions - Empty accounts', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoaded(accounts: const []));

    await tester.pumpWidgetBuilder(
      _wrap(const AtmTransactionsPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'atm_transactions_empty_accounts',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('ATM Transactions - Form loaded', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoaded(accounts: accounts));

    await tester.pumpWidgetBuilder(
      _wrap(const AtmTransactionsPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'atm_transactions_form_loaded',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('ATM Transactions - Deposit confirm dialog', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoaded(accounts: accounts));

    await tester.pumpWidgetBuilder(
      _wrap(const AtmTransactionsPage()),
      surfaceSize: const Size(412, 732),
    );
    await tester.pumpAndSettle();

    // Hesap seç
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Main TL - 2500.75 TL').last);
    await tester.pumpAndSettle();

    // Miktar gir
    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '500');
    await tester.pumpAndSettle();

    // Deposit butonuna bas
    await tester.tap(find.text('Deposit'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await screenMatchesGolden(
      tester,
      'atm_transactions_deposit_dialog',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('ATM Transactions - Withdraw confirm dialog', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoaded(accounts: accounts));

    await tester.pumpWidgetBuilder(
      _wrap(const AtmTransactionsPage()),
      surfaceSize: const Size(412, 732),
    );
    await tester.pumpAndSettle();

    // Hesap seç
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Savings - 5000.0 TL').last);
    await tester.pumpAndSettle();

    // Miktar gir
    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '300');
    await tester.pumpAndSettle();

    // Withdraw butonuna bas
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await screenMatchesGolden(
      tester,
      'atm_transactions_withdraw_dialog',
      customPump: (tester) async => await tester.pump(),
    );
  });
}
