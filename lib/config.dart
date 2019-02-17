import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Allows access to the app's configuration file.
class Config {
  var _parsed;
  var ready = false;

  /// Initializes the class. NOTE: This MUST be called.
  Future<void> init() async {
    ready = true;
    return new Future<void>(() async {
      _parsed = jsonDecode(await rootBundle.loadString("res/config.json"));
    });
  }

  /// Gets a value from the config file.
  dynamic getValue(String key) {
    if (_parsed == null) {
      throw new FormatException("Couldn't load config data. Did you call init()?");
    }
    return _parsed[key];
  }
}