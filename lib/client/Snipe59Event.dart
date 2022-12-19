import 'package:equatable/equatable.dart';

abstract class Snipe59Event extends Equatable {
  const Snipe59Event();
}

class ResetLicence extends Snipe59Event {
  @override
  List<Object> get props => [];
}

class FetchLicence extends Snipe59Event {
  const FetchLicence({required this.licence});

  final String licence;

  @override
  List<Object> get props => [licence];

  @override
  String toString() => 'FetchLicence';
}
