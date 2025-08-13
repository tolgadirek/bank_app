import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/data/entity/user_response_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:bank_app/ui/cubit/user_login_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late UserLoginCubit cubit;
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
    cubit = UserLoginCubit();
    cubit.repo = mockRepo;
  });

  tearDown(() async {
    await cubit.close();
  });

  test('initial state', () {
    expect(cubit.state, isA<UserLoginInitial>());
  });

  blocTest<UserLoginCubit, UserLoginState>(
    'login success → [Loading, Success(user, token)]',
    build: () {
      when(() => mockRepo.login('tolga@gmail.com', '123456'))
          .thenAnswer((_) async => userResp);
      return cubit;
    },
    act: (c) => c.login('tolga@gmail.com', '123456'),
    expect: () => [
      isA<UserLoginLoading>(),
      isA<UserLoginSuccess>()
          .having((s) => s.user.id, 'user.id', 1)
          .having((s) => s.token, 'token', 'abc123'),
    ],
    verify: (_) {
      verify(() => mockRepo.login('tolga@gmail.com', '123456')).called(1);
    },
  );

  blocTest<UserLoginCubit, UserLoginState>(
    'repo null döndürürse → [Loading, Error("An unexpected error occurred")]',
    build: () {
      when(() => mockRepo.login('x@y.com', 'pwd'))
          .thenAnswer((_) async => null);
      return cubit;
    },
    act: (c) => c.login('x@y.com', 'pwd'),
    expect: () => [
      isA<UserLoginLoading>(),
      isA<UserLoginError>()
          .having((e) => e.message, 'message', 'An unexpected error occurred'),
    ],
    verify: (_) {
      verify(() => mockRepo.login('x@y.com', 'pwd')).called(1);
    },
  );

  blocTest<UserLoginCubit, UserLoginState>(
    'repo error fırlatırsa → [Loading, Error(e.toString())]',
    build: () {
      when(() => mockRepo.login('bad@mail', 'wrong'))
          .thenThrow(Exception('Wrong credentials'));
      return cubit;
    },
    act: (c) => c.login('bad@mail', 'wrong'),
    expect: () => [
      isA<UserLoginLoading>(),
      isA<UserLoginError>()
          .having((e) => e.message, 'message', contains('Wrong credentials')),
    ],
    verify: (_) {
      verify(() => mockRepo.login('bad@mail', 'wrong')).called(1);
    },
  );
}
