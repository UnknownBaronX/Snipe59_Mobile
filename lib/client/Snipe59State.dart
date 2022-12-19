import 'package:equatable/equatable.dart';
import 'package:snipe59/entity/FutsovereignItem.dart';

abstract class Snipe59State extends Equatable {
  const Snipe59State();

  @override
  List<Object> get props => [];
}

class Snipe59StateEmpty extends Snipe59State {}

class Snipe59StateLoading extends Snipe59State {}

class Snipe59StateSuccess extends Snipe59State {
  const Snipe59StateSuccess();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Snipe59StateSuccess';
}

class Snipe59StateError extends Snipe59State {
  const Snipe59StateError({required this.code});

  final int code;

  @override
  List<Object> get props => [code];
}
