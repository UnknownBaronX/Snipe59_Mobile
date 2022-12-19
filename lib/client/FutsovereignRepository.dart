import 'package:snipe59/client/FutsovereignClient.dart';
import 'package:snipe59/entity/Futsovereign.dart';
import 'package:snipe59/entity/FutsovereignItem.dart';

class FutsovereignRepository {
  FutsovereignRepository(this.client);

  final FutsovereignClient client;
  List<FutsovereignItem>? items;

  Future<Futsovereign> getPrices() async {
    final result = await client.getPrices();
    return result;
  }

  Future<bool> isOnline() async {
    final result = await client.isOnline();
    return result;
  }



  void setItems(items) {
    this.items = items;
  }
}
