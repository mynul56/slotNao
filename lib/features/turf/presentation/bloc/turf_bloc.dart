import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/usecases/get_turfs_usecase.dart';
import 'turf_event.dart';
import 'turf_state.dart';

class TurfBloc extends Bloc<TurfEvent, TurfState> {
  final GetTurfsUseCase _getTurfsUseCase;
  final GetTurfDetailUseCase _getTurfDetailUseCase;
  final SearchTurfsUseCase _searchTurfsUseCase;

  TurfBloc({
    required GetTurfsUseCase getTurfsUseCase,
    required GetTurfDetailUseCase getTurfDetailUseCase,
    required SearchTurfsUseCase searchTurfsUseCase,
  })  : _getTurfsUseCase = getTurfsUseCase,
        _getTurfDetailUseCase = getTurfDetailUseCase,
        _searchTurfsUseCase = searchTurfsUseCase,
        super(const TurfInitial()) {
    on<TurfLoadRequested>(_onLoad);
    on<TurfDetailRequested>(_onDetail);
    on<TurfSearchRequested>(
      _onSearch,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 400))
          .switchMap(mapper),
    );
  }

  Future<void> _onLoad(
    TurfLoadRequested event,
    Emitter<TurfState> emit,
  ) async {
    if (event.page == 1) emit(const TurfLoading());
    final result = await _getTurfsUseCase(GetTurfsParams(page: event.page));
    result.fold(
      (failure) => emit(TurfError(failure.message)),
      (turfs) => emit(TurfListLoaded(
        turfs: turfs,
        hasMore: turfs.isNotEmpty,
      )),
    );
  }

  Future<void> _onDetail(
    TurfDetailRequested event,
    Emitter<TurfState> emit,
  ) async {
    emit(const TurfLoading());
    final result = await _getTurfDetailUseCase(event.turfId);
    result.fold(
      (failure) => emit(TurfError(failure.message)),
      (turf) => emit(TurfDetailLoaded(turf)),
    );
  }

  Future<void> _onSearch(
    TurfSearchRequested event,
    Emitter<TurfState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const TurfLoadRequested());
      return;
    }
    emit(const TurfLoading());
    final result = await _searchTurfsUseCase(
      SearchTurfsParams(query: event.query),
    );
    result.fold(
      (failure) => emit(TurfError(failure.message)),
      (results) =>
          emit(TurfSearchResults(results: results, query: event.query)),
    );
  }
}
