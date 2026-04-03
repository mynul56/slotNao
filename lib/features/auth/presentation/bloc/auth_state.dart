import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthRegistrationSuccess extends AuthState {
  final String email;
  final String message;

  const AuthRegistrationSuccess({required this.email, this.message = 'Please verify your email.'});

  @override
  List<Object> get props => [email, message];
}

final class AuthOtpVerificationSuccess extends AuthState {
  const AuthOtpVerificationSuccess();
}

final class AuthForgotPasswordEmailSent extends AuthState {
  const AuthForgotPasswordEmailSent();
}

final class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}

final class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState(this.message);

  @override
  List<Object> get props => [message];
}
