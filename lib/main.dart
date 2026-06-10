import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/storage_service.dart';
import 'state/health_state.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final healthState = HealthState(storageService);
  await healthState.init();

  runApp(
    ChangeNotifierProvider.value(
      value: healthState,
      child: const HealthDiaryApp(),
    ),
  );
}

class HealthDiaryApp extends StatelessWidget {
  const HealthDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '健康日记',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh', 'CN'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7EC8A0),
          primary: const Color(0xFF7EC8A0),
          secondary: const Color(0xFF7EC8A0),
          surface: const Color(0xFFF5F9F6),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F9F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF7EC8A0),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
