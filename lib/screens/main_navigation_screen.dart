import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/floating_island_nav_bar.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'focus_dungeon_screen.dart';
import 'stats_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();

    return Scaffold(
      body: Stack(
        children: [

          IndexedStack(
            index: navProvider.currentIndex,
            children: const [
              HomeScreen(),
              CalendarScreen(),
              FocusDungeonScreen(),
              StatsScreen(),
            ],
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingIslandNavBar(),
          ),
        ],
      ),
    );
  }
}
