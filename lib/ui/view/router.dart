import 'package:bank_app/ui/view/accounts_page.dart';
import 'package:bank_app/ui/view/home_page.dart';
import 'package:bank_app/ui/view/user_login_page.dart';
import 'package:bank_app/ui/view/user_register_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: "/login",
  routes: [
    GoRoute(
      path: "/login",
      builder: (context, state) => const UserLoginPage(),
    ),
    GoRoute(
      path: "/register",
      builder: (context, state) => const UserRegisterPage(),
    ),
    GoRoute(
      path: "/homePage",
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: "/accountsPage",
      builder: (context, state) => const AccountsPage(),
    ),
  ]
);