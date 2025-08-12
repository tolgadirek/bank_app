import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/cubit/user_info_cubit.dart';
import 'package:bank_app/ui/cubit/user_login_cubit.dart';
import 'package:bank_app/ui/view/home_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserLoginCubit extends MockCubit<UserLoginState>
    implements UserLoginCubit {}

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

class MockBankAccountsCubit extends MockCubit<BankAccountState>
    implements BankAccountsCubit {}

AccountModel makeAccount() {
  return AccountModel(
    id: 7,
    name: 'Main TL',
    accountNumber: '1234567890',
    iban: 'TR00000000000000',
    balance: 2500.75,
    createdAt: DateTime(2025, 1, 2),
    user: UserModel(
      id: 7,
      firstName: 'Tolga',
      lastName: 'Direk',
      email: 'tolga@trexbank.test',
      phoneNumber: '55555555555',
      createdAt: DateTime(2025, 1, 2),
    ),
  );
}

void main() {
  late MockUserLoginCubit mockUserLoginCubit;
  late MockUserInfoCubit mockUserInfoCubit;
  late MockBankAccountsCubit mockBankAccountsCubit;

  setUp(() {
    mockUserLoginCubit = MockUserLoginCubit();
    mockUserInfoCubit = MockUserInfoCubit();
    mockBankAccountsCubit = MockBankAccountsCubit();

    // getBankAccounts() çağrıldığında patlamaması için
    when(() => mockBankAccountsCubit.getBankAccounts())
        .thenAnswer((_) async {});
    when(() => mockUserInfoCubit.getProfile())
        .thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserLoginCubit>.value(value: mockUserLoginCubit),
        BlocProvider<UserInfoCubit>.value(value: mockUserInfoCubit),
        BlocProvider<BankAccountsCubit>.value(value: mockBankAccountsCubit),
      ],
      child: ScreenUtilInit(
        designSize: const Size(4412, 732),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => const MaterialApp(home: HomePage()),
      ),
    );
  }

  testWidgets("HomePage kullanıcı adı ve hesap listesini gösterir", (tester) async {
    // Login cubit state
    when(() => mockUserLoginCubit.state).thenReturn(
      UserLoginSuccess(
        user: UserModel(
          id: 1,
          firstName: "Tolga",
          lastName: "Direk",
          email: "tolga@test.com",
          phoneNumber: "55555555555",
          createdAt: DateTime(2025, 1, 1),
        ),
        token: 'token123',
      ),
    );

    // User info state
    when(() => mockUserInfoCubit.state).thenReturn(
      UserInfoSuccess(
        user: UserModel(
          id: 1,
          firstName: "Tolga",
          lastName: "Direk",
          email: "tolga@test.com",
          phoneNumber: "55555555555",
          createdAt: DateTime(2025, 1, 1),
        ),
      ),
    );

    // Bank accounts state
    when(() => mockBankAccountsCubit.state).thenReturn(
      BankAccountLoaded(accounts: [makeAccount()]),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text("Hello Tolga,"), findsOneWidget);
    expect(find.text("Accounts"), findsOneWidget);
    expect(find.textContaining("Main TL"), findsOneWidget);
    expect(find.text("2500.75 TL"), findsOneWidget);

    expect(find.text("My Accounts"), findsOneWidget);
    expect(find.text("Money Transfer"), findsOneWidget);
    expect(find.text("ATM Transactions"), findsOneWidget);
    expect(find.text("Settings"), findsOneWidget);
  });
}
