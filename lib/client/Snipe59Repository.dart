import 'package:snipe59/client/FutsovereignClient.dart';
import 'package:snipe59/client/Snipe59Client.dart';
import 'package:snipe59/entity/Futsovereign.dart';
import 'package:snipe59/entity/FutsovereignItem.dart';

import '../entity/Licence.dart';
import '../entity/ShowView.dart';

class Snipe59Repository {
  Snipe59Repository(this.client);

  final Snipe59Client client;

  Future<Licence> fetchLicence(String licence) async {
    final result = await client.fetchLicence(licence);
    return result;
  }

  Future<bool> fetchShowView() async{
    return await client.fetchShowView();
  }
}
