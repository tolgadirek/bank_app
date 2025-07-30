import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BankAccountState {}

class BankAccountInitial extends BankAccountState {}

class BankAccountLoading extends BankAccountState {}

class BankAccountLoaded extends BankAccountState {
  final List<AccountModel> accounts;
  BankAccountLoaded({required this.accounts});
}

class BankAccountError extends BankAccountState {
  final String message;
  BankAccountError({required this.message});
}

class BankAccountsCubit extends Cubit<BankAccountState> {
  BankAccountsCubit():super(BankAccountInitial());

  var repo = Repository();
  List<AccountModel> currentAccounts = [];

  Future<void> createBankAccount(String name) async {
    try {
      final response = await repo.createBankAccount(name);
      if(response != null) {
        currentAccounts = [...currentAccounts, response.account];
        emit(BankAccountLoaded(accounts: currentAccounts));
      }
    } catch (e) {
      emit(BankAccountError(message: "Hesap oluşturulamadı: $e"));
    }
  }

  Future<void> getBankAccounts() async {
    emit(BankAccountLoading());
    try {
      final accounts = await repo.getBankAccounts();
      currentAccounts = accounts;
      emit(BankAccountLoaded(accounts: accounts));
    } catch (e) {
      emit(BankAccountError(message: "Hesaplar getirilemedi: $e"));
    }
  }
}