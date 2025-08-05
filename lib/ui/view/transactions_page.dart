import 'package:bank_app/data/entity/transaction_model.dart';
import 'package:bank_app/ui/cubit/transactions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                return Padding(
                  padding: EdgeInsets.all(15.r),
                  child: ListView.builder(
                    itemCount: transactions.length,
                      itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(transaction.type, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),),
                                  Text(transaction.description, style: TextStyle(fontSize: 16.sp),),
                                  SizedBox(height: 10.h,),
                                  Text("${transaction.createdAt}".split(".")[0], style: TextStyle(fontSize: 16.sp),),
                                ],
                              ),
                              Text(getAmountText(transaction),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: getAmountColor(transaction)),)
                            ],
                          ),
                          Divider(),
                        ],

                      );
                      }
                  ),
                );
              }
            } else {
              return Center(child: Text("Failed to Load Data"),);
            }
          }
      ),
    );
  }
}

String getAmountText(TransactionModel transaction) {
  switch (transaction.type) {
    case "DEPOSIT":
    case "TRANSFER_IN":
      return "+${transaction.amount} TL";
    case "WITHDRAW":
    case "TRANSFER_OUT":
      return "-${transaction.amount} TL";
    default:
      return "${transaction.amount} TL";
  }
}

Color getAmountColor(TransactionModel transaction) {
  switch (transaction.type) {
    case "DEPOSIT":
    case "TRANSFER_IN":
      return Colors.green;
    case "WITHDRAW":
    case "TRANSFER_OUT":
      return Colors.red;
    default:
      return Colors.black;
  }
}