import 'package:bloc/bloc.dart';
import 'package:snipe59/client/FutsovereignEvent.dart';
import 'package:snipe59/client/FutsovereignRepository.dart';
import 'package:snipe59/client/FutsovereignState.dart';
import 'package:snipe59/entity/FutsovereignItem.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:developer' as developer;

const _duration = const Duration(milliseconds: 50);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class FutsovereignBloc extends Bloc<FutsovereignEvent, FutsovereignState> {
  FutsovereignBloc({required this.futsovereignRepository})
      : super(FutsovereignStateEmpty()) {
    on<PriceRequested>(_onPriceRequested, transformer: debounce(_duration));
    on<FilterPlayer>(_onFilterPlayer, transformer: debounce(_duration));
  }

  final FutsovereignRepository futsovereignRepository;

  void _onFilterPlayer(
    FilterPlayer event,
    Emitter<FutsovereignState> emit,
  ) async {
    emit(FutsovereignStateLoading());
    var items = futsovereignRepository.items;
    var result = List<FutsovereignItem>.empty(growable: true);
    if (items != null) {
      if (event.text.isEmpty)
        emit(FutsovereignStateSuccess(items));
      else {
        result.addAll(items.where((e) => e.playerFullName!
            .toLowerCase()
            .contains(event.text.toLowerCase())));
        emit(FutsovereignStateSuccess(result));
      }
    } else {
      _onPriceRequested(PriceRequested(console: event.console), emit);
    }
  }

  void _onPriceRequested(
    PriceRequested event,
    Emitter<FutsovereignState> emit,
  ) async {
    emit(FutsovereignStateLoading());

    try {
      final results = await futsovereignRepository.getPrices();
      if (event.console == "ps")
        results.items
            .sort((a, b) => b.currentPricePs4!.compareTo(a.currentPricePs4!));
      else
        results.items
            .sort((a, b) => b.currentPriceXbox!.compareTo(a.currentPriceXbox!));
      futsovereignRepository.setItems(results.items);
      emit(FutsovereignStateSuccess(results.items));
    } catch (error) {
      developer.log(error.toString(), name: 'Snipe59');
      emit(FutsovereignStateError('something went wrong'));
    }
  }
}
