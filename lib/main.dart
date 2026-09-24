import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'providers/task_provider.dart';
import 'providers/calendar_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/anime_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await DatabaseService.init(); // register adapter + open box
  await NotificationService().init(); // setup notification channel + permission

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: MaterialApp(
        title: 'TASUKU - Anime Quest Planner',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: AnimeTheme.lightTheme,
        darkTheme: AnimeTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}