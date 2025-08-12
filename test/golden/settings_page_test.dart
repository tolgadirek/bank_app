// test/goldens/settings_page_golden_test.dart
import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/ui/cubit/user_info_cubit.dart';
import 'package:bank_app/ui/view/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';

class MockUserInfoCubit extends Mock implements UserInfoCubit {}

void main() {
  late MockUserInfoCubit mockCubit;

  setUpAll(() async {
    await loadAppFonts();
  });

  setUp(() {
    mockCubit = MockUserInfoCubit();

    // initState -> getProfile çağrısı
    when(() => mockCubit.getProfile()).thenAnswer((_) async {});
    // default boş stream
    when(() => mockCubit.stream)
        .thenAnswer((_) => const Stream<UserInfoState>.empty());
  });

  Widget wrapWithShell(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(412, 732),
      minTextAdapt: true,
      builder: (_, __) => MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: BlocProvider<UserInfoCubit>.value(
          value: mockCubit,
          child: child,
        ),
      ),
    );
  }

  testGoldens('SettingsPage - Loading', (tester) async {
    when(() => mockCubit.state).thenReturn(UserInfoLoading());
    await tester.pumpWidgetBuilder(
      wrapWithShell(const SettingsPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'settings_loading',
      customPump: (tester) async => tester.pump(const Duration(milliseconds: 100)),
    );
  });

  testGoldens('SettingsPage - Error', (tester) async {
    when(() => mockCubit.state)
        .thenReturn(UserInfoError(message: 'Network Error'));
    await tester.pumpWidgetBuilder(
      wrapWithShell(const SettingsPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'settings_error',
      customPump: (tester) async => tester.pump(),
    );
  });

  testGoldens('SettingsPage - Success (form filled)', (tester) async {
    final user = UserModel(
      id: 9,
      firstName: 'Tolga',
      lastName: 'Direk',
      email: 'tolga@example.com',
      phoneNumber: '01234567890',
      createdAt: DateTime(2025, 7, 29, 13, 54, 35),
    );

    when(() => mockCubit.state).thenReturn(UserInfoSuccess(user: user));
    when(() => mockCubit.stream)
        .thenAnswer((_) => Stream<UserInfoState>.value(UserInfoSuccess(user: user)));

    await tester.pumpWidgetBuilder(
      wrapWithShell(const SettingsPage()),
      surfaceSize: const Size(412, 732),
    );
    await tester.pump(); // ilk frame

    await screenMatchesGolden(
      tester,
      'settings_success',
      customPump: (tester) async => tester.pump(),
    );
  });
}
