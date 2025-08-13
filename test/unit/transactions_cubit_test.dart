import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/data/entity/transaction_model.dart';
import 'package:bank_app/data/entity/transaction_response_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:bank_app/ui/cubit/transactions_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late TransactionCubit cubit;
  late MockRepository mockRepo;

  // Basit yardımcılar
  TransactionModel tx({
    required int id,
    required int accountId,
    required String type,
    required double amount,
    String description = '',
    DateTime? createdAt,
    AccountModel? related,
  }) {
    return TransactionModel(
      id: id,
      accountId: accountId,
      type: type,
      amount: amount,
      description: description,
      createdAt: createdAt ?? DateTime.parse('2025-08-01T12:00:00Z'),
      relatedAccount: related,
    );
  }

  TransactionResponseModel txResp(TransactionModel m) =>
      TransactionResponseModel(status: 'Success', transaction: m);

  setUp(() {
    mockRepo = MockRepository();
    cubit = TransactionCubit();
    cubit.repo = mockRepo;
  });

  tearDown(() async {
    await cubit.close();
  });

  group('validateTransactionDetails', () {
    test('success → true döner', () async {
      when(() => mockRepo.validateTransactionDetails(10, 'deposit', 100.0,
          relatedIban: null, relatedFirstName: null, relatedLastName: null))
          .thenAnswer((_) async => true);

      final ok = await cubit.validateTransactionDetails(10, 'deposit', 100.0);
      expect(ok, isTrue);
      verify(() => mockRepo.validateTransactionDetails(10, 'deposit', 100.0,
          relatedIban: null, relatedFirstName: null, relatedLastName: null)).called(1);
    });

    test('error → throw (string)', () async {
      when(() => mockRepo.validateTransactionDetails(10, 'withdraw', -5.0,
          relatedIban: null, relatedFirstName: null, relatedLastName: null))
          .thenThrow(Exception('Amount must be > 0'));

      expect(
            () => cubit.validateTransactionDetails(10, 'withdraw', -5.0),
        throwsA(contains('Amount must be > 0')),
      );
      verify(() => mockRepo.validateTransactionDetails(10, 'withdraw', -5.0,
          relatedIban: null, relatedFirstName: null, relatedLastName: null)).called(1);
    });
  });

  group('getTransactions', () {
    blocTest<TransactionCubit, TransactionState>(
      'success → [Loading, Loaded(list)]',
      build: () {
        when(() => mockRepo.getTransactions(10))
            .thenAnswer((_) async => [
          tx(id: 1, accountId: 10, type: 'deposit', amount: 100),
          tx(id: 2, accountId: 10, type: 'withdraw', amount: 50),
        ]);
        return cubit;
      },
      act: (c) => c.getTransactions(10),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>()
            .having((s) => s.transactions.length, 'len', 2)
            .having((s) => s.transactions.first.id, 'first.id', 1),
      ],
      verify: (_) {
        expect(cubit.currentTransactions.length, 2);
        verify(() => mockRepo.getTransactions(10)).called(1);
      },
    );

    blocTest<TransactionCubit, TransactionState>(
      'error → [Loading, Error]',
      build: () {
        when(() => mockRepo.getTransactions(99))
            .thenThrow(Exception('db down'));
        return cubit;
      },
      act: (c) => c.getTransactions(99),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionError>()
            .having((e) => e.message, 'message', contains('Failed to load history')),
      ],
      verify: (_) {
        verify(() => mockRepo.getTransactions(99)).called(1);
      },
    );
  });

  group('createTransaction', () {
    blocTest<TransactionCubit, TransactionState>(
      'success (başlangıç boş) → [Loaded([tx1])]',
      build: () {
        final tx1 = tx(id: 1, accountId: 10, type: 'deposit', amount: 120);
        when(() => mockRepo.createTransaction(10, 'deposit', 120.0,
            relatedIban: null, relatedFirstName: null, relatedLastName: null))
            .thenAnswer((_) async => txResp(tx1));
        return cubit;
      },
      act: (c) => c.createTransaction(10, 'deposit', 120.0),
      expect: () => [
        isA<TransactionLoaded>()
            .having((s) => s.transactions.length, 'len', 1)
            .having((s) => s.transactions.first.id, 'first.id', 1),
      ],
      verify: (_) {
        expect(cubit.currentTransactions.length, 1);
        verify(() => mockRepo.createTransaction(10, 'deposit', 120.0,
            relatedIban: null, relatedFirstName: null, relatedLastName: null)).called(1);
      },
    );

    blocTest<TransactionCubit, TransactionState>(
      'success (liste dolu → append) → [Loaded([tx1, tx2])]',
      build: () {
        final tx1 = tx(id: 1, accountId: 10, type: 'deposit', amount: 120);
        final tx2 = tx(id: 2, accountId: 10, type: 'withdraw', amount: 30);
        cubit.currentTransactions = [tx1];
        when(() => mockRepo.createTransaction(10, 'withdraw', 30.0,
            relatedIban: null, relatedFirstName: null, relatedLastName: null))
            .thenAnswer((_) async => txResp(tx2));
        return cubit;
      },
      act: (c) => c.createTransaction(10, 'withdraw', 30.0),
      expect: () => [
        isA<TransactionLoaded>()
            .having((s) => s.transactions.length, 'len', 2)
            .having((s) => s.transactions.last.id, 'last.id', 2),
      ],
      verify: (_) {
        expect(cubit.currentTransactions.length, 2);
        verify(() => mockRepo.createTransaction(10, 'withdraw', 30.0,
            relatedIban: null, relatedFirstName: null, relatedLastName: null)).called(1);
      },
    );

    // createTransaction catch'te hem Error state emit ediyor hem de throw yapıyor.
    blocTest<TransactionCubit, TransactionState>(
      'error → [TransactionError] ve throw (string)',
      build: () {
        when(() => mockRepo.createTransaction(10, 'transfer_out', 9999.0,
            relatedIban: 'TR...', relatedFirstName: null, relatedLastName: null))
            .thenThrow(Exception('Insufficient balance'));
        return cubit;
      },
      act: (c) => c.createTransaction(10, 'transfer_out', 9999.0,
          relatedIban: 'TR...'),
      expect: () => [
        isA<TransactionError>()
            .having((e) => e.message, 'msg', contains('Transaction could not be created')),
      ],
      errors: () => [contains('Insufficient balance')],
      verify: (_) {
        expect(cubit.currentTransactions, isEmpty);
        verify(() => mockRepo.createTransaction(10, 'transfer_out', 9999.0,
            relatedIban: 'TR...', relatedFirstName: null, relatedLastName: null)).called(1);
      },
    );
  });
}
