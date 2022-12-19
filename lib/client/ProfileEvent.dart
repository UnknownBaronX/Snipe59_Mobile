import 'package:equatable/equatable.dart';

import '../entity/Profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class LoadProfiles extends ProfileEvent {
  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile({required this.profileId});

  final String profileId;

  @override
  List<Object> get props => [profileId];

  @override
  String toString() => 'LoadProfile';
}

class SaveProfile extends ProfileEvent {
  const SaveProfile({required this.profile});

  final Profile profile;

  @override
  List<Object> get props => [profile];

  @override
  String toString() => 'SaveProfile';
}

class SetActive extends ProfileEvent {
  const SetActive({required this.profile});

  final Profile profile;

  @override
  List<Object> get props => [profile];

  @override
  String toString() => 'SetActive';
}

class CreateProfile extends ProfileEvent {
  const CreateProfile();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'CreateProfile';
}

class DeleteProfile extends ProfileEvent {
  const DeleteProfile({required this.profileId});

  final String profileId;

  @override
  List<Object> get props => [profileId];

  @override
  String toString() => 'DeleteProfile';
}
