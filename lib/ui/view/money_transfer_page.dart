import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/cubit/transactions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MoneyTransferPage extends StatefulWidget {
  const MoneyTransferPage({super.key});

  @override
  State<MoneyTransferPage> createState() => _MoneyTransferPageState();
}

class _MoneyTransferPageState extends State<MoneyTransferPage> {
  final formKey = GlobalKey<FormState>();
  var tfIban = TextEditingController();
  var tfFirstName = TextEditingController();
  var tfLastName = TextEditingController();
  var tfAmount = TextEditingController();
  int? selectedAccountId;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Trex Bank", style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(2, 165, 165, 1),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sending Account"),
                  BlocBuilder<BankAccountsCubit, BankAccountState>(
                      builder: (context, state) {
                        if (state is BankAccountLoading) {
                          return Center(child: CircularProgressIndicator(),);
                        } else if (state is BankAccountError) {
                          return Center(child: Text(state.message),);
                        } else if (state is BankAccountLoaded) {
                          final accounts = state.accounts;
                          if (accounts.isEmpty) {
                            return Text("You don't have an account");
                          } else {
                            return DropdownButtonFormField(
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Sending Account",
                                border: OutlineInputBorder(borderSide: BorderSide.none,),
                              ),
                              value: selectedAccountId,
                              items: accounts.map((account) {
                                return DropdownMenuItem(
                                  value: account.id,
                                  child: Text("${account.name} - ${account.balance} TL"),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedAccountId = value;
                                });
                              },
                              validator: (value) => value == null ? "Please select an account" : null,
                            );
                          }
                        } else {
                          return Center(child: Text("Failed to Load Data"),);
                        }
                      }
                  ),
                  SizedBox(height: 20.h,),

                  Text("Receiver First Name:"),
                  TextFormField(
                    controller: tfFirstName,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Receiver First Name",
                      border: OutlineInputBorder(borderSide: BorderSide.none,),
                    ),
                    validator: (value) => value == null || value.isEmpty ? "Enter the First Name": null,
                  ),
                  SizedBox(height: 20.h,),

                  Text("Receiver Last Name:"),
                  TextFormField(
                    controller: tfLastName,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Receiver Last Name",
                      border: OutlineInputBorder(borderSide: BorderSide.none,),
                    ),
                    validator: (value) => value == null || value.isEmpty ? "Enter the Last Name": null,
                  ),
                  SizedBox(height: 20.h,),

                  Text("Receiver IBAN:"),
                  TextFormField(
                    controller: tfIban,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Receiver IBAN",
                      border: OutlineInputBorder(borderSide: BorderSide.none,),
                    ),
                    validator: (value) => value == null || value.isEmpty ? "Enter the IBAN": null,
                  ),
                  SizedBox(height: 20.h,),

                  Text("Amount:"),
                  TextFormField(
                    controller: tfAmount,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Amount",
                      border: OutlineInputBorder(borderSide: BorderSide.none,),
                    ),
                    validator: (value) => value == null || value.isEmpty ? "Enter the Amount": null,
                  ),
                  SizedBox(height: 50.h,),

                  //Gönderme Butonu ve doğrulama
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()){
                            try {
                              final isValid = await context.read<TransactionCubit>().validateTransactionDetails(
                                selectedAccountId!,
                                "TRANSFER_OUT",
                                double.parse(tfAmount.text.trim()),
                                relatedIban: tfIban.text.trim(),
                                relatedFirstName: tfFirstName.text.trim(),
                                relatedLastName: tfLastName.text.trim(),
                              );
                              if (isValid) {

                                final accountsState = context.read<BankAccountsCubit>().state;
                                String selectedAccountName = "";

                                if (accountsState is BankAccountLoaded) {
                                  final selectedAccount = accountsState.accounts.firstWhere(
                                        (account) => account.id == selectedAccountId,
                                  );
                                  selectedAccountName = selectedAccount.name;
                                }

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Money Transfer"),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Selected Account: "),
                                              Text(selectedAccountName),
                                              SizedBox(height: 20.h,),

                                              Text("Receiver First Name: "),
                                              Text(tfFirstName.text.trim()),
                                              SizedBox(height: 20.h,),

                                              Text("Receiver Last Name: "),
                                              Text(tfLastName.text.trim()),
                                              SizedBox(height: 20.h,),

                                              Text("Receiver Iban: "),
                                              Text(tfIban.text.trim()),
                                              SizedBox(height: 20.h,),

                                              Text("Amount: "),
                                              Text("${tfAmount.text.trim()} TL"),
                                              SizedBox(height: 20.h,),

                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(onPressed: () async {
                                            Navigator.pop(context);
                                          }, child: Text("Cancel", style: TextStyle(color: Colors.red),)),
                                          TextButton(onPressed: () async {
                                            try {
                                              await context.read<TransactionCubit>().createTransaction(
                                                selectedAccountId!,
                                                "TRANSFER_OUT",
                                                double.parse(tfAmount.text.trim()),
                                                relatedIban: tfIban.text.trim(),
                                                relatedFirstName: tfFirstName.text.trim(),
                                                relatedLastName: tfLastName.text.trim(),
                                              );
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text("Success"),
                                                      content: Text("Your transaction has been completed successfully."),
                                                      actions: [
                                                        TextButton(onPressed: () async {
                                                          await context.read<BankAccountsCubit>().getBankAccounts();
                                                          context.go("/homePage");
                                                        }, child: Text("Ok")),
                                                      ],
                                                    );
                                                  }
                                              );
                                            } catch (e) {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString())),
                                              );
                                            }
                                          }, child: Text("Send", style: TextStyle(color: Colors.green),)),
                                        ],
                                      );
                                    }
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())));
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromRGBO(2, 165, 165, 1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text("Send", style: TextStyle(fontSize: 16.sp),),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
