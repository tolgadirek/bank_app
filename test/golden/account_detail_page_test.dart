import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/ui/cubit/account_detail_cubit.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/view/account_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';

// ---- Mocks ----
class MockAccountDetailCubit extends Mock implements AccountDetailCubit {}
class MockBankAccountsCubit extends Mock implements BankAccountsCubit {}

void main() {
  late MockAccountDetailCubit detailCubit;
  late MockBankAccountsCubit bankCubit;

  setUpAll(() async {
    await loadAppFonts();
  });

  setUp(() {
    detailCubit = MockAccountDetailCubit();
    bankCubit = MockBankAccountsCubit();

    when(() => detailCubit.getAccountById(any())).thenAnswer((_) async {});
    when(() => bankCubit.deleteAccount(any())).thenAnswer((_) async {});
    when(() => detailCubit.stream)
        .thenAnswer((_) => const Stream<AccountDetailState>.empty());
    when(() => bankCubit.stream)
        .thenAnswer((_) => const Stream<BankAccountState>.empty());
  });

  Widget _wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(412, 732),
      builder: (_, __) => MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AccountDetailCubit>.value(value: detailCubit),
            BlocProvider<BankAccountsCubit>.value(value: bankCubit),
          ],
          child: child,
        ),
      ),
    );
  }

  final accountWithBalance = AccountModel(
    id: 1,
    name: 'My Account',
    accountNumber: '1234567890',
    iban: 'TR00000000000000',
    balance: 1500.50,
    createdAt: DateTime(2024, 1, 1),
    user: UserModel(
      id: 5,
      email: 'tolga@example.com',
      firstName: 'Tolga',
      lastName: 'Direk',
      phoneNumber: '123456789',
      createdAt: DateTime(2023, 5, 10),
    ),
  );

  final accountZeroBalance = AccountModel(
    id: 1,
    name: 'My Account',
    accountNumber: '1234567890',
    iban: 'TR00000000000000',
    balance: 0,
    createdAt: DateTime(2024, 1, 1),
    user: UserModel(
      id: 5,
      email: 'tolga@example.com',
      firstName: 'Tolga',
      lastName: 'Direk',
      phoneNumber: '123456789',
      createdAt: DateTime(2023, 5, 10),
    ),
  );

  testGoldens('AccountDetailPage - Loading', (tester) async {
    when(() => detailCubit.state).thenReturn(AccountDetailLoading());

    await tester.pumpWidgetBuilder(
      _wrap(const AccountDetailPage(id: 1)),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(tester, 'account_detail_loading',
        customPump: (tester) async =>
        await tester.pump(const Duration(milliseconds: 100)));
  });

  testGoldens('AccountDetailPage - Error', (tester) async {
    when(() => detailCubit.state)
        .thenReturn(AccountDetailError(message: 'Failed to load'));

    await tester.pumpWidgetBuilder(
      _wrap(const AccountDetailPage(id: 1)),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'account_detail_error',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('AccountDetailPage - Loaded', (tester) async {
    when(() => detailCubit.state)
        .thenReturn(AccountDetailLoaded(account: accountWithBalance));

    await tester.pumpWidgetBuilder(
      _wrap(const AccountDetailPage(id: 1)),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'account_detail_loaded',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('AccountDetailPage - Delete Account (Cannot Delete dialog)', (tester) async {
    when(() => detailCubit.state)
        .thenReturn(AccountDetailLoaded(account: accountWithBalance));

    await tester.pumpWidgetBuilder(
      _wrap(const AccountDetailPage(id: 1)),
      surfaceSize: const Size(412, 732),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await screenMatchesGolden(
      tester,
      'account_detail_cannot_delete_dialog',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('AccountDetailPage - Delete Account (Confirm dialog)', (tester) async {
    when(() => detailCubit.state)
        .thenReturn(AccountDetailLoaded(account: accountZeroBalance));

    await tester.pumpWidgetBuilder(
      _wrap(const AccountDetailPage(id: 1)),
      surfaceSize: const Size(412, 732),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await screenMatchesGolden(
      tester,
      'account_detail_confirm_delete_dialog',
      customPump: (tester) async => await tester.pump(),
    );
  });
}
