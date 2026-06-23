import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/openalex_service.dart';
import 'state/research_controller.dart';

void main() {
  const apiKey = String.fromEnvironment('OPENALEX_API_KEY');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ResearchController(
        OpenAlexService(apiKey: apiKey.isEmpty ? null : apiKey),
      ),
      child: const JournalTrendAnalyzerApp(),
    ),
  );
}

class JournalTrendAnalyzerApp extends StatelessWidget {
  const JournalTrendAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResearchController>();
    const seed = Color(0xFF0F766E);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Journal Trend Analyzer',
      themeMode: controller.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          secondary: const Color(0xFFF59E0B),
          tertiary: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAF9),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          secondary: const Color(0xFFF59E0B),
          tertiary: const Color(0xFF3B82F6),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1312),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
