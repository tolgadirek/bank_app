import 'package:bank_app/ui/cubit/user_register_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final formKey = GlobalKey<FormState>();
  var tfFirstName = TextEditingController();
  var tfLastName = TextEditingController();
  var tfEmail = TextEditingController();
  var tfPassword = TextEditingController();
  var tfPhoneNumber = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        extendBodyBehindAppBar: true, // Arka plan AppBar arkasına geçsin
        resizeToAvoidBottomInset: true, // Fotoğrafın kaymasını kontrol eder.
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
            BlocConsumer<UserRegisterCubit, UserRegisterState>(
              listener: (context, state) {
                if (state is UserRegisterSuccess) {
                  context.go('/homePage');
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Registration Process Completed")));
                } else if (state is UserRegisterError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                  ));
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
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
                              Text(
                                "Register",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.sp),
                              ),
                              SizedBox(height: 20.h,),
                              createTextField(context, tfFirstName, "Enter Your First Name"),
                              SizedBox(height: 10.h,),
                              createTextField(context, tfLastName, "Enter Your Last Name"),
                              SizedBox(height: 10.h,),
                              createTextField(
                                context,
                                tfPhoneNumber,
                                "Enter Your Phone Number",
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "This field is required";
                                  }
                                  final phone = value.trim();
                                  if (phone.length != 11) { //11 hane kontrolü
                                    return "Phone number must be exactly 11 digits";
                                  }
                                  if (!RegExp(r'^\d{11}$').hasMatch(phone)) { // sayı dışında bişey varsa kontrolü
                                    return "Phone number must contain only digits";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.h,),
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
                                          backgroundColor: Color.fromRGBO(2, 165, 165, 1),
                                          foregroundColor: Colors.white
                                      ),
                                      onPressed: (){
                                        if (formKey.currentState!.validate()) {
                                          context.read<UserRegisterCubit>().register(
                                            tfEmail.text.trim(),
                                            tfPassword.text.trim(),
                                            tfFirstName.text.trim(),
                                            tfLastName.text.trim(),
                                            tfPhoneNumber.text.trim(),
                                          );
                                        }
                                      }, child: Text("Register", style: TextStyle(fontSize: 20.sp),)),
                                ),
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
      ),
    );
  }
}

Widget createTextField(BuildContext context, TextEditingController controller, String hintText, {bool isPassword = false, FormFieldValidator<String>? validator}) {
  return SizedBox(
    height: 50.h,
    child: TextFormField(
      controller: controller,
      obscureText: isPassword,
      cursorColor: Colors.black,
      style: const TextStyle(color: Colors.black),
      validator: validator ??
              (value) {
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
