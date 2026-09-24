# TASUKU - Anime Quest Planner

A stylish Flutter-based to-do and schedule planner designed around an anime-inspired productivity experience. The app helps users manage daily tasks, plan schedules, track progress, and stay motivated through a gamified quest system.

## Overview

TASUKU blends productivity with a playful theme inspired by anime and role-playing game progression. Instead of a plain checklist, users can treat tasks as missions, complete daily quests, and monitor their momentum through progress statistics and calendar planning.

## Features

- Task creation, editing, and deletion
- Task completion tracking with progress updates
- Daily quest style dashboard and level-based motivation system
- Calendar view for planning tasks by date
- Reminder and notification support for upcoming tasks
- Progress statistics and productivity insights
- Anime-themed interface with sakura effects and mascot-inspired visuals
- Local data storage using Hive for fast offline persistence
- Responsive and modern mobile UI built with Flutter

## Tech Stack

- Flutter & Dart
- Provider for state management
- Hive + Hive Flutter for local database storage
- Table Calendar for date-based planning
- Flutter Local Notifications for reminders
- Intl for date/time formatting
- Fl Chart for analytics and chart views
- Material Design UI with custom anime-inspired theming

## Project Structure

```text
lib/
  main.dart
  models/
  providers/
  screens/
  services/
  theme/
  utils/
  widgets/
  
test/
  widget_test.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or newer)
- Android Studio / VS Code with Flutter plugins
- An emulator or physical device

### Installation

1. Clone the repository:

```bash
git clone https://github.com/your-username/list.git
cd list
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Usage

- Add tasks from the main dashboard
- Mark tasks as completed to gain progress and level-up rewards
- Open the calendar to view scheduled tasks by date
- Check stats to review progress trends
- Use reminders to stay on top of deadlines and daily routines

## Notes

This project is built as a personal productivity app with a themed user experience. It is ideal for users who want a more engaging alternative to a traditional to-do list while still keeping workflow and scheduling simple and effective.

## License

This project is currently unlicensed unless specified otherwise.
