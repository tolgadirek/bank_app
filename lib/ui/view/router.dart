import 'package:bank_app/ui/view/account_detail_page.dart';
import 'package:bank_app/ui/view/accounts_page.dart';
import 'package:bank_app/ui/view/home_page.dart';
import 'package:bank_app/ui/view/money_transfer_page.dart';
import 'package:bank_app/ui/view/transactions_page.dart';
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
    GoRoute(
      path: "/accountDetail/:id",
      builder: (context, state) {
        final id = state.pathParameters["id"];
        return AccountDetailPage(id: int.parse(id!));
      }
    ),
    GoRoute(
        path: "/transaction/:id",
        builder: (context, state) {
          final id = state.pathParameters["id"];
          return TransactionsPage(accountId: int.parse(id!));
        }
    ),
    GoRoute(
        path: "/moneyTransferPage",
        builder: (context, state) => const MoneyTransferPage(),
    ),
  ]
);