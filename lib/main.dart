// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
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
    await NotificationService.instance.initialize();
  }

  await initializeDateFormatting('fr_FR', null);

  runApp(
    const ProviderScope(
      child: CampusPulseApp(),
    ),
  );
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