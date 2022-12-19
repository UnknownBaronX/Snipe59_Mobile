import 'package:equatable/equatable.dart';
import 'package:snipe59/entity/FutsovereignItem.dart';

abstract class FutsovereignState extends Equatable {
  const FutsovereignState();

  @override
  List<Object> get props => [];
}

class FutsovereignStateEmpty extends FutsovereignState {}

class FutsovereignStateLoading extends FutsovereignState {}

class FutsovereignStateSuccess extends FutsovereignState {
  const FutsovereignStateSuccess(this.items);

  final List<FutsovereignItem> items;

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'FutsovereignStateSuccess { items: ${items.length} }';
}

class FutsovereignStateError extends FutsovereignState {
  const FutsovereignStateError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
