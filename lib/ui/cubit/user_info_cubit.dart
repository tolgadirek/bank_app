import 'package:bank_app/data/entity/user_model.dart';
import 'package:bank_app/data/repo/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UserInfoState {}

class UserInfoInitial extends UserInfoState {}

class UserInfoLoading extends UserInfoState {}

class UserInfoSuccess extends UserInfoState {
  final UserModel user;
  UserInfoSuccess({required this.user});
}

class UserInfoError extends UserInfoState {
  final String message;
  UserInfoError({required this.message});
}

class UserInfoCubit extends Cubit<UserInfoState> {
  UserInfoCubit() : super(UserInfoInitial());

  var repo = Repository();

  Future<void> getProfile() async {
    emit(UserInfoLoading());
    try {
      final user = await repo.getprofile();
      if (user != null) {
        emit(UserInfoSuccess(user: user));
      }
    } catch (e) {
      emit(UserInfoError(message: "An error occurred: $e"));
      throw e.toString();
    }
  }

  Future<void> updateUser(String email, String firstName, String lastName,
      String phoneNumber,  {String? password}) async {

    try {
      final response = await repo.updateUser(
          email,
          firstName,
          lastName,
          phoneNumber,
          password: password
      );
      if (response != null) {
        await getProfile();
      }
    }  catch (e) {
      throw e.toString();
    }
  }
}