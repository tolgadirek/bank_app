import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/data/entity/user_response_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:bank_app/ui/cubit/user_login_cubit.dart';
import 'package:bank_app/ui/view/user_login_page.dart';
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
  Future<UserResponseModel?> login(String email, String password) async {
    // Test için sadece dummy data dönüyoruz
    return UserResponseModel(
      token: 'asdasdasd',
      user: UserModel(
        id: 1,
        email: 'tolga@example.com',
        firstName: 'Tolga',
        lastName: 'Direk',
        phoneNumber: '0000000000',
        createdAt: DateTime(2024, 1, 1),
      ),
    );
  }
}

// ---- Test Cubit ----
class TestLoginCubit extends UserLoginCubit {
  int loginCallCount = 0;
  String? lastEmail;
  String? lastPassword;

  TestLoginCubit() {
    // repo'yu sahte repo ile değiştiriyoruz
    repo = FakeRepository();
  }

  @override
  Future<void> login(String email, String password) async {
    loginCallCount++;
    lastEmail = email;
    lastPassword = password;
    // Gerçek login çalıştırmak istemezsek burayı boş bırakabiliriz
  }
}

// ---- Router wrapper ----
Widget _wrapWithRouterAndBloc(Widget child, TestLoginCubit cubit) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => ScreenUtilInit(
          designSize: const Size(412, 732), // tasarım boyutunu projeninize göre ayarlayın
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, _) => BlocProvider<UserLoginCubit>.value(
            value: cubit,
            child: child,
          ),
        ),
      ),
      GoRoute(
        path: '/homePage',
        builder: (_, __) => const Scaffold(body: Center(child: Text('HOME'))),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const Scaffold(body: Center(child: Text('REGISTER'))),
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

void main() {
  group('UserLoginPage', () {
    testWidgets('UI elemanları yüklenir', (tester) async {
      final cubit = TestLoginCubit();
      await tester.pumpWidget(_wrapWithRouterAndBloc(const UserLoginPage(), cubit));

      expect(find.text('Trex Bank'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Become a Costumer'), findsOneWidget);
    });

    testWidgets('Boş form validasyon hatası verir', (tester) async {
      final cubit = TestLoginCubit();
      await tester.pumpWidget(_wrapWithRouterAndBloc(const UserLoginPage(), cubit));

      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('This field is required'), findsNWidgets(2));
    });

    testWidgets('Geçerli girişte cubit.login çağrılır', (tester) async {
      final cubit = TestLoginCubit();
      await tester.pumpWidget(_wrapWithRouterAndBloc(const UserLoginPage(), cubit));

      await tester.enterText(find.byType(TextFormField).at(0), 'tolga@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(cubit.loginCallCount, 1);
      expect(cubit.lastEmail, 'tolga@example.com');
      expect(cubit.lastPassword, '123456');
    });

    testWidgets('Login success state gelince /homePage yönlendirmesi yapılır', (tester) async {
      final cubit = TestLoginCubit();
      await tester.pumpWidget(_wrapWithRouterAndBloc(const UserLoginPage(), cubit));

      cubit.emit(UserLoginSuccess(
        user: UserModel(
          id: 1,
          email: 'tolga@example.com',
          firstName: 'Tolga',
          lastName: 'Direk',
          phoneNumber: '0000000000',
          createdAt: DateTime(2024, 1, 1),
        ),
        token: 'asdasdasd',
      ));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
    });
  });
}
