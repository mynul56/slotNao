import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

final class ProfileUpdateRequested extends ProfileEvent {
  final String? name;
  final String? email;
  const ProfileUpdateRequested({this.name, this.email});
  @override
  List<Object?> get props => [name, email];
}
