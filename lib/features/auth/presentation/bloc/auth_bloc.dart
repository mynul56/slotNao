import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/login_with_password_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/request_otp_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RequestOtpUseCase _requestOtpUseCase;
  final LoginUseCase _loginUseCase;
  final LoginWithPasswordUseCase _loginWithPasswordUseCase;
  final SocialLoginUseCase _socialLoginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthBloc({
    required RequestOtpUseCase requestOtpUseCase,
    required LoginUseCase loginUseCase,
    required LoginWithPasswordUseCase loginWithPasswordUseCase,
    required SocialLoginUseCase socialLoginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _requestOtpUseCase = requestOtpUseCase,
       _loginUseCase = loginUseCase,
       _loginWithPasswordUseCase = loginWithPasswordUseCase,
       _socialLoginUseCase = socialLoginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(const AuthInitial()) {
    on<AuthCheckSessionRequested>(_onCheckSession);
    on<AuthRequestOtpRequested>(_onRequestOtp);
    on<AuthLoginRequested>(_onLogin);
    on<AuthPasswordLoginRequested>(_onPasswordLogin);
    on<AuthSocialLoginRequested>(_onSocialLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheckSession(AuthCheckSessionRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _getCurrentUserUseCase();
    result.fold((_) => emit(const AuthUnauthenticated()), (user) => emit(AuthAuthenticated(user)));
  }

  Future<void> _onRequestOtp(AuthRequestOtpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _requestOtpUseCase(RequestOtpParams(phone: event.phone));
    result.fold((failure) => emit(AuthFailureState(failure.message)), (_) => emit(AuthOtpRequested(phone: event.phone)));
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(LoginParams(phone: event.phone, otp: event.otp));
    result.fold((failure) => emit(AuthFailureState(failure.message)), (user) => emit(AuthAuthenticated(user)));
  }

  Future<void> _onPasswordLogin(AuthPasswordLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _loginWithPasswordUseCase(LoginWithPasswordParams(email: event.email, password: event.password));
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
    result.fold((failure) => emit(AuthFailureState(failure.message)), (user) => emit(AuthAuthenticated(user)));
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _logoutUseCase();
    emit(const AuthUnauthenticated());
  }
}
