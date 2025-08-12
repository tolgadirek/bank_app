import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/view/accounts_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';

// ---- Mocks ----
class MockBankAccountsCubit extends Mock implements BankAccountsCubit {}

void main() {
  late MockBankAccountsCubit bankCubit;

  setUpAll(() async {
    await loadAppFonts();
  });

  setUp(() {
    bankCubit = MockBankAccountsCubit();

    // initState içinde çağrılıyor → no-op
    when(() => bankCubit.getBankAccounts()).thenAnswer((_) async {});

    // Stream boş
    when(() => bankCubit.stream)
        .thenAnswer((_) => const Stream<BankAccountState>.empty());
  });

  Widget _wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(412, 732),
      builder: (_, __) => MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: BlocProvider<BankAccountsCubit>.value(
          value: bankCubit,
          child: child,
        ),
      ),
    );
  }

  // ---- Test verisi ----
  final accounts = <AccountModel>[
    AccountModel(
      id: 1,
      name: 'My Current Account',
      accountNumber: '1111111111',
      iban: 'TR00000000000000',
      balance: 1234.56,
      createdAt: DateTime.now(),
    ),
    AccountModel(
      id: 2,
      name: 'Savings',
      accountNumber: '2222222222',
      iban: 'TR00000000000001',
      balance: 9876.00,
      createdAt: DateTime.now(),
    ),
  ];

  // --------- GOLDENS ---------

  testGoldens('AccountsPage - Loading', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoading());

    await tester.pumpWidgetBuilder(
      _wrap(const AccountsPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'accounts_page_loading',
      customPump: (tester) async =>
      await tester.pump(const Duration(milliseconds: 100)),
    );
  });

  testGoldens('AccountsPage - Error', (tester) async {
    when(() => bankCubit.state)
        .thenReturn(BankAccountError(message: 'Failed to Load Data'));

    await tester.pumpWidgetBuilder(
      _wrap(const AccountsPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'accounts_page_error',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('AccountsPage - Empty accounts', (tester) async {
    when(() => bankCubit.state)
        .thenReturn(BankAccountLoaded(accounts: const []));

    await tester.pumpWidgetBuilder(
      _wrap(const AccountsPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'accounts_page_empty_accounts',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('AccountsPage - Loaded accounts', (tester) async {
    when(() => bankCubit.state)
        .thenReturn(BankAccountLoaded(accounts: accounts));

    await tester.pumpWidgetBuilder(
      _wrap(const AccountsPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'accounts_page_loaded_accounts',
      customPump: (tester) async => await tester.pump(),
    );
  });
}
