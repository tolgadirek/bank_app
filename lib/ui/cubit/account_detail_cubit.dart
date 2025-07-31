import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AccountDetailState {}

class AccountDetailInitial extends AccountDetailState {}

class AccountDetailLoading extends AccountDetailState {}

class AccountDetailLoaded extends AccountDetailState {
  final AccountModel account;
  AccountDetailLoaded({required this.account});
}

class AccountDetailError extends AccountDetailState {
  final String message;
  AccountDetailError({required this.message});
}

class AccountDetailCubit extends Cubit<AccountDetailState> {
  AccountDetailCubit():super(AccountDetailInitial());
  
  var repo = Repository();
  
  Future<void> getAccountById(int id) async {
    emit(AccountDetailLoading());
    try {
      final account = await repo.getAccountById(id);
      if(account != null) {
        emit(AccountDetailLoaded(account: account));
      } else {
        emit(AccountDetailError(message: "An error occurred."));
      }
    } catch (e) {
      emit(AccountDetailError(message: "An error occurred: $e"));
    }
  }
}