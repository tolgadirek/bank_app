import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/cubit/user_info_cubit.dart';
import 'package:bank_app/ui/cubit/user_login_cubit.dart';
import 'package:bank_app/ui/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';

// ---- Mocks ----
class MockBankAccountsCubit extends Mock implements BankAccountsCubit {}
class MockUserInfoCubit extends Mock implements UserInfoCubit {}
class MockUserLoginCubit extends Mock implements UserLoginCubit {}

void main() {
  late MockBankAccountsCubit bankCubit;
  late MockUserInfoCubit userInfoCubit;
  late MockUserLoginCubit userLoginCubit;

  setUpAll(() async {
    await loadAppFonts();
  });

  setUp(() {
    bankCubit = MockBankAccountsCubit();
    userInfoCubit = MockUserInfoCubit();
    userLoginCubit = MockUserLoginCubit();

    // initState içinde çağrılanlar → no-op
    when(() => bankCubit.getBankAccounts()).thenAnswer((_) async {});
    when(() => userInfoCubit.getProfile()).thenAnswer((_) async {});

    // Streams boş; state’i test özelinde set edeceğiz
    when(() => bankCubit.stream)
        .thenAnswer((_) => const Stream<BankAccountState>.empty());
    when(() => userInfoCubit.stream)
        .thenAnswer((_) => const Stream<UserInfoState>.empty());
    when(() => userLoginCubit.stream)
        .thenAnswer((_) => const Stream<UserLoginState>.empty());

    // HomePage.initState içinde UserLoginCubit.state okunuyor.
    // Başarı durumu gerekmiyor (sayaç sadece Success'ta okunuyor); Initial güvenli.
    when(() => userLoginCubit.state).thenReturn(UserLoginInitial());
  });

  Widget _wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(412, 732),
      builder: (_, __) => MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<BankAccountsCubit>.value(value: bankCubit),
            BlocProvider<UserInfoCubit>.value(value: userInfoCubit),
            BlocProvider<UserLoginCubit>.value(value: userLoginCubit),
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
      name: 'My Current Account 1',
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

  testGoldens('HomePage - Loading (accounts)', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoading());
    // Greeting görünmese de sorun değil; boş bırakıyoruz
    when(() => userInfoCubit.state).thenReturn(UserInfoLoading());

    await tester.pumpWidgetBuilder(
      _wrap(const HomePage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'home_page_loading',
      customPump: (tester) async => await tester.pump(const Duration(milliseconds: 100)),
    );
  });

  testGoldens('HomePage - Error (accounts)', (tester) async {
    when(() => bankCubit.state)
        .thenReturn(BankAccountError(message: 'Failed to Load Data'));
    when(() => userInfoCubit.state).thenReturn(UserInfoLoading());

    await tester.pumpWidgetBuilder(
      _wrap(const HomePage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'home_page_error',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('HomePage - No accounts', (tester) async {
    when(() => bankCubit.state)
        .thenReturn(BankAccountLoaded(accounts: const []));
    when(() => userInfoCubit.state).thenReturn(UserInfoLoading());

    await tester.pumpWidgetBuilder(
      _wrap(const HomePage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'home_page_empty_accounts',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('HomePage - Loaded (accounts list / PageView)', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoaded(accounts: accounts));
    // İstersen burada UserInfoSuccess verip "Hello X" yazısını da yakalayabilirsin.
    // State tipini bilmiyorsak loading bırakmak daha güvenli:
    when(() => userInfoCubit.state).thenReturn(UserInfoLoading());

    await tester.pumpWidgetBuilder(
      _wrap(const HomePage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'home_page_loaded_accounts',
      customPump: (tester) async => await tester.pump(),
    );
  });

  testGoldens('HomePage - "+" add account → AlertDialog shown', (tester) async {
    when(() => bankCubit.state).thenReturn(BankAccountLoaded(accounts: accounts));
    when(() => userInfoCubit.state).thenReturn(UserInfoLoading());

    await tester.pumpWidgetBuilder(
      _wrap(const HomePage()),
      surfaceSize: const Size(412, 732),
    );
    await tester.pumpAndSettle();

    // "+" ikonuna bas
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(const Duration(milliseconds: 100)); // dialogun mount olması için

    await screenMatchesGolden(
      tester,
      'home_page_add_account_dialog',
      customPump: (tester) async => await tester.pump(),
    );
  });
}
