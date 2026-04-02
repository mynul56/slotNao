import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/turf_entity.dart';
import '../../domain/usecases/get_turfs_usecase.dart';

// ── State ──────────────────────────────────────────────────────────────────
sealed class SlotState extends Equatable {
  const SlotState();
  @override
  List<Object?> get props => [];
}

final class SlotInitial extends SlotState {
  const SlotInitial();
}

final class SlotLoading extends SlotState {
  const SlotLoading();
}

final class SlotLoaded extends SlotState {
  final List<SlotEntity> slots;
  final DateTime date;
  const SlotLoaded({required this.slots, required this.date});
  @override
  List<Object> get props => [slots, date];
}

final class SlotError extends SlotState {
  final String message;
  const SlotError(this.message);
  @override
  List<Object> get props => [message];
}

// ── Cubit ──────────────────────────────────────────────────────────────────
class SlotCubit extends Cubit<SlotState> {
  final WatchSlotAvailabilityUseCase _watchSlotAvailabilityUseCase;

  SlotCubit({required WatchSlotAvailabilityUseCase watchSlotAvailabilityUseCase})
      : _watchSlotAvailabilityUseCase = watchSlotAvailabilityUseCase,
        super(const SlotInitial());

  StreamSubscription<Object?>? _slotStream;

  void watchSlots({required String turfId, required DateTime date}) {
    emit(const SlotLoading());

    final stream = _watchSlotAvailabilityUseCase(
      WatchSlotParams(turfId: turfId, date: date),
    );

    _slotStream?.cancel();
    _slotStream = stream.listen((result) {
      result.fold(
        (failure) => emit(SlotError(failure.message)),
        (slots) => emit(SlotLoaded(slots: slots, date: date)),
      );
    });
  }

  @override
  Future<void> close() async {
    await _slotStream?.cancel();
    return super.close();
  }
}
