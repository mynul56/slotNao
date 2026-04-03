import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final SocialLoginUseCase _socialLoginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required SocialLoginUseCase socialLoginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  }) : _loginUseCase = loginUseCase,
       _socialLoginUseCase = socialLoginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _verifyOtpUseCase = verifyOtpUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       super(const AuthInitial()) {
    on<AuthCheckSessionRequested>(_onCheckSession);
    on<AuthPasswordLoginRequested>(_onPasswordLogin);
    on<AuthSocialLoginRequested>(_onSocialLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthVerifyOtpRequested>(_onVerifyOtp);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthResetPasswordRequested>(_onResetPassword);
  }

  Future<void> _onCheckSession(AuthCheckSessionRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _getCurrentUserUseCase();
    result.fold((_) => emit(const AuthUnauthenticated()), (user) => emit(AuthAuthenticated(user)));
  }

  Future<void> _onPasswordLogin(AuthPasswordLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(LoginParams(email: event.email, password: event.password));
    result.fold((failure) => emit(AuthFailureState(failure.message)), (user) => emit(AuthAuthenticated(user)));
  }

  Future<void> _onSocialLogin(AuthSocialLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _socialLoginUseCase(
      SocialLoginParams(provider: event.provider, providerToken: event.providerToken, email: event.email, name: event.name),
    );
    result.fold((failure) => emit(AuthFailureState(failure.message)), (user) => emit(AuthAuthenticated(user)));
  }

  Future<void> _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _registerUseCase(
      RegisterParams(name: event.name, phone: event.phone, email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => emit(AuthRegistrationSuccess(email: event.email)),
    );
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _logoutUseCase();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onVerifyOtp(AuthVerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _verifyOtpUseCase(VerifyOtpParams(email: event.email, otp: event.otp));
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => emit(const AuthOtpVerificationSuccess()),
    );
  }

  Future<void> _onForgotPassword(AuthForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _forgotPasswordUseCase(ForgotPasswordParams(email: event.email));
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => emit(const AuthForgotPasswordEmailSent()),
    );
  }

  Future<void> _onResetPassword(AuthResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _resetPasswordUseCase(
      ResetPasswordParams(email: event.email, token: event.token, newPassword: event.newPassword),
    );
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => emit(const AuthPasswordResetSuccess()),
    );
  }
}
