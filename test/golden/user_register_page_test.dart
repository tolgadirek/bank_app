import 'package:bank_app/ui/cubit/user_register_cubit.dart';
import 'package:bank_app/ui/view/user_register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRegisterCubit extends Mock implements UserRegisterCubit {}

void main() {
  late MockUserRegisterCubit mockCubit;

  setUp(() async {
    await loadAppFonts(); // Golden’larda font sabitleme

    mockCubit = MockUserRegisterCubit();

    // Varsayılan ilk state
    when(() => mockCubit.state).thenReturn(UserRegisterInitial());

    // Stream stub (boş akış)
    when(() => mockCubit.stream)
        .thenAnswer((_) => const Stream<UserRegisterState>.empty());

    // close() çağrısını stubla
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  Widget _wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(412, 732), // Tasarım boyutu
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: BlocProvider<UserRegisterCubit>.value(
          value: mockCubit,
          child: child,
        ),
      ),
    );
  }

  testGoldens('UserRegisterPage - Initial', (tester) async {
    when(() => mockCubit.state).thenReturn(UserRegisterInitial());

    await tester.pumpWidgetBuilder(
      _wrap(const UserRegisterPage()),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'user_register_initial',
      customPump: (tester) async {
        await tester.pump();
      },
    );
  });
}
