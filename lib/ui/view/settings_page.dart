import 'package:bank_app/ui/cubit/user_info_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final formKey = GlobalKey<FormState>();
  var tfFirstName = TextEditingController();
  var tfLastName = TextEditingController();
  var tfEmail = TextEditingController();
  var tfPassword = TextEditingController();
  var tfPhoneNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UserInfoCubit>().getProfile();
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
      body: BlocBuilder<UserInfoCubit, UserInfoState>(
          builder: (context, state) {
            if (state is UserInfoLoading) {
              return Center(child: CircularProgressIndicator(),);
            } else if (state is UserInfoError) {
              return Center(child: Text(state.message),);
            } else if (state is UserInfoSuccess) {
              final user = state.user;

              tfFirstName.text = user.firstName;
              tfLastName.text = user.lastName;
              tfPhoneNumber.text = user.phoneNumber;
              tfEmail.text = user.email;
              tfPassword.clear();

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(15.r),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text("Account Opening Date: ", style: TextStyle(fontSize: 16.sp),),
                            Flexible(
                                child: Text(
                                  "${user.createdAt}".split(" ")[0],
                                  style: TextStyle(fontSize: 16.sp),
                                  overflow: TextOverflow.ellipsis,
                                )
                            )
                          ],
                        ),
                        SizedBox(height: 30.h,),
                        createTextField(tfFirstName, "First Name", (value) => value == null || value.isEmpty ? "This field s required": null),
                        SizedBox(height: 15.h,),
                        createTextField(tfLastName, "Last Name", (value) => value == null || value.isEmpty ? "This field s required": null),
                        SizedBox(height: 15.h,),
                        createTextField(tfPhoneNumber, "Phone Number", (value) => value == null || value.isEmpty ? "This field s required": null),
                        SizedBox(height: 15.h,),
                        createTextField(tfEmail, "Email Address", (value) => value == null || value.isEmpty ? "This field s required": null),
                        SizedBox(height: 15.h,),
                        createTextField(tfPassword, "Password", (value) => null, isPassword: true),
                        SizedBox(height: 30.h,),

                        // Update
                        SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  if (formKey.currentState!.validate()) {
                                    await context.read<UserInfoCubit>().updateUser(
                                      tfEmail.text,
                                      tfFirstName.text,
                                      tfLastName.text,
                                      tfPhoneNumber.text,
                                      password: tfPassword.text.isEmpty ? null : tfPassword.text,
                                    );

                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Success"),
                                            content: Text("Changes have been made successfully"),
                                            actions: [
                                              TextButton(onPressed: () {
                                                Navigator.pop(context);
                                              }, child: Text("Ok")),
                                            ],
                                          );
                                        }
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(2, 165, 165, 1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Text("Save"),),
                        ),

                        SizedBox(height: 50.h,),
                        //Log Out Button
                        TextButton(onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove("token");
                          context.go("/login");
                        }, child: Text("Log Out")),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Center(child: Text("An error occurred."),);
            }
          }
      ),
    );
  }
}

Widget createTextField(TextEditingController controller, String labelText, FormFieldValidator<String>? validator, {bool isPassword = false}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: labelText,
      border: OutlineInputBorder(
        borderSide: BorderSide.none
      ),
    ),
    validator: validator,
  );
}
