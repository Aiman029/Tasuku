import 'package:flutter/foundation.dart';

class CalendarProvider extends ChangeNotifier {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _calendarFormat = 'month'; // "month", "week", "2weeks"

  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;
  String get calendarFormat => _calendarFormat;

  void selectDay(DateTime selected, DateTime focused) {
    _selectedDay = selected;
    _focusedDay = focused;
    notifyListeners();
  }

  void setCalendarFormat(String format) {
    _calendarFormat = format;
    notifyListeners();
  }

  void goToToday() {
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    notifyListeners();
  }
}