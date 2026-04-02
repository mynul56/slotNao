import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  ProfileBloc({required GetProfileUseCase getProfileUseCase, required UpdateProfileUseCase updateProfileUseCase})
    : _getProfileUseCase = getProfileUseCase,
      _updateProfileUseCase = updateProfileUseCase,
      super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileUpdateRequested>(_onUpdate);
  }

  Future<void> _onLoad(ProfileLoadRequested event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    final result = await _getProfileUseCase();
    result.fold((failure) => emit(ProfileError(failure.message)), (profile) => emit(ProfileLoaded(profile)));
  }

  Future<void> _onUpdate(ProfileUpdateRequested event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    final result = await _updateProfileUseCase(UpdateProfileParams(name: event.name, email: event.email));
    result.fold((failure) => emit(ProfileError(failure.message)), (profile) => emit(ProfileLoaded(profile)));
  }
}
