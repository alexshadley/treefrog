import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Allows access to the app's configuration file.
class Config {
  var parsed;

  /// Initializes the class. NOTE: This MUST be called.
  Future<void> init() async {
    return new Future<void>(() async {
      parsed = jsonDecode(await rootBundle.loadString("res/config.json"));
    });
  }

  /// Gets a value from the config file.
  dynamic getValue(String key) {
    if (parsed == null) {
      throw new FormatException("Couldn't load config data. Did you call init()?");
    }
    return parsed[key];
  }
}