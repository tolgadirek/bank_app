import 'package:bank_app/ui/cubit/bank_accounts_cubit.dart';
import 'package:bank_app/ui/cubit/user_login_cubit.dart';
import 'package:bank_app/ui/cubit/user_register_cubit.dart';
import 'package:bank_app/ui/view/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserLoginCubit()),
        BlocProvider(create: (context) => UserRegisterCubit()),
        BlocProvider(create: (context) => BankAccountsCubit()),
      ],
      child: ScreenUtilInit(
        designSize: Size(412, 732),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp.router(
          routerConfig: appRouter,
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true
          ),
        ),
      ),
    );
  }
}

