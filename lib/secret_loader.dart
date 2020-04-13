import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:salto/secret.dart';
class SecretLoader {
  final String secretPath;

  SecretLoader({this.secretPath});
  Future<Secret> load() {
    return rootBundle.loadStructuredData<Secret>(this.secretPath,
            (jsonStr) async {
          final secret = Secret.googleServices(json.decode(jsonStr));
          return secret;
        });
  }
}