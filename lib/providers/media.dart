import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Media with ChangeNotifier {
  static const url = "gs://salto-7fab8.appspot.com";
  String authString;
  final String authToken;
  dynamic _media;

  Media(this.authToken, this._media) {
    this.authString = '?auth=$authToken';
  }

  Object get media {
    return this._media;
  }

  Future<void> getVideo(String contentItemId) async {
    final response = await http.get('$url/videos/$contentItemId.json$authString');
    final extracted = json.decode(response.body) as Map<String, dynamic>;
    if (extracted == null) return;
    this._media = extracted;
    print("Loaded video from database.");
    this.notifyListeners();
  }
}