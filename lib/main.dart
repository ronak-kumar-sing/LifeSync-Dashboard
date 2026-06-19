import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/sync/sync_engine.dart';
import 'core/storage/hive_storage.dart';
import 'features/income/providers/income_provider.dart';
import 'features/calendar/providers/calendar_provider.dart';
import 'features/water/providers/water_provider.dart';
import 'features/analytics/providers/analytics_provider.dart';
import 'features/ai_agent/providers/ai_agent_provider.dart';
import 'platforms/macos/macos_app.dart';
import 'platforms/android/android_app.dart';
import 'widgets/shared/app_layout.dart';
import 'core/models/app_state.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await _initializeApp();

  runApp(const LifeSyncApp());
}

Future<void> _initializeApp() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init failed (offline mode): $e');
  }

  await Hive.initFlutter();
  await HiveStorage.initialize();
  await SyncEngine.initialize();
}

class LifeSyncApp extends StatelessWidget {
  const LifeSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => AIAgentProvider()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'LifeSync Dashboard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const AdaptiveLayout(),
      ),
    );
  }
}
