import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:bank_app/ui/cubit/user_info_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late UserInfoCubit cubit;
  late MockRepository mockRepo;

  // Örnek kullanıcı
  final user = UserModel(
    id: 1,
    email: 'tolga@gmail.com',
    firstName: 'Tolga',
    lastName: 'Direk',
    phoneNumber: '5551112233',
    createdAt: DateTime.parse('2025-08-01T10:00:00Z'),
  );

  setUp(() {
    mockRepo = MockRepository();
    cubit = UserInfoCubit();
    cubit.repo = mockRepo;
  });

  tearDown(() async {
    await cubit.close();
  });

  group('UserInfoCubit.getProfile', () {
    blocTest<UserInfoCubit, UserInfoState>(
      'success → [Loading, Success(user)]',
      build: () {
        when(() => mockRepo.getprofile()).thenAnswer((_) async => user);
        return cubit;
      },
      act: (c) => c.getProfile(),
      expect: () => [
        isA<UserInfoLoading>(),
        isA<UserInfoSuccess>()
            .having((s) => s.user.id, 'user.id', 1)
            .having((s) => s.user.firstName, 'user.firstName', 'Tolga'),
      ],
      verify: (_) {
        verify(() => mockRepo.getprofile()).called(1);
      },
    );

    // getProfile hata atarsa: Error state emit + throw(string)
    blocTest<UserInfoCubit, UserInfoState>(
      'error → [Loading, Error] ve throw(string)',
      build: () {
        when(() => mockRepo.getprofile()).thenThrow(Exception('Unauthorized'));
        return cubit;
      },
      act: (c) => c.getProfile(),
      expect: () => [
        isA<UserInfoLoading>(),
        isA<UserInfoError>()
            .having((e) => e.message, 'message', contains('An error occurred')),
      ],
      errors: () => [contains('Unauthorized')],
      verify: (_) {
        verify(() => mockRepo.getprofile()).called(1);
      },
    );
  });

  group('UserInfoCubit.updateUser', () {
    // updateUser başarı → getProfile çağrılır → Loading + Success gelir
    blocTest<UserInfoCubit, UserInfoState>(
      'success (update → getProfile zinciri) → [Loading, Success(user)]',
      build: () {
        when(() => mockRepo.updateUser(
          'tolga@gmail.com',
          'Tolga',
          'Direk',
          '5551112233',
          password: null,
        )).thenAnswer((_) async => user);

        when(() => mockRepo.getprofile()).thenAnswer((_) async => user);
        return cubit;
      },
      act: (c) => c.updateUser(
        'tolga@gmail.com',
        'Tolga',
        'Direk',
        '5551112233',
      ),
      expect: () => [
        // updateUser doğrudan state emit etmez; getProfile çağrısı sonucu:
        isA<UserInfoLoading>(),
        isA<UserInfoSuccess>()
            .having((s) => s.user.email, 'user.email', 'tolga@gmail.com'),
      ],
      verify: (_) {
        verify(() => mockRepo.updateUser(
          'tolga@gmail.com',
          'Tolga',
          'Direk',
          '5551112233',
          password: null,
        )).called(1);
        verify(() => mockRepo.getprofile()).called(1);
      },
    );

    // updateUser hata → cubit içinde throw(string); state emit etmez
    blocTest<UserInfoCubit, UserInfoState>(
      'error → throw(string) (state emit edilmez)',
      build: () {
        when(() => mockRepo.updateUser(
          'bad@mail',
          'X',
          'Y',
          '123',
          password: '1',
        )).thenThrow(Exception('Email invalid'));
        return cubit;
      },
      act: (c) => c.updateUser('bad@mail', 'X', 'Y', '123', password: '1'),
      expect: () => <UserInfoState>[], // updateUser kendi başına state yayınlamıyor
      errors: () => [contains('Email invalid')],
      verify: (_) {
        verify(() => mockRepo.updateUser(
          'bad@mail',
          'X',
          'Y',
          '123',
          password: '1',
        )).called(1);
        // getProfile çağrılmamalı
        verifyNever(() => mockRepo.getprofile());
      },
    );
  });
}
