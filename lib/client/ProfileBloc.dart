import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipe59/client/FutsovereignEvent.dart';
import 'package:snipe59/client/FutsovereignRepository.dart';
import 'package:snipe59/client/FutsovereignState.dart';
import 'package:snipe59/client/ProfileEvent.dart';
import 'package:snipe59/client/ProfileState.dart';
import 'package:snipe59/client/Snipe59Event.dart';
import 'package:snipe59/client/Snipe59Repository.dart';
import 'package:snipe59/client/Snipe59State.dart';
import 'package:snipe59/entity/FutsovereignItem.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:developer' as developer;

import '../entity/Profile.dart';

const _duration = const Duration(milliseconds: 50);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required this.sharedPreferences}) : super(ProfileStateEmpty()) {
    on<LoadProfiles>(_onFetchProfiles, transformer: debounce(_duration));
    on<SaveProfile>(_onSaveProfile, transformer: debounce(_duration));
    on<SetActive>(_onSetActive, transformer: debounce(_duration));
    on<CreateProfile>(_onCreateProfile, transformer: debounce(_duration));
    on<DeleteProfile>(_onDeleteProfile, transformer: debounce(_duration));
  }

  final SharedPreferences sharedPreferences;

  void _onCreateProfile(
    CreateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    String? profiles = sharedPreferences.getString("profiles");
    List<Profile> profileList = List.empty(growable: true);
    if (profiles != null) {
      Iterable l = json.decode(profiles);
      profileList =
          List<Profile>.from(l.map((model) => Profile.fromJson(model)));
      Profile p = Profile.createProfile(profileList.length + 1);
      profileList.add(p);
      await sharedPreferences.setString('profiles', jsonEncode(profileList));
    } else {
      Profile p = Profile.createProfile(1);
      profileList.add(p);
      await sharedPreferences.setString('profiles', jsonEncode(profileList));
    }
    List<String>? filterList =
    await sharedPreferences.getStringList("filters");
    emit(ProfileStateListSuccess(profileList: profileList, filterList: filterList));
  }

  void _onSaveProfile(
    SaveProfile event,
    Emitter<ProfileState> emit,
  ) async {
    String? profiles = sharedPreferences.getString("profiles");
    List<Profile> profileToSave = List.empty(growable: true);
    if (profiles != null) {
      List<Profile> profileList;

      Iterable l = json.decode(profiles);
      profileList =
          List<Profile>.from(l.map((model) => Profile.fromJson(model)));
      for (var p in profileList) {
        if (p.uuid != event.profile.uuid!) {
          profileToSave.add(p);
        } else {
          profileToSave.add(event.profile);
        }
      }
      await sharedPreferences.setString('profiles', jsonEncode(profileToSave));
      List<String>? filterList =
      await sharedPreferences.getStringList("filters");
      emit(ProfileStateListSuccess(profileList: profileToSave, filterList: filterList));
      emit(ProfileStateReload());
    }
  }

  void _onSetActive(
    SetActive event,
    Emitter<ProfileState> emit,
  ) async {
    String? profiles = sharedPreferences.getString("profiles");
    List<Profile> profileToSave = List.empty(growable: true);
    if (profiles != null) {
      List<Profile> profileList;
      Iterable l = json.decode(profiles);
      profileList =
          List<Profile>.from(l.map((model) => Profile.fromJson(model)));
      for (var p in profileList) {
        if (p.uuid != event.profile.uuid!) {
          p.isActive = false;
          profileToSave.add(p);
        } else {
          p.isActive = true;
          profileToSave.add(p);
        }
      }

      await sharedPreferences.setString('profiles', jsonEncode(profileToSave));
      List<String>? filterList =
      await sharedPreferences.getStringList("filters");
      emit(ProfileStateListSuccess(profileList: profileToSave, filterList: filterList));
      emit(ProfileStateReload());
    }
  }

  void _onDeleteProfile(
    DeleteProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileStateLoading());
    String? profiles = sharedPreferences.getString("profiles");
    List<Profile> profileToSave = List.empty(growable: true);
    if (profiles != null) {
      List<Profile> profileList;
      Iterable l = json.decode(profiles);
      profileList =
          List<Profile>.from(l.map((model) => Profile.fromJson(model)));
      for (var p in profileList) {
        if (p.uuid != event.profileId) {
          profileToSave.add(p);
        }
      }
      if (profileToSave.isEmpty) {
        Profile p = Profile.createProfile(1);
        profileToSave.add(p);
      }
      await sharedPreferences.setString('profiles', jsonEncode(profileToSave));
      List<String>? filterList =
      await sharedPreferences.getStringList("filters");
      emit(ProfileStateListSuccess(profileList: profileToSave, filterList: filterList));
    }
  }

  void _onFetchProfiles(
    LoadProfiles event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileStateLoading());
    try {
      developer.log("Fetch profiles", name: "Snipe59Client");
      String? profiles = sharedPreferences.getString("profiles");
      List<Profile> profileList = List.empty(growable: true);
      if (profiles != null) {
        Iterable l = json.decode(profiles);
        profileList =
            List<Profile>.from(l.map((model) => Profile.fromJson(model)));
      } else {
        Profile p = Profile.createProfile(1);
        profileList.add(p);
        await sharedPreferences.setString('profiles', jsonEncode(profileList));
      }
      List<String>? filterList =
          await sharedPreferences.getStringList("filters");
      emit(ProfileStateListSuccess(
          profileList: profileList, filterList: filterList));
    } catch (error) {
      developer.log(error.toString(), name: 'Snipe59');
      emit(ProfileStateListError());
    }
  }
}
