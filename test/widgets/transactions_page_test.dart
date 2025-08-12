// test/widgets/transactions_page_test.dart
import 'package:bank_app/data/entity/transaction_model.dart';
import 'package:bank_app/ui/cubit/transactions_cubit.dart';
import 'package:bank_app/ui/view/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionCubit extends Mock implements TransactionCubit {}

void main() {
  late MockTransactionCubit mockCubit;

  setUp(() {
    mockCubit = MockTransactionCubit();

    // initState içinde çağrılan methodu no-op yap
    when(() => mockCubit.getTransactions(any()))
        .thenAnswer((_) async {});

    // BlocProvider create sırasında dinleyeceği için boş bir stream ver
    when(() => mockCubit.stream)
        .thenAnswer((_) => const Stream<TransactionState>.empty());
  });

  Widget makeWidget() {
    return ScreenUtilInit(
      designSize: const Size(412, 732),
      builder: (context, child) {
        return MaterialApp(
          home: BlocProvider<TransactionCubit>.value(
            value: mockCubit,
            child: const TransactionsPage(accountId: 1),
          ),
        );
      },
    );
  }

  testWidgets('Loading state shows CircularProgressIndicator', (tester) async {
    when(() => mockCubit.state).thenReturn(TransactionLoading());

    await tester.pumpWidget(makeWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Error state shows error message', (tester) async {
    when(() => mockCubit.state)
        .thenReturn(TransactionError(message: "Error occurred"));

    await tester.pumpWidget(makeWidget());
    expect(find.text("Error occurred"), findsOneWidget);
  });

  testWidgets('Empty list state shows empty text', (tester) async {
    when(() => mockCubit.state)
        .thenReturn(TransactionLoaded(transactions: []));

    await tester.pumpWidget(makeWidget());
    expect(find.text("There is no any transaction."), findsOneWidget);
  });

  testWidgets('Loaded state shows transactions correctly', (tester) async {
    final mockTransactions = [
      TransactionModel(
        id: 1,
        accountId: 1,
        type: "DEPOSIT",
        description: "Salary",
        amount: 1000,
        createdAt: DateTime.parse("2025-08-12 14:30:00"),
      ),
      TransactionModel(
        id: 2,
        accountId: 1,
        type: "WITHDRAW",
        description: "ATM Withdrawal",
        amount: 200,
        createdAt: DateTime.parse("2025-08-12 16:00:00"),
      ),
    ];

    when(() => mockCubit.state)
        .thenReturn(TransactionLoaded(transactions: mockTransactions));

    await tester.pumpWidget(makeWidget());

    // 1. item
    expect(find.text("DEPOSIT"), findsOneWidget);
    expect(find.text("Salary"), findsOneWidget);
    expect(find.text("+1000.0 TL"), findsOneWidget);

    // 2. item
    expect(find.text("WITHDRAW"), findsOneWidget);
    expect(find.text("ATM Withdrawal"), findsOneWidget);
    expect(find.text("-200.0 TL"), findsOneWidget);
  });
}
