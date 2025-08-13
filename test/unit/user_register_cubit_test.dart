import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/data/entity/user_response_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:bank_app/ui/cubit/user_register_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late UserRegisterCubit cubit;
  late MockRepository mockRepo;

  final user = UserModel(
    id: 1,
    email: 'tolga@gmail.com',
    firstName: 'Tolga',
    lastName: 'Direk',
    phoneNumber: '5551112233',
    createdAt: DateTime.parse('2025-08-01T10:00:00Z'),
  );

  final userResp = UserResponseModel(token: 'abc123', user: user);

  setUp(() {
    mockRepo = MockRepository();
    cubit = UserRegisterCubit();
    cubit.repo = mockRepo;
  });

  tearDown(() async {
    await cubit.close();
  });

  test('initial state', () {
    expect(cubit.state, isA<UserRegisterInitial>());
  });

  blocTest<UserRegisterCubit, UserRegisterState>(
    'register success → [Loading, Success(user, token)]',
    build: () {
      when(() => mockRepo.register(
        'tolga@gmail.com',
        '123456',
        'Tolga',
        'Direk',
        '5551112233',
      )).thenAnswer((_) async => userResp);
      return cubit;
    },
    act: (c) => c.register('tolga@gmail.com', '123456', 'Tolga', 'Direk', '5551112233'),
    expect: () => [
      isA<UserRegisterLoading>(),
      isA<UserRegisterSuccess>()
          .having((s) => s.user.id, 'user.id', 1)
          .having((s) => s.token, 'token', 'abc123'),
    ],
    verify: (_) {
      verify(() => mockRepo.register(
        'tolga@gmail.com',
        '123456',
        'Tolga',
        'Direk',
        '5551112233',
      )).called(1);
    },
  );

  blocTest<UserRegisterCubit, UserRegisterState>(
    'repo null döndürürse → [Loading, Error("An unexpected error occurred")]',
    build: () {
      when(() => mockRepo.register(
        'x@y.com',
        '123456',
        'X',
        'Y',
        '5551112233',
      )).thenAnswer((_) async => null);
      return cubit;
    },
    act: (c) => c.register('x@y.com', '123456', 'X', 'Y', '5551112233'),
    expect: () => [
      isA<UserRegisterLoading>(),
      isA<UserRegisterError>()
          .having((e) => e.message, 'message', 'An unexpected error occurred'),
    ],
    verify: (_) {
      verify(() => mockRepo.register('x@y.com', '123456', 'X', 'Y', '5551112233')).called(1);
    },
  );

  blocTest<UserRegisterCubit, UserRegisterState>(
    'repo error fırlatırsa → [Loading, Error(contains message)]',
    build: () {
      when(() => mockRepo.register(
        'bad@mail',
        '123',
        'A',
        'B',
        '000',
      )).thenThrow(Exception('Email already used'));
      return cubit;
    },
    act: (c) => c.register('bad@mail', '123', 'A', 'B', '000'),
    expect: () => [
      isA<UserRegisterLoading>(),
      isA<UserRegisterError>()
          .having((state) => state.message, 'message', contains('Email already used')),
    ],
    verify: (_) {
      verify(() => mockRepo.register('bad@mail', '123', 'A', 'B', '000')).called(1);
    },
  );
}
