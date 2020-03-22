import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:salto/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../secret.dart';
import '../secret_loader.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return this.token != null;
  }

  String get token {
    if (this._expiryDate != null &&
        this._expiryDate.isAfter(DateTime.now()) &&
        this._token != null) {
      return this._token;
    }
    return null;
  }

  String get userId {
    return this._userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    try {
      Future<Secret> secret = SecretLoader(secretPath: "secrets.json").load();
      await secret.then((secret) async {
        final url =
            'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=${secret.apiKey}';
        final response = await http.post(url,
            body: json.encode({
              'email': email,
              'password': password,
              'returnSecureToken': true,
            }));
        final responseData = json.decode(response.body);
        print(responseData);
        if (responseData['error'] != null) {
          throw HttpException(responseData['error']['message']);
        }
        this._token = responseData['idToken'];
        this._userId = responseData['localId'];
        this._expiryDate = DateTime.now()
            .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      });
      this._autoLogout();
      this.notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': this._token,
        'userId': this._userId,
        'expiryDate': this._expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    return this._authenticate(email, password, 'signInWithPassword');
  }

  Future<void> signup(String email, String password) async {
    return this._authenticate(email, password, 'signUp');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    this._token = extractedUserData['token'];
    this._userId = extractedUserData['userId'];
    this._expiryDate = expiryDate;
    this.notifyListeners();
  }

  Future<void> logout() async {
    this._userId = null;
    this._token = null;
    this._expiryDate = null;
    if (this._authTimer != null) {
      this._authTimer.cancel();
      this._authTimer = null;
    }
    this.notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (this._authTimer != null) {
      this._authTimer.cancel();
    }
    final timeToExpiry = this._expiryDate.difference(DateTime.now()).inSeconds;
    this._authTimer = Timer(Duration(seconds: timeToExpiry), this.logout);
  }
}
