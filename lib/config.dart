import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

/// Allows access to the app's configuration file.
class Config {
  Map<String, dynamic> parsed;

  /// Initializes the class. NOTE: This MUST be called.
  Future<void> init() async {
    return new Future<void>(() async {
      var json = await rootBundle.loadString("res/config.json");
      parsed = jsonDecode(json);
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