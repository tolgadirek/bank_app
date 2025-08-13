import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bank_app/data/repo/repository.dart';
import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/data/entity/user_response_model.dart';
import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/data/entity/account_response_model.dart';
import 'package:bank_app/data/entity/transaction_model.dart';
import 'package:bank_app/data/entity/transaction_response_model.dart';

import 'repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDio mockDio;       // public istekler (register/login)
  late MockDio mockAuthDio;   // authorized istekler (profile/account/tx)
  late Repository repository;

  Map<String, dynamic> userJson({
    int id = 1,
    String email = 'tolga@gmail.com',
    String first = 'Tolga',
    String last = 'Direk',
    String phone = '5551112233',
    String createdAt = '2025-08-01T10:00:00.000Z',
  }) => {
    "id": id,
    "email": email,
    "firstName": first,
    "lastName": last,
    "phoneNumber": phone,
    "createdAt": createdAt,
  };

  Map<String, dynamic> accountJson({
    int id = 10,
    int userId = 1,
    String name = 'Main',
    String iban = 'TR00011234567890',
    String accountNumber = '1234567890',
    String createdAt = '2025-08-01T10:00:00.000Z',
    double balance = 1500.0,
  }) => {
    "id": id,
    "userId": userId,
    "name": name,
    "iban": iban,
    "accountNumber": accountNumber,
    "createdAt": createdAt,
    "balance": balance,
  };

  Map<String, dynamic> transactionJson({
    int id = 100,
    int accountId = 10,
    String type = 'deposit', // deposit | withdraw | transfer_in | transfer_out
    double amount = 250.0,
    String createdAt = '2025-08-02T12:00:00.000Z',
    String? relatedIban = 'TR00018765432100',
    String? relatedFirstName = 'Ali',
    String? relatedLastName = 'Veli',
  }) => {
    "id": id,
    "accountId": accountId,
    "type": type,
    "amount": amount,
    "createdAt": createdAt,
    "relatedIban": relatedIban,
    "relatedFirstName": relatedFirstName,
    "relatedLastName": relatedLastName,
  };

  Response<T> ok<T>(String path, {T? data, int statusCode = 200}) =>
      Response<T>(requestOptions: RequestOptions(path: path), data: data, statusCode: statusCode);

  DioException dioErr(String path, {int code = 400, String msg = "Invalid"}) =>
      DioException(
        requestOptions: RequestOptions(path: path),
        response: Response(requestOptions: RequestOptions(path: path), statusCode: code, data: {"message": msg}),
        type: DioExceptionType.badResponse,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockDio = MockDio();
    mockAuthDio = MockDio();
    repository = Repository(
      dio: mockDio,
      authDio: () async => mockAuthDio,
    );
  });

  group('Auth', () {
    test('register success → token kaydedilir ve UserResponseModel döner', () async {
      when(mockDio.post("/auth/register", data: anyNamed('data'))).thenAnswer((_) async {
        final data = {
          "token": "abc123",
          "user": userJson(),
        };
        return ok("/auth/register", data: data);
      });

      final res = await repository.register("x@y.com", "123456", "Tolga", "Direk", "5551112233");

      expect(res, isA<UserResponseModel>());
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('token'), "abc123");
      expect(res!.user.email, "tolga@gmail.com");
    });

    test('register error (DioException) → message throw', () async {
      when(mockDio.post("/auth/register", data: anyNamed('data')))
          .thenThrow(dioErr("/auth/register", msg: "Email used"));

      expect(
            () => repository.register("x@y.com", "123456", "A", "B", "1"),
        throwsA("Email used"),
      );
    });

    test('login success → eski token silinir, yeni token kaydedilir', () async {
      SharedPreferences.setMockInitialValues({"token": "old_token"});
      when(mockDio.post("/auth/login", data: anyNamed('data'))).thenAnswer((_) async {
        final data = {
          "token": "new_token",
          "user": userJson(),
        };
        return ok("/auth/login", data: data);
      });

      final res = await repository.login("x@y.com", "123456");
      final prefs = await SharedPreferences.getInstance();

      expect(res, isA<UserResponseModel>());
      expect(prefs.getString('token'), "new_token");
      verify(mockDio.post("/auth/login", data: anyNamed('data'))).called(1);
    });

    test('login error (DioException) → message throw', () async {
      when(mockDio.post("/auth/login", data: anyNamed('data')))
          .thenThrow(dioErr("/auth/login", msg: "Wrong credentials"));

      expect(() => repository.login("a", "b"), throwsA("Wrong credentials"));
    });
  });

  group('Profile', () {
    test('getprofile success', () async {
      when(mockAuthDio.get("/auth/profile")).thenAnswer((_) async {
        final data = {"user": userJson()};
        return ok("/auth/profile", data: data);
      });

      final user = await repository.getprofile();
      expect(user, isA<UserModel>());
      expect(user!.firstName, "Tolga");
    });

    test('getprofile error → message throw', () async {
      when(mockAuthDio.get("/auth/profile")).thenThrow(dioErr("/auth/profile", msg: "Unauthorized"));
      expect(() => repository.getprofile(), throwsA("Unauthorized"));
    });

    test('updateUser success', () async {
      when(mockAuthDio.post("/auth/update", data: anyNamed('data'))).thenAnswer((_) async {
        final data = {"user": userJson(first: "Mert", last: "Soygaz")};
        return ok("/auth/update", data: data);
      });

      final u = await repository.updateUser("e", "Mert", "Soygaz", "5");
      expect(u, isA<UserModel>());
      expect(u!.firstName, "Mert");
      expect(u.lastName, "Soygaz");
    });

    test('updateUser error → message throw', () async {
      when(mockAuthDio.post("/auth/update", data: anyNamed('data')))
          .thenThrow(dioErr("/auth/update", msg: "Email invalid"));
      expect(() => repository.updateUser("bad", "A", "B", "5"), throwsA("Email invalid"));
    });
  });

  group('Accounts', () {
    test('createBankAccount success', () async {
      when(mockAuthDio.post("/account", data: anyNamed('data'))).thenAnswer((_) async {
        final data = {
          "status": "Created",
          "account": accountJson(),
        };
        return ok("/account", data: data, statusCode: 201);
      });

      final res = await repository.createBankAccount("Main");
      expect(res, isA<AccountResponseModel>());
      expect(res!.account.name, "Main");
    });

    test('createBankAccount error → message throw', () async {
      when(mockAuthDio.post("/account", data: anyNamed('data')))
          .thenThrow(dioErr("/account", msg: "Name required"));
      expect(() => repository.createBankAccount(""), throwsA("Name required"));
    });

    test('getBankAccounts success → liste maplenir', () async {
      when(mockAuthDio.get("/account")).thenAnswer((_) async {
        final data = {
          "accounts": [accountJson(id: 10), accountJson(id: 11, name: 'Savings')],
        };
        return ok("/account", data: data);
      });

      final list = await repository.getBankAccounts();
      expect(list, isA<List<AccountModel>>());
      expect(list.length, 2);
      expect(list[1].name, 'Savings');
    });

    test('getBankAccounts error → boş liste', () async {
      when(mockAuthDio.get("/account")).thenThrow(Exception('boom'));
      final list = await repository.getBankAccounts();
      expect(list, isEmpty);
    });

    test('getAccountById success', () async {
      when(mockAuthDio.get("/account/10")).thenAnswer((_) async {
        final data = {"account": accountJson(id: 10, name: "Detail")};
        return ok("/account/10", data: data);
      });

      final acc = await repository.getAccountById(10);
      expect(acc, isA<AccountModel>());
      expect(acc!.name, "Detail");
    });

     test('getAccountById not found → null', () async {
      when(mockAuthDio.get("/account/99")).thenAnswer((_) async {
        final data = {"account": null};
        return ok("/account/99", data: data);
      });

      final acc = await repository.getAccountById(99);
      expect(acc, isNull);
    });

    test('getAccountById error → null', () async {
      when(mockAuthDio.get("/account/1")).thenThrow(Exception('db down'));
      final acc = await repository.getAccountById(1);
      expect(acc, isNull);
    });

    test('deleteAccount success → true', () async {
      when(mockAuthDio.delete("/account/10")).thenAnswer((_) async {
        return ok("/account/10", statusCode: 200);
      });

      final okRes = await repository.deleteAccount(10);
      expect(okRes, true);
    });

    test('deleteAccount error → message throw', () async {
      when(mockAuthDio.delete("/account/10"))
          .thenThrow(dioErr("/account/10", code: 500, msg: "Server Error"));
      expect(() => repository.deleteAccount(10), throwsA("Server Error"));
    });
  });

  group('Transactions', () {
    test('validateTransactionDetails success → true', () async {
      when(mockAuthDio.post("/transaction/validate", data: anyNamed('data')))
          .thenAnswer((_) async => ok("/transaction/validate"));

      final okRes = await repository.validateTransactionDetails(
        10, "deposit", 100.0,
        relatedIban: "TR...", relatedFirstName: "Ali", relatedLastName: "Veli",
      );
      expect(okRes, true);
    });

    test('validateTransactionDetails error → message throw', () async {
      when(mockAuthDio.post("/transaction/validate", data: anyNamed('data')))
          .thenThrow(dioErr("/transaction/validate", msg: "Amount must be > 0"));
      expect(
            () => repository.validateTransactionDetails(10, "withdraw", -5),
        throwsA("Amount must be > 0"),
      );
    });

    test('createTransaction success', () async {
      when(mockAuthDio.post("/transaction", data: anyNamed('data'))).thenAnswer((_) async {
        final data = {
          "status": "Success",
          "transaction": transactionJson(),
        };
        return ok("/transaction", data: data, statusCode: 201);
      });

      final res = await repository.createTransaction(10, "deposit", 250.0);
      expect(res, isA<TransactionResponseModel>());
      expect(res!.transaction.amount, 250.0);
    });

    test('createTransaction error → message throw', () async {
      when(mockAuthDio.post("/transaction", data: anyNamed('data')))
          .thenThrow(dioErr("/transaction", msg: "Insufficient balance"));
      expect(
            () => repository.createTransaction(10, "transfer_out", 9999.0, relatedIban: "TR..."),
        throwsA("Insufficient balance"),
      );
    });

    test('getTransactions success → liste maplenir', () async {
      when(mockAuthDio.get("/transaction/10")).thenAnswer((_) async {
        final data = {
          "transactions": [
            transactionJson(id: 1, type: "deposit", amount: 100),
            transactionJson(id: 2, type: "withdraw", amount: 50),
          ]
        };
        return ok("/transaction/10", data: data);
      });

      final list = await repository.getTransactions(10);
      expect(list, isA<List<TransactionModel>>());
      expect(list.length, 2);
      expect(list.first.type, "deposit");
    });

    test('getTransactions error → boş liste', () async {
      when(mockAuthDio.get("/transaction/10")).thenThrow(Exception('down'));
      final list = await repository.getTransactions(10);
      expect(list, isEmpty);
    });
  });
}
