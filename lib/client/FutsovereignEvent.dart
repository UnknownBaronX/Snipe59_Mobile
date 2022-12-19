import 'package:equatable/equatable.dart';

abstract class FutsovereignEvent extends Equatable {
  const FutsovereignEvent();
}

class PriceRequested extends FutsovereignEvent {
  const PriceRequested({required this.console});

  final String console;

  @override
  List<Object> get props => [console];

  @override
  String toString() => 'PriceRequested';
}

class FilterPlayer extends FutsovereignEvent {
  const FilterPlayer({required this.text, required this.console});

  final String text;
  final String console;

  @override
  List<Object> get props => [text, console];

  @override
  String toString() => 'FilterPlayer $text';
}
