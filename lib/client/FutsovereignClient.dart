import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:snipe59/entity/Futsovereign.dart';

class FutsovereignClient {
  FutsovereignClient({
    http.Client? httpClient,
    this.baseUrl =
        "https://futsovereign.com/futsovereign/v1/dixeam/player/mobileapi?licenseKey=FREE",
  }) : this.httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client httpClient;

  Future<Futsovereign> getPrices() async {

    final response = await httpClient.get(Uri.parse("$baseUrl"));

    final results = json.decode(response.body);
    if (response.statusCode == 200) {
      return Futsovereign.fromJson(results);
    } else {
      throw Future.error(response.statusCode);
    }
  }

  //function to check if snipe59 is online, if not return message
  Future<bool> isOnline() async {
    const String onlineUrl =
        "https://futsovereign.com/futsovereign/status/mobile";
    try {
      final response = await httpClient.get(Uri.parse(onlineUrl));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
