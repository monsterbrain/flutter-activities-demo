
// Copyright 2024, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:developer' as dev;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import 'remote_config_keys.dart';

// A service that handles the remote config.
class RemoteConfigService {
  // The remote config instance.
  final FirebaseRemoteConfig _remoteConfig;

  // A private constructor.
  RemoteConfigService._(this._remoteConfig);

  // A static factory method that creates a new instance of the service.
  static Future<RemoteConfigService> create() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    // Fetch and activate the remote config values.
    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      dev.log('Error fetching remote config: $e');
    }

    return RemoteConfigService._(remoteConfig);
  }

  // A method that initializes the remote config.
  Future<void> init() async {
    // Set the default values for the remote config parameters.
    await _remoteConfig.setDefaults({
      RemoteConfigKeys.season: 'normal',
    });

    // Set the minimum fetch interval.
    if (kDebugMode) {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(seconds: 1),
        ),
      );
    }
  }

  // A method that returns the value of the season parameter.
  String get season => _remoteConfig.getString(RemoteConfigKeys.season);
}
