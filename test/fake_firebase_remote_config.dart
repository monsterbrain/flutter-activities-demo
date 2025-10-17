// Copyright 2024, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:basic/remote_config/remote_config_keys.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';

// A fake implementation of the [FirebaseRemoteConfig] that can be used in
// tests.
class FakeFirebaseRemoteConfig extends Fake implements FirebaseRemoteConfig {
  // A map of the remote config values.
  final Map<String, String> _values = {};

  // A method that returns the value of the given key.
  @override
  String getString(String key) => _values[key] ?? '';

  // A method that sets the default values for the remote config parameters.
  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    // For each key-value pair in the defaults map, add it to the values map.
    for (final key in defaults.keys) {
      _values[key] = defaults[key] as String;
    }
  }
}
