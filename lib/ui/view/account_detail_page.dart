import 'package:bank_app/ui/cubit/account_detail_cubit.dart';
import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AccountDetailPage extends StatefulWidget {
  final int id;
  const AccountDetailPage({super.key, required this.id});

  @override
  State<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {

  @override
  void initState() {
    super.initState();
    context.read<AccountDetailCubit>().getAccountById(widget.id);
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
              Text("Account Detail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.sp),),
              BlocBuilder<AccountDetailCubit, AccountDetailState>(
                  builder: (context, state) {
                    if (state is AccountDetailLoading) {
                      return Center(child: CircularProgressIndicator(),);
                    } else if (state is AccountDetailError) {
                      return Center(child: Text(state.message),);
                    } else if (state is AccountDetailLoaded) {
                      var account = state.account;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15.h,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(account.accountNumber, style: TextStyle(fontSize: 16.sp),),
                              Text("${account.balance}", style: TextStyle(fontSize: 16.sp)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Avaliable Balance", style: TextStyle(color: Colors.grey, fontSize: 16.sp),),
                              Text("${account.balance}", style: TextStyle(color: Colors.grey, fontSize: 16.sp),),
                            ],
                          ),

                          SizedBox(height: 15.h,),

                          Text("Account Holder", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5.h,),
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(10.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("First and Last Name", style: TextStyle(color: Colors.grey, fontSize: 16.sp),),
                                      Text("${account.user?.firstName} ${account.user?.lastName}", style: TextStyle(fontSize: 16.sp),),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Costumer Email", style: TextStyle(color: Colors.grey, fontSize: 16.sp),),
                                      Text("${account.user?.email}", style: TextStyle(fontSize: 16.sp),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 15.h,),

                          Text("Account Informations", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5.h,),
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(10.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Account Name", style: TextStyle(color: Colors.grey, fontSize: 16.sp),),
                                      Text(account.name, style: TextStyle(fontSize: 16.sp),),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Account Number", style: TextStyle(color: Colors.grey, fontSize: 16.sp),),
                                      Text(account.accountNumber, style: TextStyle(fontSize: 16.sp),),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("IBAN", style: TextStyle(color: Colors.grey, fontSize: 16.sp),),
                                      SelectableText(account.iban, style: TextStyle(fontSize: 16.sp, color: Colors.blueAccent),),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Account Opening Date", style: TextStyle(color: Colors.grey, fontSize: 16.sp),),
                                      Text("${account.createdAt}".split(" ")[0], style: TextStyle(fontSize: 16.sp),),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Account Type", style: TextStyle(color: Colors.grey, fontSize: 16.sp),),
                                      Text("Current Account", style: TextStyle(fontSize: 16.sp),),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Account Opening Purpose", style: TextStyle(color: Colors.grey, fontSize: 16.sp),),
                                      Text("Personel", style: TextStyle(fontSize: 16.sp),),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Currency Code", style: TextStyle(color: Colors.grey, fontSize: 16.sp),),
                                      Text("TL", style: TextStyle(fontSize: 16.sp),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 30.h,),

                          createElevatedButton("Account Transactions", (){
                            context.push("/transaction/${account.id}");
                          }),
                          SizedBox(height: 10.h,),

                          createElevatedButton("Delete Account", () async {
                            if (account.balance > 0) {
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text("Cannot Delete"),
                                    content: Text("This account has a non-zero balance"),
                                    actions: [
                                      TextButton(onPressed: (){
                                        Navigator.pop(context);
                                      }, child: Text("Ok"))
                                    ],
                                  )
                              );
                              return;
                            } else {
                              await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text("Delete"),
                                    content: Text("Delete this account?"),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: Text("No")),
                                      TextButton(onPressed: () {
                                        context.go("/homePage");
                                        context.read<BankAccountsCubit>().deleteAccount(account.id);
                                      } , child: Text("Yes")),
                                    ],
                                  )
                              );
                            }
                          })
                        ],
                      );
                    } else {
                      return Center(child: Text("An error occurred."),);
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

Widget createElevatedButton(String text, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 50.h,
    child: ElevatedButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Color.fromRGBO(2, 165, 165, 1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(text, style: TextStyle(fontSize: 16.sp),)),
  );
}
