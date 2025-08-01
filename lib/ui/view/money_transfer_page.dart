import 'package:bank_app/ui/cubit/transactions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

                  Text("Receiver First Name:"),
                  TextFormField(
                    controller: tfFirstName,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Receiver First Name",
                      hintStyle: const TextStyle(color: Colors.grey),
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
                      hintStyle: const TextStyle(color: Colors.grey),
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
                      hintStyle: const TextStyle(color: Colors.grey),
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
                      hintStyle: const TextStyle(color: Colors.grey),
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
                        onPressed: () {
                          if (formKey.currentState!.validate()){
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
                                          Text("data"),
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
                                      TextButton(onPressed: (){
                                        Navigator.pop(context);
                                      }, child: Text("Cancel", style: TextStyle(color: Colors.red),)),
                                      TextButton(onPressed: (){

                                      }, child: Text("Send", style: TextStyle(color: Colors.green),)),
                                    ],
                                  );
                                }
                            );
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
