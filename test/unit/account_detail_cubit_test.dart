import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:bank_app/ui/cubit/account_detail_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late AccountDetailCubit cubit;
  late MockRepository mockRepo;

  final account = AccountModel(
    id: 10,
    name: 'Main',
    accountNumber: '1234567890',
    iban: 'TR00011234567890',
    balance: 1500.0,
    createdAt: DateTime.parse('2025-08-01T10:00:00Z'),
    user: null,
  );

  setUp(() {
    mockRepo = MockRepository();
    cubit = AccountDetailCubit();
    cubit.repo = mockRepo;
  });

  tearDown(() async {
    await cubit.close();
  });

  group('AccountDetailCubit.getAccountById', () {
    blocTest<AccountDetailCubit, AccountDetailState>(
      'success → [Loading, Loaded]',
      build: () {
        when(() => mockRepo.getAccountById(10))
            .thenAnswer((_) async => account);
        return cubit;
      },
      act: (c) => c.getAccountById(10),
      expect: () => [
        isA<AccountDetailLoading>(),
        isA<AccountDetailLoaded>()
            .having((s) => s.account.id, 'account.id', 10)
            .having((s) => s.account.name, 'account.name', 'Main'),
      ],
      verify: (_) {
        verify(() => mockRepo.getAccountById(10)).called(1);
      },
    );

    blocTest<AccountDetailCubit, AccountDetailState>(
      'null dönerse → [Loading, Error]',
      build: () {
        when(() => mockRepo.getAccountById(99))
            .thenAnswer((_) async => null);
        return cubit;
      },
      act: (c) => c.getAccountById(99),
      expect: () => [
        isA<AccountDetailLoading>(),
        isA<AccountDetailError>()
            .having((e) => e.message, 'message', contains('An error occurred')),
      ],
      verify: (_) {
        verify(() => mockRepo.getAccountById(99)).called(1);
      },
    );

    blocTest<AccountDetailCubit, AccountDetailState>(
      'exception fırlarsa → [Loading, Error]',
      build: () {
        when(() => mockRepo.getAccountById(7))
            .thenThrow(Exception('db down'));
        return cubit;
      },
      act: (c) => c.getAccountById(7),
      expect: () => [
        isA<AccountDetailLoading>(),
        isA<AccountDetailError>()
            .having((e) => e.message, 'message', contains('An error occurred')),
      ],
      verify: (_) {
        verify(() => mockRepo.getAccountById(7)).called(1);
      },
    );
  });
}

