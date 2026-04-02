import 'package:equatable/equatable.dart';
import '../../domain/entities/turf_entity.dart';

sealed class TurfState extends Equatable {
  const TurfState();
  @override
  List<Object?> get props => [];
}

final class TurfInitial extends TurfState {
  const TurfInitial();
}

final class TurfLoading extends TurfState {
  const TurfLoading();
}

final class TurfListLoaded extends TurfState {
  final List<TurfEntity> turfs;
  final bool hasMore;
  const TurfListLoaded({required this.turfs, this.hasMore = true});
  @override
  List<Object> get props => [turfs, hasMore];
}

final class TurfDetailLoaded extends TurfState {
  final TurfEntity turf;
  const TurfDetailLoaded(this.turf);
  @override
  List<Object> get props => [turf];
}

final class TurfSearchResults extends TurfState {
  final List<TurfEntity> results;
  final String query;
  const TurfSearchResults({required this.results, required this.query});
  @override
  List<Object> get props => [results, query];
}

final class TurfError extends TurfState {
  final String message;
  const TurfError(this.message);
  @override
  List<Object> get props => [message];
}
