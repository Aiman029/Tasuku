import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo_schedule_planner/providers/calendar_provider.dart';
import 'package:todo_schedule_planner/providers/navigation_provider.dart';
import 'package:todo_schedule_planner/providers/task_provider.dart';
import 'package:todo_schedule_planner/screens/focus_dungeon_screen.dart';
import 'package:todo_schedule_planner/screens/main_navigation_screen.dart';
import 'package:todo_schedule_planner/theme/anime_theme.dart';
import 'package:todo_schedule_planner/widgets/floating_island_nav_bar.dart';

void main() {
  group('NavigationProvider Tests', () {
    test('Initial tab is quests (index 0) and timer not running', () {
      final provider = NavigationProvider();
      expect(provider.currentIndex, 0);
      expect(provider.currentTab, MainTab.quests);
      expect(provider.isDungeonTimerRunning, false);
    });

    test('setIndex and setTab update index and currentTab correctly', () {
      final provider = NavigationProvider();

      provider.setIndex(1);
      expect(provider.currentIndex, 1);
      expect(provider.currentTab, MainTab.calendar);

      provider.setTab(MainTab.dungeon);
      expect(provider.currentIndex, 2);
      expect(provider.currentTab, MainTab.dungeon);

      provider.setTab(MainTab.stats);
      expect(provider.currentIndex, 3);
      expect(provider.currentTab, MainTab.stats);
    });

    test('setDungeonTimerRunning notifies state updates', () {
      final provider = NavigationProvider();
      provider.setDungeonTimerRunning(true);
      expect(provider.isDungeonTimerRunning, true);

      provider.setDungeonTimerRunning(false);
      expect(provider.isDungeonTimerRunning, false);
    });
  });

  group('FloatingIslandNavBar Widget Tests', () {
    testWidgets('Renders all 4 navigation items with labels and Japanese sublabels',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => NavigationProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => CalendarProvider()),
          ],
          child: MaterialApp(
            theme: AnimeTheme.lightTheme,
            home: const Scaffold(
              bottomNavigationBar: FloatingIslandNavBar(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Quests'), findsOneWidget);
      expect(find.text('クエスト'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Dungeon'), findsOneWidget);
      expect(find.text('Guild'), findsOneWidget);
    });

    testWidgets('Tapping Calendar tab switches NavigationProvider index to 1',
        (tester) async {
      final navProvider = NavigationProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: navProvider),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => CalendarProvider()),
          ],
          child: MaterialApp(
            theme: AnimeTheme.lightTheme,
            home: const Scaffold(
              bottomNavigationBar: FloatingIslandNavBar(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on Calendar item
      await tester.tap(find.text('Calendar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(navProvider.currentIndex, 1);
      expect(navProvider.currentTab, MainTab.calendar);

      // Tap on Dungeon item
      await tester.tap(find.text('Dungeon'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(navProvider.currentIndex, 2);
      expect(navProvider.currentTab, MainTab.dungeon);
    });

    testWidgets('MainNavigationScreen displays active screen per selected tab',
        (tester) async {
      final navProvider = NavigationProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: navProvider),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => CalendarProvider()),
          ],
          child: MaterialApp(
            theme: AnimeTheme.lightTheme,
            home: const MainNavigationScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Initial tab is Quests
      expect(find.text('Daily Quests ⚔️'), findsOneWidget);

      // Switch to Dungeon
      navProvider.setIndex(2);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Focus Dungeon 🔥'), findsOneWidget);
    });
  });

  group('FocusDungeonScreen Widget Tests', () {
    testWidgets('Displays timer modes, initial countdown, and mascot mentorship card',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => NavigationProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
          ],
          child: MaterialApp(
            theme: AnimeTheme.lightTheme,
            home: const FocusDungeonScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Focus Dungeon 🔥'), findsOneWidget);
      expect(find.text('Novice Quest 🥋'), findsOneWidget);
      expect(find.text('Hashira Focus ⚡'), findsOneWidget);
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('Commence Quest'), findsOneWidget);
      expect(find.text('Tasu-chan Mentorship'), findsOneWidget);
    });

    testWidgets('Switching mode updates countdown timer display', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => NavigationProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
          ],
          child: MaterialApp(
            theme: AnimeTheme.lightTheme,
            home: const FocusDungeonScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Initial Novice mode is 25:00
      expect(find.text('25:00'), findsOneWidget);

      // Select Hashira Focus 50 min
      await tester.tap(find.text('Hashira Focus ⚡'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('50:00'), findsOneWidget);

      // Select Chakra Rest 5 min
      await tester.tap(find.text('Chakra Rest 🍵'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('05:00'), findsOneWidget);
    });
  });
}
