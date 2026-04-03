import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:turf_booking_app/core/errors/failures.dart';
import 'package:turf_booking_app/features/auth/domain/entities/user_entity.dart';
import 'package:turf_booking_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:turf_booking_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:turf_booking_app/features/auth/domain/usecases/login_with_password_usecase.dart';
import 'package:turf_booking_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:turf_booking_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:turf_booking_app/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:turf_booking_app/features/auth/domain/usecases/social_login_usecase.dart';
import 'package:turf_booking_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:turf_booking_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:turf_booking_app/features/auth/presentation/bloc/auth_state.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────
class MockRequestOtpUseCase extends Mock implements RequestOtpUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLoginWithPasswordUseCase extends Mock implements LoginWithPasswordUseCase {}

class MockSocialLoginUseCase extends Mock implements SocialLoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

// ── Test Data ─────────────────────────────────────────────────────────────
final tUser = UserEntity(
  id: 'user-001',
  name: 'Md Inzamam',
  email: 'inzamam@slotnao.com',
  phone: '01712345678',
  role: UserRole.player,
  createdAt: DateTime(2025, 1, 1),
);

void main() {
  late AuthBloc authBloc;
  late MockRequestOtpUseCase mockRequestOtpUseCase;
  late MockLoginUseCase mockLoginUseCase;
  late MockLoginWithPasswordUseCase mockLoginWithPasswordUseCase;
  late MockSocialLoginUseCase mockSocialLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  setUp(() {
    mockRequestOtpUseCase = MockRequestOtpUseCase();
    mockLoginUseCase = MockLoginUseCase();
    mockLoginWithPasswordUseCase = MockLoginWithPasswordUseCase();
    mockSocialLoginUseCase = MockSocialLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();

    authBloc = AuthBloc(
      requestOtpUseCase: mockRequestOtpUseCase,
      loginUseCase: mockLoginUseCase,
      loginWithPasswordUseCase: mockLoginWithPasswordUseCase,
      socialLoginUseCase: mockSocialLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
    );

    // Register fallback values
    registerFallbackValue(const RequestOtpParams(phone: '01700000000'));
    registerFallbackValue(const LoginParams(phone: '01700000000', otp: '123456'));
    registerFallbackValue(const LoginWithPasswordParams(email: 'test@example.com', password: 'password'));
    registerFallbackValue(
      const SocialLoginParams(
        provider: 'google',
        providerToken: 'google_test_token',
        email: 'test@example.com',
        name: 'Test User',
      ),
    );
    registerFallbackValue(
      const RegisterParams(name: 'Test', phone: '01700000000', email: 'test@example.com', password: 'password'),
    );
  });

  tearDown(() => authBloc.close());

  group('AuthBloc - CheckSession', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when session is valid',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckSessionRequested()),
      expect: () => [const AuthLoading(), AuthAuthenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no session',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => const Left(AuthFailure(message: 'No user')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckSessionRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });

  group('AuthBloc - Login', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(phone: '01712345678', otp: '123456')),
      expect: () => [const AuthLoading(), AuthAuthenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] on login failure',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer((_) async => const Left(AuthFailure(message: 'Invalid credentials')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(phone: '01799999999', otp: '000000')),
      expect: () => [const AuthLoading(), const AuthFailureState('Invalid credentials')],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] on network error',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer((_) async => const Left(NetworkFailure()));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(phone: '01700000000', otp: '111111')),
      expect: () => [const AuthLoading(), const AuthFailureState('No internet connection. Please check your network.')],
    );
  });

  group('AuthBloc - Password Login', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful password login',
      build: () {
        when(() => mockLoginWithPasswordUseCase(any())).thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthPasswordLoginRequested(email: 'test@example.com', password: 'password123')),
      expect: () => [const AuthLoading(), AuthAuthenticated(tUser)],
    );
  });

  group('AuthBloc - Social Login', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful social login',
      build: () {
        when(() => mockSocialLoginUseCase(any())).thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthSocialLoginRequested(
          provider: 'google',
          providerToken: 'google_test_token',
          email: 'test@example.com',
          name: 'Test User',
        ),
      ),
      expect: () => [const AuthLoading(), AuthAuthenticated(tUser)],
    );
  });

  group('AuthBloc - Logout', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] on logout',
      build: () {
        when(() => mockLogoutUseCase()).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthUnauthenticated()],
    );
  });
}
