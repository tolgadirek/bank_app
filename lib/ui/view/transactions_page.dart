import 'package:bank_app/data/entity/transaction_model.dart';
import 'package:bank_app/ui/cubit/transactions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionsPage extends StatefulWidget {
  final int accountId;
  const TransactionsPage({super.key, required this.accountId});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  
  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().getTransactions(widget.accountId);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trex Bank", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(2, 165, 165, 1),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return Center(child: CircularProgressIndicator(),);
            } else if (state is TransactionError) {
              return Center(child: Text(state.message),);
            } else if (state is TransactionLoaded) {
              final List<TransactionModel> transactions = state.transactions;
              if (transactions.isEmpty) {
                return Center(child: Text("There is no any transaction."),);
              } else {
                return Center();
              }
            } else {
              return Center(child: Text("Failed to Load Data"),);
            }
          }
      ),
    );
  }
}
