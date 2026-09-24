import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/date_helper.dart';
import '../theme/anime_theme.dart';
import '../widgets/sakura_particles.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _newCheckpointController = TextEditingController();
  bool _isAddingCheckpoint = false;

  @override
  void dispose() {
    _newCheckpointController.dispose();
    super.dispose();
  }

  void _handleAddCheckpoint(String taskId) {
    final text = _newCheckpointController.text.trim();
    if (text.isEmpty) return;

    context.read<TaskProvider>().addSubTask(taskId, text);
    _newCheckpointController.clear();
    setState(() {
      _isAddingCheckpoint = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AnimeColors.animeViolet,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Row(
          children: [
            Text('✨', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text('Checkpoint added! 📋',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final current = taskProvider.allTasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );

    final rankColor = AnimeColors.getPriorityColor(current.priority);
    final rankLabel = AnimeColors.getRankLabel(current.priority);
    final categoryIcon = AnimeColors.getCategoryIcon(current.category);
    final overdue = !current.isDone && DateHelper.isOverdue(current.dueDate);
    final subtasks = current.subtasks;
    final totalSubtasks = subtasks.length;
    final completedSubtasks = current.completedSubtasks;
    final subtaskProgress = current.subtaskProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'クエスト詳細',
              style: TextStyle(
                fontSize: 11,
                color: AnimeColors.sakuraPink,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Quest Briefing 📜',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AnimeColors.flameCrimson),
            onPressed: () {
              context.read<TaskProvider>().deleteTask(current.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AnimeColors.flameCrimson,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  content: const Text('Quest abandoned and removed.'),
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SakuraPetalsOverlay(
        petalCount: 14,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          physics: const BouncingScrollPhysics(),
          children: [
            // Quest Title & Rank Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AnimeColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: current.isDone
                      ? (isDark ? Colors.white12 : Colors.black12)
                      : rankColor.withAlpha(isDark ? 80 : 50),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: current.isDone
                        ? Colors.transparent
                        : rankColor.withAlpha(isDark ? 30 : 20),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: rankColor.withAlpha(isDark ? 60 : 35),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: rankColor, width: 1.2),
                        ),
                        child: Text(
                          rankLabel,
                          style: TextStyle(
                            color: rankColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : const Color(0xFFF0EBF8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(categoryIcon,
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              current.category,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (current.isDone)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AnimeColors.sakuraPink.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'CLEARED 🏆',
                            style: TextStyle(
                              color: AnimeColors.sakuraPink,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    current.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      decoration:
                          current.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: AnimeColors.sakuraPink,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Checkpoints / Sub-tasks Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AnimeColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AnimeColors.sakuraPink.withAlpha(isDark ? 60 : 40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('📋', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          const Text(
                            'Checkpoints',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (totalSubtasks > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: completedSubtasks == totalSubtasks
                                    ? AnimeColors.sakuraPink
                                    : AnimeColors.sakuraPink.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$completedSubtasks / $totalSubtasks',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: completedSubtasks == totalSubtasks
                                      ? Colors.white
                                      : AnimeColors.sakuraPink,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isAddingCheckpoint = !_isAddingCheckpoint;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AnimeColors.sakuraPink,
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: Icon(
                          _isAddingCheckpoint ? Icons.close : Icons.add_circle,
                          size: 18,
                        ),
                        label: Text(
                          _isAddingCheckpoint ? 'Cancel' : 'Add Step',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Progress Bar for Checkpoints
                  if (totalSubtasks > 0) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: subtaskProgress,
                        minHeight: 8,
                        backgroundColor: isDark
                            ? Colors.white10
                            : AnimeColors.sakuraPink.withAlpha(20),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AnimeColors.sakuraPink,
                        ),
                      ),
                    ),
                  ],

                  // Inline Input for Adding Checkpoint
                  if (_isAddingCheckpoint) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newCheckpointController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Enter checkpoint title...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                            onSubmitted: (_) => _handleAddCheckpoint(current.id),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () => _handleAddCheckpoint(current.id),
                          style: IconButton.styleFrom(
                            backgroundColor: AnimeColors.sakuraPink,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.check, size: 20),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Checkpoints List
                  if (subtasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No checkpoints yet. Break this quest into steps using "Add Step" above! ✨',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? AnimeColors.textSubDark
                              : AnimeColors.textSubLight,
                        ),
                      ),
                    )
                  else
                    ...subtasks.map((cp) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cp.isDone
                              ? (isDark
                                  ? Colors.white.withAlpha(8)
                                  : Colors.black.withAlpha(6))
                              : (isDark
                                  ? AnimeColors.cardDarkSurface
                                  : const Color(0xFFFAF7FC)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cp.isDone
                                ? Colors.transparent
                                : (isDark ? Colors.white12 : Colors.black12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: cp.isDone,
                              activeColor: AnimeColors.sakuraPink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              onChanged: (_) {
                                context
                                    .read<TaskProvider>()
                                    .toggleSubTask(current.id, cp.id);
                              },
                            ),
                            Expanded(
                              child: Text(
                                cp.title,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  decoration: cp.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: AnimeColors.sakuraPink,
                                  color: cp.isDone
                                      ? (isDark ? Colors.white38 : Colors.black38)
                                      : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: isDark ? Colors.white30 : Colors.black26,
                              onPressed: () {
                                context
                                    .read<TaskProvider>()
                                    .deleteSubTask(current.id, cp.id);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Description / Briefing Card
            if (current.description.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AnimeColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AnimeColors.sakuraPink.withAlpha(isDark ? 50 : 35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('📝', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          'Mission Briefing',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      current.description,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: isDark
                            ? Colors.white.withAlpha(220)
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Schedule & Timing Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AnimeColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AnimeColors.sakuraPink.withAlpha(isDark ? 50 : 35),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (overdue
                                ? AnimeColors.flameCrimson
                                : AnimeColors.sakuraPink)
                            .withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.event,
                        color: overdue
                            ? AnimeColors.flameCrimson
                            : AnimeColors.sakuraPink,
                        size: 22,
                      ),
                    ),
                    title: const Text(
                      'Deadline',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: Text(
                      overdue
                          ? 'OVERDUE • ${DateHelper.formatDate(current.dueDate)}'
                          : DateHelper.formatDate(current.dueDate),
                      style: TextStyle(
                        color: overdue ? AnimeColors.flameCrimson : null,
                        fontWeight:
                            overdue ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AnimeColors.animeViolet.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: AnimeColors.animeViolet,
                        size: 22,
                      ),
                    ),
                    title: const Text(
                      'Reminder Alarm',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: Text(
                      current.reminderTime != null
                          ? DateHelper.formatDateTime(current.reminderTime!)
                          : 'No reminder alarm scheduled',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Mark as Cleared / Pending Action Button
            Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: current.isDone
                    ? const LinearGradient(
                        colors: [Color(0xFF8E8D9A), Color(0xFF6C6A7B)],
                      )
                    : AnimeColors.sakuraGradient,
                boxShadow: [
                  BoxShadow(
                    color: current.isDone
                        ? Colors.black26
                        : AnimeColors.sakuraPink.withAlpha(100),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    context.read<TaskProvider>().toggleTaskStatus(current.id);
                    if (!current.isDone) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AnimeColors.sakuraPink,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          content: const Row(
                            children: [
                              Text('✨', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 8),
                              Text(
                                'Quest Cleared! +50 EXP ✨ 素晴らしい!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          current.isDone
                              ? Icons.undo
                              : Icons.check_circle_outline,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          current.isDone
                              ? 'Reactivate Quest ⚔️'
                              : 'Clear Quest (+50 EXP) 🏆',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}