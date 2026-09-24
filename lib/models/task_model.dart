import 'dart:convert';
import 'package:hive/hive.dart';

part 'task_model.g.dart';

class SubTask {
  final String id;
  String title;
  bool isDone;

  SubTask({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isDone': isDone,
      };

  factory SubTask.fromMap(Map<String, dynamic> map) => SubTask(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        isDone: map['isDone'] as bool? ?? false,
      );

  SubTask copyWith({
    String? id,
    String? title,
    bool? isDone,
  }) =>
      SubTask(
        id: id ?? this.id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
      );
}

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  DateTime? reminderTime; // masa notification akan fire

  @HiveField(5)
  bool isDone;

  @HiveField(6)
  String priority; // "Low", "Medium", "High"

  @HiveField(7)
  String category; // contoh: "Study", "Work", "Personal"

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  String subtasksRaw;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.reminderTime,
    this.isDone = false,
    this.priority = 'Medium',
    this.category = 'General',
    DateTime? createdAt,
    List<SubTask>? subtasks,
    String? subtasksRaw,
  })  : createdAt = createdAt ?? DateTime.now(),
        subtasksRaw = subtasksRaw ??
            (subtasks != null
                ? jsonEncode(subtasks.map((e) => e.toMap()).toList())
                : '[]');

  List<SubTask> get subtasks {
    if (subtasksRaw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(subtasksRaw);
      return decoded
          .map((e) => SubTask.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  set subtasks(List<SubTask> list) {
    subtasksRaw = jsonEncode(list.map((e) => e.toMap()).toList());
  }

  int get totalSubtasks => subtasks.length;
  int get completedSubtasks => subtasks.where((s) => s.isDone).length;
  double get subtaskProgress =>
      totalSubtasks == 0 ? 0.0 : completedSubtasks / totalSubtasks;

  // Untuk toggle checklist / update sikit tanpa buat object baru penuh
  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? reminderTime,
    bool? isDone,
    String? priority,
    String? category,
    List<SubTask>? subtasks,
    String? subtasksRaw,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt,
      subtasks: subtasks,
      subtasksRaw: subtasksRaw ?? (subtasks != null ? null : this.subtasksRaw),
    );
  }
}