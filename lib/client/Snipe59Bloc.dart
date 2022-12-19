import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:snipe59/client/FutsovereignEvent.dart';
import 'package:snipe59/client/FutsovereignRepository.dart';
import 'package:snipe59/client/FutsovereignState.dart';
import 'package:snipe59/client/Snipe59Event.dart';
import 'package:snipe59/client/Snipe59Repository.dart';
import 'package:snipe59/client/Snipe59State.dart';
import 'package:snipe59/entity/FutsovereignItem.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:developer' as developer;

const _duration = const Duration(milliseconds: 50);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class Snipe59Bloc extends Bloc<Snipe59Event, Snipe59State> {
  Snipe59Bloc(  {required this.snipe59Repository, required this.futsovereignRepository}) : super(Snipe59StateEmpty()) {
    on<FetchLicence>(_onFetchLicence, transformer: debounce(_duration));
    on<ResetLicence>(_onResetLicence, transformer: debounce(_duration));

  }

  final Snipe59Repository snipe59Repository;
  final FutsovereignRepository futsovereignRepository;

  void _onResetLicence(
    ResetLicence event,
    Emitter<Snipe59State> emit,
  ) async {
    emit(Snipe59StateEmpty());
  }

  void _onFetchLicence(
    FetchLicence event,
    Emitter<Snipe59State> emit,
  ) async {
    emit(Snipe59StateLoading());
    try {
       var online = await futsovereignRepository.isOnline();
        if(!online) {
          emit(const Snipe59StateError(code: 500));
          return;
        }
      
      if(event.licence == "FREE"){
        emit(const Snipe59StateSuccess());
        return;
      }
      
      var licence = await snipe59Repository.fetchLicence(event.licence);
      DateTime dt = DateTime.parse(licence.data!.expiresAt!);
      if (dt.isAfter(DateTime.now()) && licence.data!.status! == 2) {
        developer.log("Licence date valid", name: "Snipe59");
        emit(const Snipe59StateSuccess());
      } else {
        developer.log("Licence date invalid", name: "Snipe59");
        emit(const Snipe59StateError(code: -1));
      }
    } catch (error) {
      developer.log(error.toString(), name: 'Snipe59');
      emit(const Snipe59StateError(code: 404));
      //emit(const Snipe59StateSuccess());

    }
  }


}
