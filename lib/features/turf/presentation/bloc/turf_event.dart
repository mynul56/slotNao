import 'package:equatable/equatable.dart';
import '../../domain/entities/turf_entity.dart';

sealed class TurfEvent extends Equatable {
  const TurfEvent();
  @override
  List<Object?> get props => [];
}

final class TurfLoadRequested extends TurfEvent {
  final int page;
  const TurfLoadRequested({this.page = 1});
  @override
  List<Object> get props => [page];
}

final class TurfSearchRequested extends TurfEvent {
  final String query;
  const TurfSearchRequested(this.query);
  @override
  List<Object> get props => [query];
}

final class TurfDetailRequested extends TurfEvent {
  final String turfId;
  const TurfDetailRequested(this.turfId);
  @override
  List<Object> get props => [turfId];
}

final class TurfFilterChanged extends TurfEvent {
  final TurfType? type;
  final double? maxPrice;
  const TurfFilterChanged({this.type, this.maxPrice});
  @override
  List<Object?> get props => [type, maxPrice];
}
