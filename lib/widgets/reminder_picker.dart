import 'package:flutter/material.dart';
import '../utils/date_helper.dart';
import '../theme/anime_theme.dart';

class ReminderPicker extends StatelessWidget {
  final DateTime? selectedDateTime;
  final ValueChanged<DateTime?> onChanged;
  final String label;

  const ReminderPicker({
    super.key,
    required this.selectedDateTime,
    required this.onChanged,
    this.label = 'Notification Bell / Reminder',
  });

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AnimeColors.sakuraPink,
                ),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AnimeColors.sakuraPink,
                ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    onChanged(combined);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AnimeColors.animeViolet.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.notifications_active_outlined,
          color: AnimeColors.animeViolet,
          size: 22,
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      subtitle: Text(
        selectedDateTime != null
            ? DateHelper.formatDateTime(selectedDateTime!)
            : 'No reminder alarm set',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: selectedDateTime != null
          ? IconButton(
              icon: const Icon(Icons.clear, color: AnimeColors.sakuraPink),
              onPressed: () => onChanged(null),
            )
          : TextButton(
              onPressed: () => _pickDateTime(context),
              child: const Text('Set Time'),
            ),
      onTap: () => _pickDateTime(context),
    );
  }
}