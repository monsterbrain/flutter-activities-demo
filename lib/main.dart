// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:developer' as dev;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'app_lifecycle/app_lifecycle.dart';
import 'audio/audio_controller.dart';
import 'firebase_options.dart';
import 'player_progress/player_progress.dart';
import 'remote_config/remote_config_service.dart';
import 'router.dart';
import 'settings/settings.dart';
import 'style/palette.dart';

void main() async {
  // Basic logging setup.
  Logger.root.level = kDebugMode ? Level.FINE : Level.INFO;
  Logger.root.onRecord.listen((record) {
    dev.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
    );
  });

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create and initialize the remote config service.
  final remoteConfigService = await RemoteConfigService.create();
  await remoteConfigService.init();

  // Put game into full screen mode on mobile devices.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Lock the game to portrait mode on mobile devices.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp(remoteConfigService: remoteConfigService));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.remoteConfigService});

  final RemoteConfigService remoteConfigService;

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          Provider(create: (context) => SettingsController()),
          Provider(create: (context) => Palette()),
          Provider(create: (context) => remoteConfigService),
          ChangeNotifierProvider(create: (context) => PlayerProgress()),
          ProxyProvider2<AppLifecycleStateNotifier, SettingsController,
              AudioController>(
            create: (context) => AudioController(),
            update: (context, lifecycleNotifier, settings, audio) {
              audio!.attachDependencies(lifecycleNotifier, settings);
              return audio;
            },
            dispose: (context, audio) => audio.dispose(),
            lazy: false,
          ),
        ],
        child: Builder(
          builder: (context) {
            final palette = context.watch<Palette>();

            return MaterialApp.router(
              title: 'My Flutter Game',
              theme: ThemeData.from(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: palette.darkPen,
                  surface: palette.backgroundMain,
                ),
                textTheme: TextTheme(
                  bodyMedium: TextStyle(color: palette.ink),
                ),
                useMaterial3: true,
              ).copyWith(
                filledButtonTheme: FilledButtonThemeData(
                  style: FilledButton.styleFrom(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
