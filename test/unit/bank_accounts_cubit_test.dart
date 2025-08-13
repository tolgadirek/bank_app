import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/data/entity/account_response_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late BankAccountsCubit cubit;
  late MockRepository mockRepo;

  final acc1 = AccountModel(
    id: 1,
    name: 'Main',
    accountNumber: '1111111111',
    iban: 'TR00011111111111',
    balance: 1000.0,
    createdAt: DateTime.parse('2025-08-01T10:00:00Z'),
    user: null,
  );

  final acc2 = AccountModel(
    id: 2,
    name: 'Savings',
    accountNumber: '2222222222',
    iban: 'TR00012222222222',
    balance: 500.0,
    createdAt: DateTime.parse('2025-08-02T10:00:00Z'),
    user: null,
  );

  AccountResponseModel createdResp(AccountModel a) =>
      AccountResponseModel(status: "Created", account: a);

  setUp(() {
    mockRepo = MockRepository();
    cubit = BankAccountsCubit();
    cubit.repo = mockRepo;
  });

  tearDown(() async {
    await cubit.close();
  });

  group('BankAccountsCubit', () {
    test('initial state', () {
      expect(cubit.state, isA<BankAccountInitial>());
      expect(cubit.currentAccounts, isEmpty);
    });

    blocTest<BankAccountsCubit, BankAccountState>(
      'getBankAccounts success → [Loading, Loaded(list)]',
      build: () {
        when(() => mockRepo.getBankAccounts())
            .thenAnswer((_) async => [acc1, acc2]);
        return cubit;
      },
      act: (c) => c.getBankAccounts(),
      expect: () => [
        isA<BankAccountLoading>(),
        isA<BankAccountLoaded>()
            .having((s) => s.accounts.length, 'len', 2)
            .having((s) => s.accounts.first.id, 'first.id', 1),
      ],
      verify: (_) {
        expect(cubit.currentAccounts.length, 2);
        verify(() => mockRepo.getBankAccounts()).called(1);
      },
    );

    blocTest<BankAccountsCubit, BankAccountState>(
      'getBankAccounts error → [Loading, Error]',
      build: () {
        when(() => mockRepo.getBankAccounts())
            .thenThrow(Exception('db down'));
        return cubit;
      },
      act: (c) => c.getBankAccounts(),
      expect: () => [
        isA<BankAccountLoading>(),
        isA<BankAccountError>()
            .having((e) => e.message, 'message', contains('An error occurred')),
      ],
      verify: (_) {
        verify(() => mockRepo.getBankAccounts()).called(1);
      },
    );

    blocTest<BankAccountsCubit, BankAccountState>(
      'createBankAccount success (başlangıç boş) → [Loaded([acc1])]',
      build: () {
        when(() => mockRepo.createBankAccount('Main'))
            .thenAnswer((_) async => createdResp(acc1));
        return cubit;
      },
      act: (c) => c.createBankAccount('Main'),
      expect: () => [
        isA<BankAccountLoaded>()
            .having((s) => s.accounts.length, 'len', 1)
            .having((s) => s.accounts.first.id, 'first.id', 1),
      ],
      verify: (_) {
        expect(cubit.currentAccounts.length, 1);
        verify(() => mockRepo.createBankAccount('Main')).called(1);
      },
    );

    blocTest<BankAccountsCubit, BankAccountState>(
      'createBankAccount success (liste doluyken append) → [Loaded([acc1, acc2])]',
      build: () {
        cubit.currentAccounts = [acc1]; // mevcut liste dolu başlat
        when(() => mockRepo.createBankAccount('Savings'))
            .thenAnswer((_) async => createdResp(acc2));
        return cubit;
      },
      act: (c) => c.createBankAccount('Savings'),
      expect: () => [
        isA<BankAccountLoaded>()
            .having((s) => s.accounts.length, 'len', 2)
            .having((s) => s.accounts.last.id, 'last.id', 2),
      ],
      verify: (_) {
        expect(cubit.currentAccounts.length, 2);
        verify(() => mockRepo.createBankAccount('Savings')).called(1);
      },
    );

    // bloc_test ile hatayı "errors" matcher'ıyla yakalıyoruz.
    blocTest<BankAccountsCubit, BankAccountState>(
      'createBankAccount throw → errors([contains("boom")])',
      build: () {
        when(() => mockRepo.createBankAccount('X'))
            .thenThrow(Exception('boom'));
        return cubit;
      },
      act: (c) => c.createBankAccount('X'),
      errors: () => [isA<String>().having((s) => s, 'err', contains('boom'))],
      verify: (_) {
        verify(() => mockRepo.createBankAccount('X')).called(1);
      },
    );

    blocTest<BankAccountsCubit, BankAccountState>(
      'deleteAccount success → listedeki öğe silinir ve Loaded yayınlanır',
      build: () {
        cubit.currentAccounts = [acc1, acc2];
        when(() => mockRepo.deleteAccount(1))
            .thenAnswer((_) async => true);
        return cubit;
      },
      act: (c) => c.deleteAccount(1),
      expect: () => [
        isA<BankAccountLoaded>()
            .having((s) => s.accounts.length, 'len', 1)
            .having((s) => s.accounts.single.id, 'remaining.id', 2),
      ],
      verify: (_) {
        expect(cubit.currentAccounts.length, 1);
        expect(cubit.currentAccounts.single.id, 2);
        verify(() => mockRepo.deleteAccount(1)).called(1);
      },
    );

    blocTest<BankAccountsCubit, BankAccountState>(
      'deleteAccount throw → errors([contains("boom")])',
      build: () {
        cubit.currentAccounts = [acc1];
        when(() => mockRepo.deleteAccount(1))
            .thenThrow(Exception('boom'));
        return cubit;
      },
      act: (c) => c.deleteAccount(1),
      errors: () => [isA<String>().having((s) => s, 'err', contains('boom'))],
      verify: (_) {
        // state yayınlanmaz, sadece hata fırlatır
        verify(() => mockRepo.deleteAccount(1)).called(1);
      },
    );
  });
}
