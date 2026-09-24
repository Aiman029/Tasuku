import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/date_helper.dart';
import '../theme/anime_theme.dart';

class TaskTile extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkAnimController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _checkAnimController,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.task.isDone) {
      _checkAnimController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.isDone != oldWidget.task.isDone) {
      if (widget.task.isDone) {
        _checkAnimController.forward(from: 0.0);
      } else {
        _checkAnimController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overdue =
        !widget.task.isDone && DateHelper.isOverdue(widget.task.dueDate);
    final rankColor = AnimeColors.getPriorityColor(widget.task.priority);
    final rankLabel = AnimeColors.getRankLabel(widget.task.priority);
    final categoryIcon = AnimeColors.getCategoryIcon(widget.task.category);

    return Dismissible(
      key: Key(widget.task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Colors.transparent, Color(0xFFFF3366)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '斬 • Dismiss',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_sweep, color: Colors.white, size: 24),
          ],
        ),
      ),
      onDismissed: (_) => widget.onDelete(),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AnimeColors.cardDark : AnimeColors.cardLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.task.isDone
                  ? (isDark ? Colors.white12 : Colors.black12)
                  : rankColor.withAlpha(isDark ? 80 : 60),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.task.isDone
                    ? Colors.transparent
                    : rankColor.withAlpha(isDark ? 30 : 22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: widget.onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Anime Checkmark Button with pulse/sparkle
                    GestureDetector(
                      onTap: () {
                        widget.onToggle();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: AnimatedBuilder(
                          animation: _checkAnimController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: widget.task.isDone
                                  ? _scaleAnimation.value
                                  : 1.0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: widget.task.isDone
                                      ? AnimeColors.sakuraGradient
                                      : null,
                                  border: Border.all(
                                    color: widget.task.isDone
                                        ? AnimeColors.sakuraPink
                                        : (isDark
                                            ? AnimeColors.animeLavender
                                                .withAlpha(120)
                                            : AnimeColors.sakuraPink
                                                .withAlpha(150)),
                                    width: 2.2,
                                  ),
                                  boxShadow: widget.task.isDone
                                      ? [
                                          BoxShadow(
                                            color: AnimeColors.sakuraPink
                                                .withAlpha(100),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : null,
                                ),
                                child: widget.task.isDone
                                    ? const Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Main Task Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rank & Category chips row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: rankColor.withAlpha(isDark ? 50 : 35),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: rankColor.withAlpha(120),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  rankLabel,
                                  style: TextStyle(
                                    color: rankColor,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white10
                                      : const Color(0xFFF0EBF8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(categoryIcon,
                                        style: const TextStyle(fontSize: 11)),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.task.category,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (widget.task.reminderTime != null)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AnimeColors.animeViolet
                                        .withAlpha(isDark ? 40 : 25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active_outlined,
                                    size: 14,
                                    color: AnimeColors.animeViolet,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Title
                          Text(
                            widget.task.title,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              decoration: widget.task.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AnimeColors.sakuraPink,
                              color: widget.task.isDone
                                  ? (isDark ? Colors.white38 : Colors.black38)
                                  : (isDark
                                      ? AnimeColors.textMainDark
                                      : AnimeColors.textMainLight),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          // Due Date with Anime Badges
                          Row(
                            children: [
                              Icon(
                                overdue
                                    ? Icons.warning_amber_rounded
                                    : Icons.schedule,
                                size: 13,
                                color: overdue
                                    ? AnimeColors.flameCrimson
                                    : (isDark
                                        ? AnimeColors.textSubDark
                                        : AnimeColors.textSubLight),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                overdue
                                    ? 'OVERDUE • ${DateHelper.formatDate(widget.task.dueDate)}'
                                    : DateHelper.formatDate(widget.task.dueDate),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: overdue
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: overdue
                                    ? AnimeColors.flameCrimson
                                    : (isDark
                                        ? AnimeColors.textSubDark
                                        : AnimeColors.textSubLight),
                              ),
                            ),
                          ],
                        ),

                        // Checkpoint Steps Indicator
                        if (widget.task.totalSubtasks > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: widget.task.subtaskProgress,
                                    minHeight: 4.5,
                                    backgroundColor: isDark
                                        ? Colors.white10
                                        : AnimeColors.sakuraPink.withAlpha(25),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      AnimeColors.sakuraPink,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.task.completedSubtasks}/${widget.task.totalSubtasks} steps',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AnimeColors.textSubDark
                                      : AnimeColors.textSubLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}