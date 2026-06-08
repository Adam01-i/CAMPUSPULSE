// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/core/services/hive_service.dart';
import 'package:flutter_application_2/core/services/fcm_service.dart';
import 'package:flutter_application_2/core/services/local_notification_service.dart';
import 'package:flutter_application_2/core/services/schedule_listener_service.dart';
import 'package:flutter_application_2/core/services/notification_service.dart';
import 'package:flutter_application_2/features/profile/presentation/controllers/settings_providers.dart';
import 'package:flutter_application_2/features/auth/presentation/pages/auth_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalNotificationService.init();

  var notificationsEnabled = true;

  try {
    await HiveService.init();
    notificationsEnabled = HiveService.getSettingsBox()
        .get(HiveService.notificationsEnabledKey, defaultValue: true) as bool;
  } catch (_) {
    notificationsEnabled = true;
  }

  if (!notificationsEnabled) {
    return;
  }

  final title = message.notification?.title ?? 'Nouvelle notification';
  final body = message.notification?.body ?? 'Vous avez un nouveau message.';

  await LocalNotificationService.showRemoteNotification(
    title: title,
    body: body,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!Platform.isLinux) {
    try {
      await NotificationService.instance.initialize();
      await FCMService.initialize();
    } catch (_) {
      // ignore initialization errors in silent startup
    }
  }

  await initializeDateFormatting('fr_FR', null);

  runApp(
    const ProviderScope(
      child: CampusPulseApp(),
    ),
  );

  _bootstrapServices();
}

void _bootstrapServices() {
  Future.microtask(() async {
    try {
      ScheduleListenerService.startListening();
    } catch (_) {
      // ignore startup failures silently
    }

    try {
      await NotificationService.initAppReminders();
      await NotificationService.startDailyPlanningScheduler();
    } catch (_) {
      // ignore startup failures silently
    }

    if (!Platform.isLinux) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FCMService.init(user.uid);
      }

      FirebaseMessaging.onMessage.listen((message) async {
        final isEnabled = HiveService.getSettingsBox()
            .get(HiveService.notificationsEnabledKey, defaultValue: true) as bool;

        if (!isEnabled) {
          return;
        }

        final title = message.notification?.title ?? 'Nouvelle notification';
        final body = message.notification?.body ?? 'Vous avez un nouveau message.';
        await LocalNotificationService.showRemoteNotification(
          title: title,
          body: body,
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        // Handle notification tap if needed by navigating later.
      });
    }
  });
}

class CampusPulseApp extends ConsumerWidget {
  const CampusPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final themeMode = settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusPulse',
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeMode,
      home: const AuthGate(),
    );
  }
}
