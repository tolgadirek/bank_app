import 'package:bank_app/ui/cubit/user_login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final formKey = GlobalKey<FormState>();
  var tfEmail = TextEditingController();
  var tfPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Arka plan AppBar arkasına geçsin
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Şeffaflık
        elevation: 0, // Gölge yok
        title: Text("Trex Bank", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6), // Ne kadar karanlık olmasını istiyorsan
                    BlendMode.darken,
                  ),
                  child: Image.asset("images/trex.png", fit: BoxFit.cover, )
              ),
          ),
          BlocConsumer<UserLoginCubit, UserLoginState>(
            listener: (context, state) {
              if (state is UserLoginSuccess) {
                context.go('/homePage');
              } else if (state is UserLoginError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),);
              }
            },
            builder: (context, state) {
              return SingleChildScrollView( // Bunu koyunca arka plan aşağıdan boşluk verdi.
                child: ConstrainedBox(
                  constraints: BoxConstraints( // Bu sayede arka plan resmi bozulmamış tam ekran oldu.
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.r),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 190.h,),
                            Text(
                              "Log in",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp),
                            ),
                            SizedBox(height: 20.h,),
                            createTextField(context, tfEmail, "Enter Your Email Address"),
                            SizedBox(height: 10.h,),
                            createTextField(context, tfPassword, "Enter Your Password", isPassword: true),
                            SizedBox(height: 40.h,),
                            Padding(
                              padding: EdgeInsets.only(right: 40.w, left: 40.w),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white
                                    ),
                                    onPressed: (){
                                      String email = tfEmail.text.trim();
                                      String password = tfPassword.text.trim();
                                      context.read<UserLoginCubit>().login(email, password);
                                    }, child: Text("Log In", style: TextStyle(fontSize: 20.sp),)),
                              ),
                            ),
                            SizedBox(height: 60.h,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(onPressed: (){
                                  context.push("/register");
                                }, child: Text("Become a Costumer", style: TextStyle(color: Colors.white54, fontSize: 15.sp),)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget createTextField(BuildContext context, TextEditingController controller, String hintText, {bool isPassword = false}) {
  return SizedBox(
    height: 50.h,
    child: TextFormField(
      controller: controller,
      obscureText: isPassword,
      cursorColor: Colors.black,
      style: const TextStyle(color: Colors.black),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "This field is required";
        }
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}
