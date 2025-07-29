import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UserRegisterState {}

class UserRegisterInitial extends UserRegisterState {}

class UserRegisterLoading extends UserRegisterState {}

class UserRegisterSuccess extends UserRegisterState {
  final UserModel user;
  final String token;

  UserRegisterSuccess({required this.user, required this.token});
}

class UserRegisterError extends UserRegisterState {
  final String message;

  UserRegisterError({required this.message});
}


class UserRegisterCubit extends Cubit<UserRegisterState> {
  UserRegisterCubit() : super(UserRegisterInitial());

  var repo = Repository();

  Future<void> register(String email, String password, String firstName, String lastName) async {
    emit(UserRegisterLoading());
    try {
     final result = await repo.register(email, password, firstName, lastName);
     emit(UserRegisterSuccess(user: result.user, token: result.token));
    } catch (e) {
      emit(UserRegisterError(message: "registration failed $e"));
    }
  }
}