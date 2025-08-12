import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:bank_app/data/services/dio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UserLoginState {}

class UserLoginInitial extends UserLoginState {}

class UserLoginLoading extends UserLoginState {}

class UserLoginSuccess extends UserLoginState {
  final UserModel user;
  final String token;

  UserLoginSuccess({required this.user, required this.token});
}

class UserLoginError extends UserLoginState {
  final String message;

  UserLoginError({required this.message});
}


class UserLoginCubit extends Cubit<UserLoginState> {
  UserLoginCubit() : super(UserLoginInitial());

  var repo = Repository(dio: DioService.dio);

  Future<void> login(String email, String password) async {
    emit(UserLoginLoading());
    try {
      final result = await repo.login(email, password);
      if(result != null) {
        emit(UserLoginSuccess(user: result.user, token: result.token));
      } else {
        emit(UserLoginError(message: "An unexpected error occurred"));
      }
    } catch (e) {
      emit(UserLoginError(message: e.toString()));
    }
  }
}