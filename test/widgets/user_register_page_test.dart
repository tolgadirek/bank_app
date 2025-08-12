import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/data/entity/user_response_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:bank_app/ui/cubit/user_register_cubit.dart';
import 'package:bank_app/ui/view/user_register_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ---- Fake Repository ----
class FakeRepository extends Repository {
  FakeRepository() : super(dio: Dio());

  @override
  Future<UserResponseModel?> register(
      String email, String password, String firstName, String lastName, String phoneNumber) async {
    return UserResponseModel(
      token: 'asdasdasd',
      user: UserModel(
        id: 1,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        createdAt: DateTime(2024, 1, 1),
      ),
    );
  }
}

// ---- Test Cubit ----
class TestRegisterCubit extends UserRegisterCubit {
  int registerCallCount = 0;
  List<String>? lastParams;

  TestRegisterCubit() {
    repo = FakeRepository();
  }

  @override
  Future<void> register(
      String email, String password, String firstName, String lastName, String phoneNumber) async {
    registerCallCount++;
    lastParams = [email, password, firstName, lastName, phoneNumber];
  }
}

// ---- Router wrapper ----
Widget _wrapWithRouterAndBloc(Widget child, TestRegisterCubit cubit) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => ScreenUtilInit(
          designSize: const Size(412, 732),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, _) => BlocProvider<UserRegisterCubit>.value(
            value: cubit,
            child: child,
          ),
        ),
      ),
      GoRoute(
        path: '/homePage',
        builder: (_, __) => const Scaffold(body: Center(child: Text('HOME'))),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  group('UserRegisterPage', () {
    testWidgets('UI elemanları yüklenir', (tester) async {
      final cubit = TestRegisterCubit();
      await tester.pumpWidget(_wrapWithRouterAndBloc(const UserRegisterPage(), cubit));

      expect(find.text('Register').first, findsOneWidget,);
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('Boş form validasyon hatası verir', (tester) async {
      final cubit = TestRegisterCubit();
      await tester.pumpWidget(_wrapWithRouterAndBloc(const UserRegisterPage(), cubit));

      // Butona bas
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Validasyon mesajlarını gör
      expect(find.text('This field is required'), findsNWidgets(5));
    });

    testWidgets('Geçerli kayıt cubit.register çağırır', (tester) async {
      final cubit = TestRegisterCubit();
      await tester.pumpWidget(_wrapWithRouterAndBloc(const UserRegisterPage(), cubit));

      await tester.enterText(find.byType(TextFormField).at(0), 'Tolga');
      await tester.enterText(find.byType(TextFormField).at(1), 'Direk');
      await tester.enterText(find.byType(TextFormField).at(2), '01234567890');
      await tester.enterText(find.byType(TextFormField).at(3), 'tolga@example.com');
      await tester.enterText(find.byType(TextFormField).at(4), '123456');

      // Butona bas ki cubit.register() çalışsın
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(cubit.registerCallCount, 1);
      expect(cubit.lastParams, [
        'tolga@example.com',
        '123456',
        'Tolga',
        'Direk',
        '01234567890',
      ]);
    });

    testWidgets('Register success state gelince /homePage yönlendirmesi yapılır', (tester) async {
      final cubit = TestRegisterCubit();
      await tester.pumpWidget(_wrapWithRouterAndBloc(const UserRegisterPage(), cubit));

      cubit.emit(UserRegisterSuccess(
        user: UserModel(
          id: 1,
          email: 'tolga@example.com',
          firstName: 'Tolga',
          lastName: 'Direk',
          phoneNumber: '01234567890',
          createdAt: DateTime(2024, 1, 1),
        ),
        token: 'asdasdasd',
      ));

      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
    });
  });
}
