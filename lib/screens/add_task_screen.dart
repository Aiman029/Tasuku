import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/reminder_picker.dart';
import '../utils/date_helper.dart';
import '../theme/anime_theme.dart';
import '../widgets/sakura_particles.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _checkpointController = TextEditingController();
  final List<SubTask> _checkpoints = [];
  final Uuid _uuid = const Uuid();

  DateTime _dueDate = DateTime.now();
  DateTime? _reminderTime;
  String _priority = 'Medium';
  String _category = 'General';

  final List<Map<String, String>> _priorityOptions = [
    {'key': 'Low', 'label': 'B-Rank 🍃', 'sub': 'Low Urgency'},
    {'key': 'Medium', 'label': 'A-Rank ⚡', 'sub': 'Standard'},
    {'key': 'High', 'label': 'S-Rank 🔥', 'sub': 'Urgent Mission'},
  ];

  final List<Map<String, String>> _categories = [
    {'name': 'General', 'icon': '🌸', 'label': 'Life'},
    {'name': 'Study', 'icon': '📚', 'label': 'Academy'},
    {'name': 'Work', 'icon': '💼', 'label': 'Guild'},
    {'name': 'Personal', 'icon': '🍜', 'label': 'Chill'},
    {'name': 'Gaming', 'icon': '🎮', 'label': 'Gaming'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _checkpointController.dispose();
    super.dispose();
  }

  void _addCheckpoint() {
    final text = _checkpointController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _checkpoints.add(SubTask(id: _uuid.v4(), title: text));
      _checkpointController.clear();
    });
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
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
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<TaskProvider>().addTask(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          dueDate: _dueDate,
          reminderTime: _reminderTime,
          priority: _priority,
          category: _category,
          subtasks: _checkpoints,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AnimeColors.sakuraPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Row(
          children: [
            Text('✨', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text(
              'Quest summoned successfully! ⚔️',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'クエスト召喚',
              style: TextStyle(
                fontSize: 11,
                color: AnimeColors.sakuraPink,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Summon New Quest',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: AnimeColors.sakuraPink, size: 28),
            onPressed: _submit,
          ),
        ],
      ),
      body: SakuraPetalsOverlay(
        petalCount: 12,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              // Quest Title input card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AnimeColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AnimeColors.sakuraPink.withAlpha(isDark ? 60 : 40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('⚔️', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          'Quest Objective',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Master Dart async patterns...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        prefixIcon: const Icon(Icons.edit_note,
                            color: AnimeColors.sakuraPink),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Quest objective is required!'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                        hintText: 'Briefing / Description (optional)',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        prefixIcon: const Icon(Icons.notes,
                            color: AnimeColors.animeViolet),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quest Checkpoints / Sub-tasks Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AnimeColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AnimeColors.sakuraPink.withAlpha(isDark ? 60 : 40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        const Text(
                          'Quest Checkpoints / Sub-tasks',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        if (_checkpoints.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AnimeColors.sakuraPink.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_checkpoints.length} Steps',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AnimeColors.sakuraPink,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _checkpointController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Step 1: Research lore...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                            onFieldSubmitted: (_) => _addCheckpoint(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _addCheckpoint,
                          style: IconButton.styleFrom(
                            backgroundColor: AnimeColors.sakuraPink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                    if (_checkpoints.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._checkpoints.asMap().entries.map((entry) {
                        final i = entry.key;
                        final cp = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withAlpha(10)
                                : const Color(0xFFF7F4FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AnimeColors.sakuraPink.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AnimeColors.sakuraPink,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  cp.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                color: Colors.grey,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    _checkpoints.removeAt(i);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Priority / Rank Selection Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AnimeColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AnimeColors.sakuraPink.withAlpha(isDark ? 60 : 40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('🔥', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          'Quest Difficulty / Rank',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: _priorityOptions.map((opt) {
                        final isSelected = _priority == opt['key'];
                        final rankColor =
                            AnimeColors.getPriorityColor(opt['key']!);

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _priority = opt['key']!),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? rankColor.withAlpha(isDark ? 60 : 35)
                                    : (isDark
                                        ? Colors.white.withAlpha(10)
                                        : const Color(0xFFF7F4FA)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? rankColor
                                      : Colors.transparent,
                                  width: 1.8,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    opt['label']!,
                                    style: TextStyle(
                                      color: isSelected
                                          ? rankColor
                                          : (isDark
                                              ? Colors.white70
                                              : Colors.black87),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    opt['sub']!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Category Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AnimeColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AnimeColors.sakuraPink.withAlpha(isDark ? 60 : 40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('🏷️', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          'Quest Category',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _category == cat['name'];
                        return GestureDetector(
                          onTap: () => setState(() => _category = cat['name']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AnimeColors.sakuraGradient
                                  : null,
                              color: isSelected
                                  ? null
                                  : (isDark
                                      ? Colors.white10
                                      : const Color(0xFFF0EBF8)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDark ? Colors.white12 : Colors.black12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(cat['icon']!,
                                    style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Text(
                                  cat['label']!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Date & Reminder Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AnimeColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AnimeColors.sakuraPink.withAlpha(isDark ? 60 : 40),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AnimeColors.sakuraPink.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.event_available,
                            color: AnimeColors.sakuraPink, size: 22),
                      ),
                      title: const Text(
                        'Deadline / Due Date',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      subtitle: Text(
                        DateHelper.formatDate(_dueDate),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: TextButton(
                        onPressed: _pickDueDate,
                        child: const Text('Change Date'),
                      ),
                      onTap: _pickDueDate,
                    ),
                    const Divider(height: 1),
                    ReminderPicker(
                      selectedDateTime: _reminderTime,
                      onChanged: (val) => setState(() => _reminderTime = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Glowing Summon Quest Button
              Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: AnimeColors.sakuraGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AnimeColors.sakuraPink.withAlpha(100),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _submit,
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Summon Quest ✨',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}