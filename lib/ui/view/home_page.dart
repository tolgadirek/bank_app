import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/cubit/user_login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var sayac = 1;
  @override
  void initState() {
    super.initState();
    final loginState = context.read<UserLoginCubit>().state;
    if (loginState is UserLoginSuccess) {
      final userId = loginState.user.id.toString();
      loadSayac(userId);
    }
    context.read<BankAccountsCubit>().getBankAccounts();
  }

  // Sayaçı SharedPreferences'tan yükle
  Future<void> loadSayac(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sayac = prefs.getInt('sayac_$userId') ?? 1;
    });
  }

  // Sayaçı kaydet
  Future<void> incrementSayac(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sayac++;
    });
    await prefs.setInt('sayac_$userId', sayac);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.r),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Accounts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),),
                  // Account Add button
                  IconButton(onPressed: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Create an Account"),
                          content: const Text("Are you sure you want to create an account?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              }, child: const Text("No",),
                            ),

                            TextButton(
                              onPressed: () async {
                                context.read<BankAccountsCubit>().createBankAccount("My Current Account $sayac");
                                final loginState = context.read<UserLoginCubit>().state;
                                if (loginState is UserLoginSuccess) {
                                  final userId = loginState.user.id.toString();
                                  await incrementSayac(userId);
                                }
                                Navigator.pop(context);
                              }, child: const Text("Yes",),
                            ),
                          ],
                        );
                      },
                    );
                  }, icon: Icon(Icons.add, color: Color.fromRGBO(2, 165, 165, 1),))
                ],
              ),
              Divider(),
              SizedBox(height: 10.h,),
              BlocBuilder<BankAccountsCubit, BankAccountState>(
                  builder: (context, state) {
                    if (state is BankAccountLoading) {
                      return Center(child: CircularProgressIndicator(),);
                    } else if (state is BankAccountError) {
                      return Center(child: Text(state.message),);
                    } else if (state is BankAccountLoaded) {
                      final List<AccountModel> accounts = state.accounts;

                      return SizedBox(
                        height: 200.h,
                        child: accounts.isEmpty
                            ? const Center(
                          child: Text("You don't have an account."),
                        )
                            : PageView.builder(
                          itemCount: accounts.length,
                          controller: PageController(viewportFraction: 0.95),
                          itemBuilder: (context, index) {
                            final account = accounts[index];
                            return GestureDetector(
                              onTap: () {
                                context.push("/accountDetail/${account.id}");
                              },
                              child: Card(
                                elevation: 4,
                                child: Padding(
                                  padding: EdgeInsets.all(15.r),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text("${account.name} - ", style: TextStyle(fontSize: 15.sp, color: Colors.grey),),
                                          Text(account.accountNumber, style: TextStyle(fontSize: 15.sp, color: Colors.grey),),
                                        ],
                                      ),
                                      SizedBox(height: 15.h,),
                                      Text("Balance", style: TextStyle(fontSize: 16.sp),),
                                      Text("${account.balance} TL", style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),),
                                      // Account Transactions button
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: TextButton(onPressed: (){
                                          context.push("/transaction/${account.id}");
                                        }, child: Text("Account Transactions ➔", style: TextStyle(color: Color.fromRGBO(2, 165, 165, 1),),)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(child: Text("Failed to Load Data"),);
                    }
                  }
              ),
              SizedBox(height: 20.h,),
              // Accounts Button
              SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      context.push("/accountsPage");
                    },
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text("My Accounts", style: TextStyle(color: Color.fromRGBO(2, 165, 165, 1),),),
                  )
              ),

              //Money Transfer Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    context.push("/moneyTransferPage");
                  },
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text("Money Transfer", style: TextStyle(color: Color.fromRGBO(2, 165, 165, 1),),),
                )
              ),

              // ATM Transactions Button
              SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      context.push("/atmTransactionsPage");
                    },
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text("ATM Transactions", style: TextStyle(color: Color.fromRGBO(2, 165, 165, 1),),),
                  )
              ),

              // Settings Button
              SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      context.push("/settingsPage");
                    },
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text("Settings", style: TextStyle(color: Color.fromRGBO(2, 165, 165, 1),),),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
