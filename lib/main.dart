// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/services/schedule_listener_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!Platform.isLinux) {
    try {
      await NotificationService.instance.initialize();
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
      await NotificationService.initAppReminders(); // optional background startup
    } catch (_) {
      // ignore startup failures silently
    }
  });
}

class CampusPulseApp extends StatelessWidget {
  const CampusPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusPulse',
      theme: ThemeData(useMaterial3: true),
      home: const AuthGate(),
    );
  }
}