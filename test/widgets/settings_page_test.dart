import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/ui/cubit/user_info_cubit.dart';
import 'package:bank_app/ui/view/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockUserInfoCubit extends Mock implements UserInfoCubit {}

class FakeUserInfoState extends Fake implements UserInfoState {}

void main() {
  late MockUserInfoCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(FakeUserInfoState());
  });

  setUp(() {
    mockCubit = MockUserInfoCubit();
    // Varsayılan olarak boş stream dön
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    // initState içinde çağrılacağı için getProfile'ı stub'la
    when(() => mockCubit.getProfile()).thenAnswer((_) async {});
  });

  Widget createTestWidget(UserInfoState state) {
    when(() => mockCubit.state).thenReturn(state);
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(state));

    return ScreenUtilInit(
      designSize: const Size(412, 732),
      minTextAdapt: true,
      builder: (_, __) {
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => BlocProvider<UserInfoCubit>.value(
                value: mockCubit,
                child: const SettingsPage(),
              ),
            ),
            GoRoute(
              path: '/login',
              builder: (_, __) => const Scaffold(body: Text('Login Page')),
            ),
          ],
        );

        return MaterialApp.router(
          routerConfig: router,
        );
      },
    );
  }

  testWidgets('Loading state shows CircularProgressIndicator', (tester) async {
    await tester.pumpWidget(createTestWidget(UserInfoLoading()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Error state shows error message', (tester) async {
    await tester.pumpWidget(
        createTestWidget(UserInfoError(message: 'Error happened')));
    expect(find.text('Error happened'), findsOneWidget);
  });

  testWidgets('Success state fills form fields correctly', (tester) async {
    final user = UserModel(
      id: 1,
      firstName: 'Tolga',
      lastName: 'Direk',
      email: 'tolga@example.com',
      phoneNumber: '01234567890',
      createdAt: DateTime(2025, 1, 1),
    );

    await tester.pumpWidget(createTestWidget(UserInfoSuccess(user: user)));
    await tester.pumpAndSettle();

    expect(find.text('Tolga'), findsOneWidget);
    expect(find.text('Direk'), findsOneWidget);
    expect(find.text('01234567890'), findsOneWidget);
    expect(find.text('tolga@example.com'), findsOneWidget);
    expect(find.text('2025-01-01'), findsOneWidget);
  });

  testWidgets('Save button calls updateUser', (tester) async {
    final user = UserModel(
      id: 1,
      firstName: 'Tolga',
      lastName: 'Direk',
      email: 'tolga@example.com',
      phoneNumber: '01234567890',
      createdAt: DateTime(2025, 1, 1),
    );

    when(() => mockCubit.updateUser(any(), any(), any(), any(),
        password: any(named: 'password')))
        .thenAnswer((_) async {});

    await tester.pumpWidget(createTestWidget(UserInfoSuccess(user: user)));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'), 'Jane');
    await tester.tap(find.text('Save'));
    await tester.pump();

    verify(() => mockCubit.updateUser(
      'tolga@example.com',
      'Jane',
      'Direk',
      '01234567890',
      password: null,
    )).called(1);
  });

  testWidgets('Log Out button navigates to /login', (tester) async {
    final user = UserModel(
      id: 1,
      firstName: 'Mert',
      lastName: 'Soygaz',
      email: 'mert@example.com',
      phoneNumber: '11234567890',
      createdAt: DateTime(2025, 1, 1),
    );

    await tester.pumpWidget(createTestWidget(UserInfoSuccess(user: user)));
    await tester.pumpAndSettle();

    // Log Out butonuna tıkla
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

  });
}
