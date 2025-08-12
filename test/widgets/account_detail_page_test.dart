import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/ui/cubit/account_detail_cubit.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/view/account_detail_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// --------- Mock'lar
class MockAccountDetailCubit extends MockCubit<AccountDetailState>
    implements AccountDetailCubit {}

class MockBankAccountsCubit extends MockCubit<BankAccountState>
    implements BankAccountsCubit {}

// --------- Fake'ler (registerFallbackValue için)
class FakeAccountDetailState extends Fake implements AccountDetailState {}
class FakeBankAccountState extends Fake implements BankAccountState {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAccountDetailState());
    registerFallbackValue(FakeBankAccountState());
  });

  late MockAccountDetailCubit accountDetailCubit;
  late MockBankAccountsCubit bankAccountsCubit;

  // Basit router
  GoRouter _routerBuilder(Widget child) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => child,
      ),
      GoRoute(
        path: '/homePage',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Home')),
        ),
      ),
      GoRoute(
        path: '/transaction/:id',
        builder: (_, state) => Scaffold(
          body: Center(
              child: Text('Tx for id=${state.pathParameters['id']}')),
        ),
      ),
    ],
  );

  Widget _app(Widget page) {
    return ScreenUtilInit(
      designSize: const Size(412, 732),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MultiBlocProvider(
        providers: [
          BlocProvider<AccountDetailCubit>.value(value: accountDetailCubit),
          BlocProvider<BankAccountsCubit>.value(value: bankAccountsCubit),
        ],
        child: MaterialApp.router(routerConfig: _routerBuilder(page)),
      ),
    );
  }

  AccountModel makeAccount({
    int id = 7,
    String name = 'Main TL',
    String accountNumber = '1234567890',
    String iban = 'TR00000000000000',
    double balance = 2500.75,
    DateTime? createdAt,
    String firstName = 'Tolga',
    String lastName = 'Direk',
    String email = 'tolga@trexbank.test',
  }) {
    createdAt ??= DateTime(2025, 1, 2);

    return AccountModel(
      id: id,
      name: name,
      accountNumber: accountNumber,
      iban: iban,
      balance: balance,
      createdAt: DateTime.parse(createdAt.toIso8601String()),
      user: UserModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        id: id,
        phoneNumber: '55555555555',
        createdAt: createdAt,
      ),
    );
  }

  setUp(() {
    accountDetailCubit = MockAccountDetailCubit();
    bankAccountsCubit = MockBankAccountsCubit();

    // bankAccountsCubit.state hiçbir yerde kullanılmıyor ama null olmasın:
    when(() => bankAccountsCubit.state).thenReturn(FakeBankAccountState());
  });

  //Passed
  testWidgets('Loading state gösteriliyor', (tester) async {
    when(() => accountDetailCubit.state).thenReturn(AccountDetailLoading());
    when(() => accountDetailCubit.getAccountById(any<int>()))
        .thenAnswer((_) async {});

    await tester.pumpWidget(_app(AccountDetailPage(id: 1)));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  //Passed
  testWidgets('Error state mesajı gösteriliyor', (tester) async {
    when(() => accountDetailCubit.state)
        .thenReturn(AccountDetailError(message: 'Boom'));
    when(() => accountDetailCubit.getAccountById(any<int>()))
        .thenAnswer((_) async {});

    await tester.pumpWidget(_app(AccountDetailPage(id: 1)));
    await tester.pump();

    expect(find.text('Boom'), findsOneWidget);
  });

  //Passed
  testWidgets('Loaded state - alanlar ve /transaction navigation',
          (tester) async {
        final acc = makeAccount(id: 7);

        when(() => accountDetailCubit.state)
            .thenReturn(AccountDetailLoaded(account: acc));
        when(() => accountDetailCubit.getAccountById(any<int>()))
            .thenAnswer((_) async {});
        when(() => bankAccountsCubit.deleteAccount(any<int>()))
            .thenAnswer((_) async {});

        await tester.pumpWidget(_app(AccountDetailPage(id: acc.id)));
        await tester.pumpAndSettle();

        expect(find.text('Account Detail'), findsOne);
        expect(find.byKey(const Key('accountNumberTop'),), findsOneWidget);
        expect(find.byKey(const Key('accountNumberInfo'),), findsOneWidget);
        expect(find.text('${acc.balance}'), findsNWidgets(2));
        expect(find.text('${acc.user?.firstName} ${acc.user?.lastName}'),
            findsOne);
        expect(find.text(acc.user?.email ?? ''), findsOne);
        expect(find.text(acc.name), findsOne);
        expect(find.text('Current Account'), findsOne);

        await tester.ensureVisible(find.text('Account Transactions'));
        await tester.tap(find.text('Account Transactions'));
        await tester.pumpAndSettle();

        expect(find.text('Tx for id=${acc.id}'), findsOneWidget);
  });

  //Passed
  testWidgets('Delete - balance > 0 ise "Cannot Delete" diyaloğu', (tester) async {
    final acc = makeAccount(id: 11, balance: 100);

    when(() => accountDetailCubit.state)
        .thenReturn(AccountDetailLoaded(account: acc));
    when(() => accountDetailCubit.getAccountById(any<int>()))
        .thenAnswer((_) async {});
    when(() => bankAccountsCubit.deleteAccount(any<int>()))
        .thenAnswer((_) async {});

    await tester.pumpWidget(_app(AccountDetailPage(id: acc.id)));
    await tester.pumpAndSettle();

    // Önce görünür yap, sonra tıkla
    await tester.ensureVisible(find.text('Delete Account'));
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    expect(find.text('Cannot Delete'), findsOneWidget);
    expect(find.text('This account has a non-zero balance'), findsOneWidget);

    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();

    expect(find.text('Cannot Delete'), findsNothing);
  });

  //Passed
  testWidgets('Delete - balance == 0 ise onay + deleteAccount çağrısı + /homePage',
          (tester) async {
        final acc = makeAccount(id: 12, balance: 0);

        when(() => accountDetailCubit.state)
            .thenReturn(AccountDetailLoaded(account: acc));
        when(() => accountDetailCubit.getAccountById(any<int>()))
            .thenAnswer((_) async {});
        when(() => bankAccountsCubit.deleteAccount(acc.id))
            .thenAnswer((_) async {});

        await tester.pumpWidget(_app(AccountDetailPage(id: acc.id)));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Delete Account'));
        await tester.tap(find.text('Delete Account'));
        await tester.pumpAndSettle();

        expect(find.text('Delete'), findsOne);
        expect(find.text('Delete this account?'), findsOne);

        await tester.tap(find.text('Yes'));
        await tester.pumpAndSettle();

        verify(() => bankAccountsCubit.deleteAccount(acc.id)).called(1);
        expect(find.text('Home'), findsOne);
  });
}
