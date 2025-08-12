import 'package:bank_app/data/entity/transaction_model.dart';
import 'package:bank_app/ui/cubit/transactions_cubit.dart';
import 'package:bank_app/ui/view/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionCubit extends Mock implements TransactionCubit {}

void main() {
  late MockTransactionCubit mockCubit;

  setUp(() async {
    await loadAppFonts(); // Golden’larda yazı tipini sabitle
    mockCubit = MockTransactionCubit();

    // initState içinde çağrılıyor → no-op
    when(() => mockCubit.getTransactions(any()))
        .thenAnswer((_) async {});

    // Golden sırasında dinlenecek stream → boş
    when(() => mockCubit.stream)
        .thenAnswer((_) => const Stream<TransactionState>.empty());
  });

  Widget _wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(412, 732),
      builder: (_, __) => MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: BlocProvider<TransactionCubit>.value(
          value: mockCubit,
          child: child,
        ),
      ),
    );
  }

  testGoldens('TransactionsPage - Error', (tester) async {
    when(() => mockCubit.state).thenReturn(
      TransactionError(message: 'Network Error'),
    );

    await tester.pumpWidgetBuilder(
      _wrap(const TransactionsPage(accountId: 1)),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'transactions_error',
      customPump: (tester) async {
        await tester.pump(); // tek frame yeter
      },
    );
  });

  testGoldens('TransactionsPage - Empty', (tester) async {
    when(() => mockCubit.state).thenReturn(
      TransactionLoaded(transactions: []),
    );

    await tester.pumpWidgetBuilder(
      _wrap(const TransactionsPage(accountId: 1)),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'transactions_empty',
      customPump: (tester) async {
        await tester.pump();
      },
    );
  });

  testGoldens('TransactionsPage - Loaded', (tester) async {
    final items = [
      TransactionModel(
        id: 1,
        accountId: 1,
        type: 'DEPOSIT',
        amount: 1000,
        description: 'Salary very very long description to test ellipsis',
        createdAt: DateTime.parse('2025-08-12 14:30:00'),
      ),
      TransactionModel(
        id: 2,
        accountId: 1,
        type: 'WITHDRAW',
        amount: 200.5,
        description: 'ATM Withdrawal',
        createdAt: DateTime.parse('2025-08-12 16:00:00'),
      ),
      TransactionModel(
        id: 3,
        accountId: 1,
        type: 'TRANSFER_IN',
        amount: 250,
        description: 'From Savings',
        createdAt: DateTime.parse('2025-08-10 10:00:00'),
      ),
    ];

    when(() => mockCubit.state).thenReturn(
      TransactionLoaded(transactions: items),
    );

    await tester.pumpWidgetBuilder(
      _wrap(const TransactionsPage(accountId: 1)),
      surfaceSize: const Size(412, 732),
    );

    await screenMatchesGolden(
      tester,
      'transactions_loaded',
      customPump: (tester) async {
        await tester.pump();
      },
    );
  });
}
