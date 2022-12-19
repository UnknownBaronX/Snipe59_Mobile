import 'FutsovereignItem.dart';

class Futsovereign {
  const Futsovereign({required this.items});

  final List<FutsovereignItem> items;

  static Futsovereign fromJson(List<dynamic> json) {
    final items = json
        .map((dynamic item) =>
            FutsovereignItem.fromJson(item as Map<String, dynamic>))
        .toList();
    return Futsovereign(items: items);
  }
}
