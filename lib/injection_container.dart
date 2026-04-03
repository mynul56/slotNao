import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/network/request_canceler.dart';
import 'core/network/ws_client.dart';
// Auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/login_with_password_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/request_otp_usecase.dart';
import 'features/auth/domain/usecases/social_login_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
// Booking
import 'features/booking/data/datasources/booking_remote_datasource.dart';
import 'features/booking/data/repositories/booking_repository_impl.dart';
import 'features/booking/domain/repositories/booking_repository.dart';
import 'features/booking/domain/usecases/create_booking_usecase.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';
// Payment
import 'features/payment/data/datasources/payment_remote_datasource.dart';
import 'features/payment/data/repositories/payment_repository_impl.dart';
import 'features/payment/domain/repositories/payment_repository.dart';
import 'features/payment/domain/usecases/init_payment_usecase.dart';
import 'features/payment/presentation/bloc/payment_bloc.dart';
// Profile
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
// Turf
import 'features/turf/data/datasources/turf_remote_datasource.dart';
import 'features/turf/data/repositories/turf_repository_impl.dart';
import 'features/turf/domain/repositories/turf_repository.dart';
import 'features/turf/domain/usecases/get_turf_detail_usecase.dart';
import 'features/turf/domain/usecases/get_turfs_usecase.dart';
import 'features/turf/presentation/bloc/slot_cubit.dart';
import 'features/turf/presentation/bloc/turf_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ──────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true)),
  );

  sl.registerSingleton<Logger>(
    Logger(
      level: kReleaseMode ? Level.warning : Level.debug,
      printer: PrettyPrinter(methodCount: 1, errorMethodCount: 5, lineLength: 80, colors: !kReleaseMode, printEmojis: false),
    ),
  );

  // ── Core ──────────────────────────────────────────────────────────────
  sl.registerSingleton<Connectivity>(Connectivity());
  sl.registerSingleton<NetworkInfo>(NetworkInfo(connectivity: sl()));
  sl.registerSingleton<RequestCanceler>(RequestCanceler());
  sl.registerSingleton<ApiClient>(ApiClient(secureStorage: sl(), logger: sl(), networkInfo: sl(), requestCanceler: sl()));

  sl.registerSingleton<WsClient>(WsClient(logger: sl(), secureStorage: sl()));

  sl.registerSingleton<Dio>(sl<ApiClient>().dio);

  // ── Auth ──────────────────────────────────────────────────────────────
  sl
    ..registerLazySingleton<AuthRemoteDatasource>(() => AuthRemoteDatasourceImpl(apiClient: sl(), secureStorage: sl()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDatasource: sl(), secureStorage: sl()))
    ..registerLazySingleton(() => RequestOtpUseCase(sl()))
    ..registerLazySingleton(() => LoginUseCase(sl()))
    ..registerLazySingleton(() => LoginWithPasswordUseCase(sl()))
    ..registerLazySingleton(() => SocialLoginUseCase(sl()))
    ..registerLazySingleton(() => RegisterUseCase(sl()))
    ..registerLazySingleton(() => LogoutUseCase(sl()))
    ..registerLazySingleton(() => GetCurrentUserUseCase(sl()))
    ..registerFactory(
      () => AuthBloc(
        requestOtpUseCase: sl(),
        loginUseCase: sl(),
        loginWithPasswordUseCase: sl(),
        socialLoginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
      ),
    );

  // ── Turf ──────────────────────────────────────────────────────────────
  sl
    ..registerLazySingleton<TurfRemoteDatasource>(() => TurfRemoteDatasourceImpl(apiClient: sl()))
    ..registerLazySingleton<TurfRepository>(() => TurfRepositoryImpl(remoteDatasource: sl(), wsClient: sl()))
    ..registerLazySingleton(() => GetTurfsUseCase(sl()))
    ..registerLazySingleton(() => GetTurfDetailUseCase(sl()))
    ..registerLazySingleton(() => SearchTurfsUseCase(sl()))
    ..registerLazySingleton(() => WatchSlotAvailabilityUseCase(sl()))
    ..registerFactory(() => TurfBloc(getTurfsUseCase: sl(), getTurfDetailUseCase: sl(), searchTurfsUseCase: sl()))
    ..registerFactory(() => SlotCubit(watchSlotAvailabilityUseCase: sl()));

  // ── Booking ───────────────────────────────────────────────────────────
  sl
    ..registerLazySingleton<BookingRemoteDatasource>(() => BookingRemoteDatasourceImpl(apiClient: sl()))
    ..registerLazySingleton<BookingRepository>(() => BookingRepositoryImpl(remoteDatasource: sl()))
    ..registerLazySingleton(() => CreateBookingUseCase(sl()))
    ..registerLazySingleton(() => GetBookingsUseCase(sl()))
    ..registerLazySingleton(() => CancelBookingUseCase(sl()))
    ..registerFactory(() => BookingBloc(createBookingUseCase: sl(), getBookingsUseCase: sl(), cancelBookingUseCase: sl()));

  // ── Payment ───────────────────────────────────────────────────────────
  sl
    ..registerLazySingleton<PaymentRemoteDatasource>(() => PaymentRemoteDatasourceImpl(apiClient: sl()))
    ..registerLazySingleton<PaymentRepository>(() => PaymentRepositoryImpl(remoteDatasource: sl()))
    ..registerLazySingleton(() => InitPaymentUseCase(sl()))
    ..registerLazySingleton(() => ConfirmPaymentUseCase(sl()))
    ..registerFactory(() => PaymentBloc(initPaymentUseCase: sl(), confirmPaymentUseCase: sl()));

  // ── Profile ───────────────────────────────────────────────────────────
  sl
    ..registerLazySingleton<ProfileRemoteDatasource>(() => ProfileRemoteDatasourceImpl(apiClient: sl()))
    ..registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(remoteDatasource: sl()))
    ..registerLazySingleton(() => GetProfileUseCase(sl()))
    ..registerLazySingleton(() => UpdateProfileUseCase(sl()))
    ..registerFactory(() => ProfileBloc(getProfileUseCase: sl(), updateProfileUseCase: sl()));
}
