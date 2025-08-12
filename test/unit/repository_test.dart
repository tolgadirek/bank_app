import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bank_app/data/repo/repository.dart';
import 'package:bank_app/data/entity/user_response_model.dart';
import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/data/entity/account_response_model.dart';
import 'package:bank_app/data/entity/transaction_model.dart';
import 'package:bank_app/data/entity/transaction_response_model.dart';

// Bu dosya build_runner ile üretilecek
import 'repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDio mockDio;       // public requestler (register/login)
  late MockDio mockDioAuth;   // authorized requestler (profile, account, tx)
  late Repository repository;

  setUp(() async {
    // SharedPreferences mock belleği
    SharedPreferences.setMockInitialValues({});

    mockDio = MockDio();
    mockDioAuth = MockDio();

    repository = Repository(
      dio: mockDio,
      authDio: () async => mockDioAuth, // kritik: authorized Dio’yu enjekte ettik
    );
  });

  group('Auth - register', () {
    test('register success returns UserResponseModel and saves token', () async {
      final fakeResponse = Response(
        requestOptions: RequestOptions(path: '/auth/register'),
        statusCode: 200,
        data: {
          "token": "jwt_token_123",
          "user": {
            "id": 1,
            "email": "test@mail.com",
            "firstName": "Tolga",
            "lastName": "Direk",
            "phoneNumber": "5550001122",
            "createdAt": DateTime.now().toIso8601String(),
          }
        },
      );

      when(mockDio.post(
        '/auth/register',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer((_) async => fakeResponse);

      final result = await repository.register(
        "test@mail.com", "123456", "Tolga", "Direk", "5550001122",
      );

      expect(result, isA<UserResponseModel>());
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('token'), equals('jwt_token_123'));
    });

    test('register error throws server message', () async {
      final errorResponse = Response(
        requestOptions: RequestOptions(path: '/auth/register'),
        statusCode: 400,
        data: {"message": "Email already exists"},
      );

      when(mockDio.post(
        '/auth/register',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenThrow(
        DioException.badResponse(
          requestOptions: errorResponse.requestOptions,
          response: errorResponse, statusCode: 400,
        ),
      );

      expect(
            () => repository.register("a@b.com", "123456", "A", "B", "555"),
        throwsA("Email already exists"),
      );
    });
  });

  group('Auth - login', () {
    test('login success returns UserResponseModel and replaces token', () async {
      // ilk önce varmış gibi bir token yazalım
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'old_token');

      final fakeResponse = Response(
        requestOptions: RequestOptions(path: '/auth/login'),
        statusCode: 200,
        data: {
          "token": "new_token_999",
          "user": {
            "id": 2,
            "email": "x@y.com",
            "firstName": "X",
            "lastName": "Y",
            "phoneNumber": "555",
            "createdAt": DateTime.now().toIso8601String(),
          }
        },
      );

      when(mockDio.post(
        '/auth/login',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer((_) async => fakeResponse);

      final result = await repository.login("x@y.com", "123456");
      expect(result, isA<UserResponseModel>());
      expect(prefs.getString('token'), equals('new_token_999'));
    });

    test('login error throws message', () async {
      final errorResponse = Response(
        requestOptions: RequestOptions(path: '/auth/login'),
        statusCode: 401,
        data: {"message": "Invalid credentials"},
      );

      when(mockDio.post(
        '/auth/login',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenThrow(
        DioException.badResponse(
          requestOptions: errorResponse.requestOptions,
          response: errorResponse, statusCode: 400,
        ),
      );

      expect(
            () => repository.login("x@y.com", "wrong"),
        throwsA("Invalid credentials"),
      );
    });
  });

  group('Profile', () {
    test('getprofile returns UserModel', () async {
      final fakeResponse = Response(
        requestOptions: RequestOptions(path: '/auth/profile'),
        statusCode: 200,
        data: {
          "user": {
            "id": 5,
            "email": "pro@mail.com",
            "firstName": "Pro",
            "lastName": "File",
            "phoneNumber": "5551112233",
            "createdAt": DateTime.now().toIso8601String(),
          }
        },
      );

      when(mockDioAuth.get(
        '/auth/profile',
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer((_) async => fakeResponse);

      final result = await repository.getprofile();
      expect(result, isA<UserModel>());
      expect(result!.email, "pro@mail.com");
    });

    test('updateUser returns updated UserModel', () async {
      final fakeResponse = Response(
        requestOptions: RequestOptions(path: '/auth/update'),
        statusCode: 200,
        data: {
          "user": {
            "id": 5,
            "email": "new@mail.com",
            "firstName": "New",
            "lastName": "Name",
            "phoneNumber": "5552223344",
            "createdAt": DateTime.now().toIso8601String(),
          }
        },
      );

      when(mockDioAuth.post(
        '/auth/update',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer((_) async => fakeResponse);

      final result = await repository.updateUser(
        "new@mail.com", "New", "Name", "5552223344",
      );
      expect(result, isA<UserModel>());
      expect(result!.email, "new@mail.com");
    });
  });

  group('Accounts', () {
    test('createBankAccount returns AccountResponseModel', () async {
      final fakeResponse = Response(
        requestOptions: RequestOptions(path: '/account'),
        statusCode: 201,
        data: {
          "status": "Created",
          "account": {
            "id": 10,
            "userId": 5,
            "name": "Main",
            "accountNumber": "1234567890",
            "iban": "TR00011234567890",
            "balance": 0,
            "createdAt": DateTime.now().toIso8601String(),
          }
        },
      );

      when(mockDioAuth.post(
        '/account',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer((_) async => fakeResponse);

      final result = await repository.createBankAccount("Main");
      expect(result, isA<AccountResponseModel>());
      expect(result!.account.name, "Main");
    });

    test('getBankAccounts returns list<AccountModel>', () async {
      final fakeResponse = Response(
        requestOptions: RequestOptions(path: '/account'),
        statusCode: 200,
        data: {
          "accounts": [
            {
              "id": 1, "userId": 5, "name": "A",
              "accountNumber": "111", "iban": "TR000111", "balance": 100.0,
              "createdAt": DateTime.now().toIso8601String(),
            },
            {
              "id": 2, "userId": 5, "name": "B",
              "accountNumber": "222", "iban": "TR000222", "balance": 0.0,
              "createdAt": DateTime.now().toIso8601String(),
            },
          ]
        },
      );

      when(mockDioAuth.get(
        '/account',
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer((_) async => fakeResponse);

      final result = await repository.getBankAccounts();
      expect(result, isA<List<AccountModel>>());
      expect(result.length, 2);
      expect(result[0].name, "A");
    });

    test('getAccountById returns null when not found', () async {
      final fakeResponse = Response(
        requestOptions: RequestOptions(path: '/account/999'),
        statusCode: 200,
        data: {"account": null},
      );

      when(mockDioAuth.get(
        '/account/999',
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer((_) async => fakeResponse);

      final result = await repository.getAccountById(999);
      expect(result, isNull);
    });

    test('deleteAccount returns true on 200', () async {
      final fakeResponse = Response(
        requestOptions: RequestOptions(path: '/account/1'),
        statusCode: 200,
        data: {"status": "OK"},
      );

      when(mockDioAuth.delete(
        '/account/1',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => fakeResponse);

      final ok = await repository.deleteAccount(1);
      expect(ok, isTrue);
    });

    test('deleteAccount throws message on server error', () async {
      final errorResponse = Response(
        requestOptions: RequestOptions(path: '/account/1'),
        statusCode: 400,
        data: {"message": "Cannot delete"},
      );

      when(mockDioAuth.delete(
        '/account/1',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(
        DioException.badResponse(
          requestOptions: errorResponse.requestOptions,
          response: errorResponse, statusCode: 400,
        ),
      );

      expect(() => repository.deleteAccount(1), throwsA("Cannot delete"));
    });
  });

  group('Transactions', () {
    test('validateTransactionDetails returns true on 200', () async {
      final fakeResponse = Response(
        requestOptions: RequestOptions(path: '/transaction/validate'),
        statusCode: 200,
        data: {"ok": true},
      );

      when(mockDioAuth.post(
        '/transaction/validate',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer((_) async => fakeResponse);

      final ok = await repository.validateTransactionDetails(
        1, "DEPOSIT", 100.0,
      );
      expect(ok, isTrue);
    });

    test('createTransaction returns TransactionResponseModel', () async {
      final fakeResponse = Response(
        requestOptions: RequestOptions(path: '/transaction'),
        statusCode: 201,
        data: {
          "status": "Created",
          "transaction": {
            "id": 50,
            "accountId": 1,
            "type": "DEPOSIT",
            "amount": 100.0,
            "description": "Money Deposited",
            "createdAt": DateTime.now().toIso8601String(),
          }
        },
      );

      when(mockDioAuth.post(
        '/transaction',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer((_) async => fakeResponse);

      final result = await repository.createTransaction(1, "DEPOSIT", 100.0);
      expect(result, isA<TransactionResponseModel>());
      expect(result!.transaction.type, "DEPOSIT");
    });

    test('getTransactions returns list<TransactionModel>', () async {
      final fakeResponse = Response(
        requestOptions: RequestOptions(path: '/transaction/1'),
        statusCode: 200,
        data: {
          "transactions": [
            {
              "id": 1, "accountId": 1, "type": "DEPOSIT",
              "amount": 200.0, "description": "Money Deposited",
              "createdAt": DateTime.now().toIso8601String(),
            },
            {
              "id": 2, "accountId": 1, "type": "WITHDRAW",
              "amount": 50.0, "description": "Money withdrawed",
              "createdAt": DateTime.now().toIso8601String(),
            },
          ]
        },
      );

      when(mockDioAuth.get(
        '/transaction/1',
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer((_) async => fakeResponse);

      final result = await repository.getTransactions(1);
      expect(result, isA<List<TransactionModel>>());
      expect(result.length, 2);
      expect(result.first.type, "DEPOSIT");
    });
  });
}
