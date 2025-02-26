import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/services/shared_services.dart';
import 'package:frontend/features/repository/auth_local_repository.dart';
import 'package:frontend/features/repository/auth_remote_repository.dart';
import 'package:frontend/model/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final authRemoteRepository = AuthRemoteRepository();
  final authLocalRepository = AuthLocalRepository();
  final spService = SpService();

  void getUserData() async {
    try {
      emit(AuthLoading());
      final userModel = await authRemoteRepository.getUserData();

      if (userModel != null) {
        await authLocalRepository.insertUser(userModel);
        emit(AuthLoggedIn(userModel));
        return;
      }
      emit(AuthInitial());
    } catch (e) {
      emit(AuthInitial());
    }
  }

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      authRemoteRepository.signUp(name: name, email: email, password: password);
      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void login({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final userModel =
          await authRemoteRepository.login(email: email, password: password);
      // ignore: unnecessary_null_comparison
      if (userModel.token != null) {
        spService.setToken(userModel.token);
      }

      await authLocalRepository.insertUser(userModel);
      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
