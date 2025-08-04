import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/cubit/transactions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AtmTransactionsPage extends StatefulWidget {
  const AtmTransactionsPage({super.key});

  @override
  State<AtmTransactionsPage> createState() => _AtmTransactionsPageState();
}

class _AtmTransactionsPageState extends State<AtmTransactionsPage> {
  final formKey = GlobalKey<FormState>();
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
                  Text("Account"),
                  BlocBuilder<BankAccountsCubit, BankAccountState>(
                      builder: (context, state) {
                        if (state is BankAccountLoading) {
                          return Center(child: CircularProgressIndicator(),);
                        } else if (state is BankAccountError) {
                          return Center(child: Text(state.message),);
                        } else if (state is BankAccountLoaded) {
                          final accounts = state.accounts;
                          if (accounts.isEmpty){
                            return Text("You don't have an account.");
                          } else {
                            return DropdownButtonFormField(
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Account",
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

                  Text("Amount:"),
                  TextFormField(
                    controller: tfAmount,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Amount",
                        border: OutlineInputBorder(borderSide: BorderSide.none)
                    ),
                    validator: (value) => value == null || value.isEmpty ? "Please Enter the Amount": null,
                  ),

                  SizedBox(height: 100.h,),

                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromRGBO(2, 165, 165, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            final isValid  = await context.read<TransactionCubit>().validateTransactionDetails(
                                selectedAccountId!,
                                "DEPOSIT",
                                double.parse(tfAmount.text.trim()),
                            );

                            if(isValid) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Deposit"),
                                      content: Text("Are you sure you want to deposit ${tfAmount.text.trim()} TL?"),
                                      actions: [
                                        TextButton(onPressed: () {Navigator.pop(context);}, child: Text("No")),
                                        TextButton(onPressed: () async {
                                          try {
                                            await context.read<TransactionCubit>().createTransaction(
                                              selectedAccountId!,
                                              "DEPOSIT",
                                              double.parse(tfAmount.text.trim()),
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
                                        }, child: Text("Yes")),
                                      ],
                                    );
                                  }
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                      child: Text("Deposit", style: TextStyle(fontSize: 16.sp),),
                    ),
                  ),

                  SizedBox(height: 10.h,),

                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromRGBO(2, 165, 165, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            final isValid  = await context.read<TransactionCubit>().validateTransactionDetails(
                              selectedAccountId!,
                              "WITHDRAW",
                              double.parse(tfAmount.text.trim()),
                            );

                            if(isValid) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Withdraw"),
                                      content: Text("Are you sure you want to withdraw ${tfAmount.text.trim()} TL?"),
                                      actions: [
                                        TextButton(onPressed: () {Navigator.pop(context);}, child: Text("No")),
                                        TextButton(onPressed: () async {
                                          try {
                                            await context.read<TransactionCubit>().createTransaction(
                                              selectedAccountId!,
                                              "WITHDRAW",
                                              double.parse(tfAmount.text.trim()),
                                            );
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context)  {
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
                                        }, child: Text("Yes")),
                                      ],
                                    );
                                  }
                              );
                            }

                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                      child: Text("Withdraw", style: TextStyle(fontSize: 16.sp),),
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
