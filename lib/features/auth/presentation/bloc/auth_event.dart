import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthCheckSessionRequested extends AuthEvent {
  const AuthCheckSessionRequested();
}

final class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  const AuthVerifyOtpRequested({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}

final class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

final class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  final String token;
  final String newPassword;

  const AuthResetPasswordRequested({required this.email, required this.token, required this.newPassword});

  @override
  List<Object> get props => [email, token, newPassword];
}

final class AuthPasswordLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthPasswordLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

final class AuthSocialLoginRequested extends AuthEvent {
  final String provider;
  final String providerToken;
  final String email;
  final String? name;

  const AuthSocialLoginRequested({required this.provider, required this.providerToken, required this.email, this.name});

  @override
  List<Object?> get props => [provider, providerToken, email, name];
}

final class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String? phone;
  final String email;
  final String password;

  const AuthRegisterRequested({required this.name, this.phone, required this.email, required this.password});

  @override
  List<Object?> get props => [name, phone, email, password];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
