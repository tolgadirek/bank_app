import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/data/entity/transaction_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  TransactionLoaded({required this.transactions});
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError({required this.message});
}

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit():super(TransactionInitial());

  var repo = Repository();
  List<TransactionModel> currentTransactions = [];

  Future<void> createTransaction(
      int accountId, String type, double amount, AccountModel? relatedAccount,
      {String? relatedIban, String? relatedFirstName,String? relatedLastName}) async {
    try{
      final response = await repo.createTransaction(accountId, type, amount, relatedAccount,
      relatedIban: relatedIban, relatedFirtName: relatedFirstName, relatedLastName: relatedLastName);

      if (response != null) {
        currentTransactions = [...currentTransactions, response.transaction];
        emit(TransactionLoaded(transactions: currentTransactions));
      }
    } catch (e) {
      emit(TransactionError(message: "Transaction could not be created: $e"));
    }
  }

  Future<void> getTransactions(int accountId) async {
    emit(TransactionLoading());
    try {
      final transactions = await repo.getTransactions(accountId);
      currentTransactions = transactions;
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(message: "Failed to load history: $e"));
    }
  }
}