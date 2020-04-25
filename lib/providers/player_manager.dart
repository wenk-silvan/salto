import 'package:flutter/material.dart';

class PlayerManager with ChangeNotifier {
  bool _isPlaying;

  PlayerManager() {
    _isPlaying = false;
  }

  bool get isPlaying {
    return _isPlaying;
}

  void reset() {
    _isPlaying = false;
  }

  void stopAllPlayers() {
    _isPlaying = true;
    this.notifyListeners();
  }
}