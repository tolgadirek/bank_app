import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/view/accounts_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockBankAccountsCubit extends Mock implements BankAccountsCubit {}
class FakeBankAccountState extends Fake implements BankAccountState {}

void main() {
  late MockBankAccountsCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(FakeBankAccountState());
  });

  setUp(() {
    mockCubit = MockBankAccountsCubit();
  });

  Widget createTestWidget(BankAccountState state) {
    when(() => mockCubit.state).thenReturn(state);
    whenListen(mockCubit, Stream<BankAccountState>.fromIterable([state]));
    when(() => mockCubit.getBankAccounts()).thenAnswer((_) async {});

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => BlocProvider<BankAccountsCubit>.value(
            value: mockCubit,
            child: const AccountsPage(),
          ),
        ),
        GoRoute(
          path: '/accountDetail/:id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return Scaffold(body: Text('Detail Page $id'));
          },
        ),
      ],
    );

    return ScreenUtilInit(
      designSize: const Size(412, 732),
      minTextAdapt: true,
      splitScreenMode: true,
        builder: (context, child) {
        return MaterialApp.router(routerConfig: router);
        },
    );
  }

  testWidgets('Loading state shows CircularProgressIndicator', (tester) async {
    await tester.pumpWidget(createTestWidget(BankAccountLoading()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Error state shows error message', (tester) async {
    await tester.pumpWidget(createTestWidget(
      BankAccountError(message: 'Error occurred'),
    ));
    expect(find.text('Error occurred'), findsOneWidget);
  });

  testWidgets('Loaded state shows account list and total balance', (tester) async {
    final accounts = [
      AccountModel(
        id: 1,
        name: 'Main',
        accountNumber: '123',
        balance: 100.0,
        iban: 'TR00',
        createdAt: DateTime(2025, 1, 2),
      ),
      AccountModel(
        id: 2,
        name: 'Savings',
        accountNumber: '456',
        balance: 200.0,
        iban: 'TR01',
        createdAt: DateTime(2025, 1, 2),
      ),
    ];

    await tester.pumpWidget(createTestWidget(
      BankAccountLoaded(accounts: accounts),
    ));

    expect(find.text('All Accounts (2)'), findsOneWidget);
    expect(find.text('300.0 TL'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Savings'), findsOneWidget);
  });

  testWidgets('Tapping account navigates to detail page', (tester) async {
    final accounts = [
      AccountModel(
        id: 1,
        name: 'Main',
        accountNumber: '123',
        balance: 100.0,
        iban: 'TR00',
        createdAt: DateTime(2025, 1, 2),
      ),
    ];

    await tester.pumpWidget(createTestWidget(
      BankAccountLoaded(accounts: accounts),
    ));

    await tester.tap(find.text('Main'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Page 1'), findsOneWidget);
  });
}
