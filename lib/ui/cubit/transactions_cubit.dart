import 'package:bank_app/data/entity/transaction_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:bank_app/data/services/dio_service.dart';
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

  var repo = Repository(dio: DioService.dio);
  List<TransactionModel> currentTransactions = [];

  Future<bool> validateTransactionDetails(
      int accountId,
      String type,
      double amount,
      {String? relatedIban, String? relatedFirstName, String? relatedLastName,}) async {
    try {
      final result = await repo.validateTransactionDetails(
        accountId,
        type,
        amount,
        relatedIban: relatedIban,
        relatedFirstName: relatedFirstName,
        relatedLastName: relatedLastName,
      );
      return result;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> createTransaction(
      int accountId, String type, double amount,
      {String? relatedIban, String? relatedFirstName, String? relatedLastName,}) async {
    try{
      final response = await repo.createTransaction(
        accountId, type, amount,
        relatedIban: relatedIban,
        relatedFirstName: relatedFirstName,
        relatedLastName: relatedLastName,);

      if (response != null) {
        currentTransactions = [...currentTransactions, response.transaction];
        emit(TransactionLoaded(transactions: currentTransactions));
      }
    } catch (e) {
      emit(TransactionError(message: "Transaction could not be created: $e"));
      throw e.toString();
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