import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_schedule_planner/screens/splash_screen.dart';
import 'package:todo_schedule_planner/theme/anime_theme.dart';

void main() {
  testWidgets('Splash screen loads with anime title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AnimeTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );

    // Initial frame
    await tester.pump();

    // Verify anime title appears
    expect(find.text('TASUKU'), findsOneWidget);
    expect(find.text('タスク'), findsOneWidget);
    expect(find.text('ANIME QUEST & SCHEDULE PLANNER'), findsOneWidget);
  });
}
