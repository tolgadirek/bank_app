import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {

  @override
  void initState() {
    super.initState();
    context.read<BankAccountsCubit>().getBankAccounts();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Accounts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.sp),),
              SizedBox(height: 30.h,),
              BlocBuilder<BankAccountsCubit, BankAccountState>(
                  builder: (context, state) {
                    if (state is BankAccountLoading) {
                      return Center(child: CircularProgressIndicator(),);
                    } else if (state is BankAccountError) {
                      return Center(child: Text(state.message),);
                    } else if (state is BankAccountLoaded) {
                      final List<AccountModel> accounts = state.accounts;

                      if (accounts.isEmpty) {
                        return Center(child: Text("You don't have an account."),);
                      } else {
                        // Toplam bakiyeyi hesapla
                        double totalBalance = accounts.fold(0.0, (sum, item) => sum + item.balance);
                        int totalAccount = accounts.length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(15.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("All Accounts ($totalAccount)", style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Avaliable Balance", style: TextStyle(fontSize: 16.sp, color: Colors.grey),),
                                        Text("$totalBalance TL", style: TextStyle(fontSize: 16.sp, color: Colors.grey),),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h,),

                            Text("Current Accounts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),),
                            Divider(),

                            ListView.builder(
                              itemCount: accounts.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              // Yani bu iki satırı singlechildscroolviewı tüm sayfa için kullanırsak liste içinde aşağı inme olmasın
                              //sadece tüm sayfa için kaydırma olsun dersek kullanırız.
                              itemBuilder: (context, index) {
                                final account = accounts[index];
                                return GestureDetector(
                                  onTap: () {
                                    context.push("/accountDetail/${account.id}");
                                  },
                                  child: Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(15.r),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(account.name, style: TextStyle(fontSize: 17.sp,fontWeight: FontWeight.bold),),
                                              Text(account.accountNumber, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),),
                                            ],
                                          ),
                                          SizedBox(height: 10.h,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Balance", style: TextStyle(fontSize: 16.sp, color: Colors.grey),),
                                              Text("${account.balance} TL", style: TextStyle(fontSize: 16.sp, color: Colors.grey),),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Avaliable Balance", style: TextStyle(fontSize: 16.sp, color: Colors.grey),),
                                              Text("${account.balance} TL", style: TextStyle(fontSize: 16.sp, color: Colors.grey),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }
                    } else {
                      return Center(child: Text("Failed to Load Data"),);
                    }
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
