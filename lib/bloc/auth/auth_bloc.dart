import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/settings_storage.dart';
import '../../data/repositories/auth_repository.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const RegisterRequested({required this.email, required this.password, required this.name});
  @override
  List<Object?> get props => [email, password, name];
}

class LogoutRequested extends AuthEvent {}

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String email;
  final String name;
  const Authenticated({required this.email, required this.name});
  @override
  List<Object?> get props => [email, name];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepo;
  final SettingsStorage _settings;

  AuthBloc(this._authRepo, this._settings) : super(AuthInitial()) {
    on<AppStarted>((event, emit) {
      if (_authRepo.isLoggedIn) {
        emit(Authenticated(
          email: _authRepo.currentEmail ?? '',
          name: _authRepo.currentName ?? '',
        ));
      } else {
        emit(Unauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final res = await _authRepo.login(event.email, event.password);
        emit(Authenticated(email: res.email, name: res.name));
      } catch (e) {
        emit(AuthFailure(_extractErrorMessage(e)));
        emit(Unauthenticated());
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final res = await _authRepo.register(event.email, event.password, event.name);
        emit(Authenticated(email: res.email, name: res.name));
      } catch (e) {
        emit(AuthFailure(_extractErrorMessage(e)));
        emit(Unauthenticated());
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _authRepo.logout();
      await _settings.clearSyncTime();
      emit(Unauthenticated());
    });
  }
}

String _extractErrorMessage(dynamic e) {
  if (e is DioException) {
    if (e.response?.statusCode == 401) {
      return 'Invalid email or password. If you do not have an account, please tap "Register" to create one.';
    }
    if (e.response?.statusCode == 400) {
      final msg = e.response?.data?['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      return 'Invalid request information.';
    }
    if (e.response?.statusCode == 409) {
      return 'An account with this email already exists. Please sign in instead.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to backend server at http://127.0.0.1:8080. Please ensure the backend is running.';
    }
  }
  return e.toString();
}
