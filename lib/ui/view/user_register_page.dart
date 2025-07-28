import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  var tfFirstName = TextEditingController();
  var tfLastName = TextEditingController();
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
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints( // Bu sayede arka plan resmi bozulmamış tam ekran oldu.
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(30.r),
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
                      createTextField(context, tfEmail, "Enter Your First Name"),
                      SizedBox(height: 10.h,),
                      createTextField(context, tfEmail, "Enter Your Last Name"),
                      SizedBox(height: 10.h,),
                      createTextField(context, tfEmail, "Enter Your Email Address"),
                      SizedBox(height: 10.h,),
                      createTextField(context, tfPassword, "Enter Your Password"),
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

                              }, child: Text("Register", style: TextStyle(fontSize: 20.sp),)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
