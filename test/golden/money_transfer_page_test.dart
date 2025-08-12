import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/cubit/transactions_cubit.dart';
import 'package:bank_app/ui/view/money_transfer_page.dart';
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
    when(() => txCubit.validateTransactionDetails(
      any(), any(), any(),
      relatedIban: any(named: 'relatedIban'),
      relatedFirstName: any(named: 'relatedFirstName'),
      relatedLastName: any(named: 'relatedLastName'),
    )).thenAnswer((_) async => true);

    when(() => txCubit.createTransaction(
      any(), any(), any(),
      relatedIban: any(named: 'relatedIban'),
      relatedFirstName: any(named: 'relatedFirstName'),
      relatedLastName: any(named: 'relatedLastName'),
    )).thenAnswer((_) async {});

    // Streams boş; state’i test özelinde set edeceğiz
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
      id: 7,
      name: 'Main TL',
      accountNumber: '1234567890',
      iban: 'TR00000000000000',
      balance: 2500.75,
      createdAt: DateTime.now(),
    ),
    AccountModel(
      id: 11,
      name: 'Savings',
      accountNumber: '9876543210',
      iban: 'TR00000000000001',
      balance: 5000.00,
      createdAt: DateTime.now(),
    ),
  ];

  // --------- GOLDENS ---------

  testGoldens('MoneyTransferPage - Loading (accounts)', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoading());

    await tester.pumpWidgetBuilder(
      _wrap(const MoneyTransferPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'money_transfer_loading',
      customPump: (tester) async => await tester.pump(const Duration(milliseconds: 100)),
    );
  });

  testGoldens('MoneyTransferPage - Error (accounts)', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountError(message: 'Failed to Load Data'));

    await tester.pumpWidgetBuilder(
      _wrap(const MoneyTransferPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'money_transfer_error',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('MoneyTransferPage - No accounts', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoaded(accounts: const []));

    await tester.pumpWidgetBuilder(
      _wrap(const MoneyTransferPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'money_transfer_empty_accounts',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('MoneyTransferPage - Form (accounts loaded, initial)', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoaded(accounts: accounts));

    await tester.pumpWidgetBuilder(
      _wrap(const MoneyTransferPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'money_transfer_form_loaded',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('MoneyTransferPage - Confirm dialog (filled form)', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoaded(accounts: accounts));

    await tester.pumpWidgetBuilder(
      _wrap(const MoneyTransferPage()),
      surfaceSize: const Size(412, 732),
    );
    await tester.pumpAndSettle();

    // Hesap seç
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Main TL - 2500.75 TL').last);
    await tester.pumpAndSettle();

    // Form doldur
    await tester.enterText(find.widgetWithText(TextFormField, 'Receiver First Name'), 'Tolga');
    await tester.enterText(find.widgetWithText(TextFormField, 'Receiver Last Name'), 'Direk');
    await tester.enterText(find.widgetWithText(TextFormField, 'Receiver IBAN'), 'TR110000000000001');
    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '250');
    await tester.pumpAndSettle();

    // Gönder → onay dialogu
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100)); // dialogun mount olmasını bekle

    // Golden: Onay dialogu açık
    await screenMatchesGolden(
      tester,
      'money_transfer_confirm_dialog',
      customPump: (tester) async => await tester.pump(),
    );
  });
}
