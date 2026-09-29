import 'package:flutter/foundation.dart';

enum MainTab {
  quests,
  calendar,
  dungeon,
  stats,
}

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isDungeonTimerRunning = false;

  int get currentIndex => _currentIndex;
  MainTab get currentTab => MainTab.values[_currentIndex];
  bool get isDungeonTimerRunning => _isDungeonTimerRunning;

  void setIndex(int index) {
    if (index >= 0 && index < MainTab.values.length && _currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void setTab(MainTab tab) {
    setIndex(tab.index);
  }

  void setDungeonTimerRunning(bool isRunning) {
    if (_isDungeonTimerRunning != isRunning) {
      _isDungeonTimerRunning = isRunning;
      notifyListeners();
    }
  }
}
