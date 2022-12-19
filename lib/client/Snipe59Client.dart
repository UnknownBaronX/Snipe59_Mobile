import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:snipe59/entity/Futsovereign.dart';
import 'dart:developer' as developer;

import 'package:snipe59/entity/Licence.dart';

class Snipe59Client {
  Snipe59Client({
    http.Client? httpClient,
    this.baseUrl = "https://futstarz.com/wp-json/lmfwc/v2/licenses",
  }) : this.httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client httpClient;

  Future<Licence> fetchLicence(String licence) async {
    final response = await httpClient.get(Uri.parse(
        "$baseUrl/$licence?consumer_key=ck_5cd18f4adb18fcda3481528335234b66b80b729e&consumer_secret=cs_5e48df88dcb579c73256b6f823b46beb08e2104d"));
    final results = json.decode(response.body);
    developer.log(response.toString(), name: "Snipe59Client");
    developer.log(results.toString(), name: "Snipe59Client");
    if (response.statusCode == 200) {
      return Licence.fromJson(results);
    } else {
      throw Future.error(response.statusCode);
    }
  }
}
