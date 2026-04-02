import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthCheckSessionRequested extends AuthEvent {
  const AuthCheckSessionRequested();
}

final class AuthLoginRequested extends AuthEvent {
  final String phone;
  final String password;
  const AuthLoginRequested({required this.phone, required this.password});

  @override
  List<Object> get props => [phone, password];
}

final class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String phone;
  final String email;
  final String password;

  const AuthRegisterRequested({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, phone, email, password];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
