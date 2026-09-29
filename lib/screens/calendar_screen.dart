import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/task_provider.dart';
import '../providers/calendar_provider.dart';
import '../widgets/task_tile.dart';
import '../theme/anime_theme.dart';
import '../widgets/sakura_particles.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final calendarProvider = context.watch<CalendarProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tasksForSelectedDay =
        taskProvider.getTasksForDate(calendarProvider.selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'カレンダー',
              style: TextStyle(
                fontSize: 11,
                color: AnimeColors.sakuraPink,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Quest Calendar 📅',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => calendarProvider.goToToday(),
              style: TextButton.styleFrom(
                foregroundColor: AnimeColors.sakuraPink,
                backgroundColor: AnimeColors.sakuraPink.withAlpha(25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              icon: const Icon(Icons.today, size: 16),
              label: const Text(
                'Today',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: SakuraPetalsOverlay(
        petalCount: 14,
        child: Column(
          children: [
            // Calendar Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? AnimeColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AnimeColors.sakuraPink.withAlpha(isDark ? 50 : 35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AnimeColors.sakuraPink.withAlpha(isDark ? 20 : 15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: calendarProvider.focusedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(calendarProvider.selectedDay, day),
                onDaySelected: (selected, focused) {
                  calendarProvider.selectDay(selected, focused);
                },
                onPageChanged: (focused) {
                  calendarProvider.selectDay(
                      calendarProvider.selectedDay, focused);
                },
                eventLoader: (day) => taskProvider.getTasksForDate(day),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AnimeColors.animeViolet.withAlpha(80),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AnimeColors.animeViolet,
                      width: 1.5,
                    ),
                  ),
                  selectedDecoration: const BoxDecoration(
                    gradient: AnimeColors.sakuraGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66FF5E86),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AnimeColors.sakuraPink,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                  markerSize: 5.5,
                  markerMargin: const EdgeInsets.symmetric(horizontal: 1.2),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: AnimeColors.sakuraPink),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: AnimeColors.sakuraPink),
                ),
              ),
            ),

            // Section Header: Tasks on selected day
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('📜', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '${tasksForSelectedDay.length} Quests on this date',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AnimeColors.sakuraPink,
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text(
                      'Add Quest',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Task list for day or empty
            Expanded(
              child: tasksForSelectedDay.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wb_twilight_rounded,
                            size: 48,
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No quests for this day.\nEnjoy your peaceful rest! 🌸',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AnimeColors.textSubDark
                                  : AnimeColors.textSubLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasksForSelectedDay.length,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 110),
                      itemBuilder: (context, index) {
                        final task = tasksForSelectedDay[index];
                        return TaskTile(
                          task: task,
                          onToggle: () =>
                              taskProvider.toggleTaskStatus(task.id),
                          onDelete: () => taskProvider.deleteTask(task.id),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskDetailScreen(task: task),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}