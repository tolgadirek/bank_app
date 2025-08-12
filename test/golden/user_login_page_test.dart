import 'package:bank_app/ui/cubit/user_login_cubit.dart';
import 'package:bank_app/ui/view/user_login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';

class MockUserLoginCubit extends Mock implements UserLoginCubit {}

void main() {
  late MockUserLoginCubit mockCubit;

  setUp(() async {
    await loadAppFonts(); // Golden’larda font sabitleme

    mockCubit = MockUserLoginCubit();

    // İlk state
    when(() => mockCubit.state).thenReturn(UserLoginInitial());

    // Stream stub (boş akış)
    when(() => mockCubit.stream)
        .thenAnswer((_) => const Stream<UserLoginState>.empty());

    // close çağrısı boş
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  Widget _wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(412, 732), // Tasarım boyutu
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: BlocProvider<UserLoginCubit>.value(
          value: mockCubit,
          child: child,
        ),
      ),
    );
  }

  testGoldens('UserLoginPage - Initial', (tester) async {
    when(() => mockCubit.state).thenReturn(UserLoginInitial());

    await tester.pumpWidgetBuilder(
      _wrap(const UserLoginPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'user_login_initial',
      customPump: (tester) async {
        await tester.pump();
      },
    );
  });
}
