import 'package:equatable/equatable.dart';
import 'package:snipe59/entity/FutsovereignItem.dart';

import '../entity/Profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileStateEmpty extends ProfileState {}

class ProfileStateLoading extends ProfileState {}

class ProfileStateReload extends ProfileState {}

class ProfileStateListSuccess extends ProfileState {
  const ProfileStateListSuccess({required this.profileList});

  final List<Profile> profileList;

  @override
  List<Object> get props => [profileList];

  @override
  String toString() => 'ProfileStateListSuccess';
}

class ProfileStateListError extends ProfileState {
  const ProfileStateListError();

  @override
  List<Object> get props => [];
}
