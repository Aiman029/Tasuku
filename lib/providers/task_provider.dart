import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  List<TaskModel> _tasks = [];
  String _filterStatus = 'All'; // "All", "Completed", "Pending"
  String _filterCategory = 'All';

  List<TaskModel> get tasks => _filteredTasks();
  List<TaskModel> get allTasks => _tasks;
  String get filterStatus => _filterStatus;
  String get filterCategory => _filterCategory;

  // Panggil sekali masa app start (contoh: initState di home_screen)
  void loadTasks() {
    _tasks = _dbService.getAllTasks();
    // Sort ikut dueDate terdekat dulu
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  List<TaskModel> _filteredTasks() {
    var result = _tasks;

    if (_filterStatus == 'Completed') {
      result = result.where((t) => t.isDone).toList();
    } else if (_filterStatus == 'Pending') {
      result = result.where((t) => !t.isDone).toList();
    }

    if (_filterCategory != 'All') {
      result = result.where((t) => t.category == _filterCategory).toList();
    }

    return result;
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  // CREATE
  Future<void> addTask({
    required String title,
    String description = '',
    required DateTime dueDate,
    DateTime? reminderTime,
    String priority = 'Medium',
    String category = 'General',
    List<SubTask>? subtasks,
  }) async {
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      reminderTime: reminderTime,
      priority: priority,
      category: category,
      subtasks: subtasks,
    );

    await _dbService.addTask(task);
    await _notificationService.scheduleReminder(task);

    _tasks.add(task);
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  // SUBTASKS / CHECKPOINTS
  Future<void> addSubTask(String taskId, String title) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final currentList = task.subtasks;
      currentList.add(SubTask(id: _uuid.v4(), title: title));
      task.subtasks = currentList;
      await _dbService.updateTask(task);
      notifyListeners();
    }
  }

  Future<void> toggleSubTask(String taskId, String subTaskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final currentList = task.subtasks;
      final subIndex = currentList.indexWhere((s) => s.id == subTaskId);
      if (subIndex != -1) {
        currentList[subIndex] = currentList[subIndex]
            .copyWith(isDone: !currentList[subIndex].isDone);
        task.subtasks = currentList;

        // If all subtasks are done, mark main task as done too!
        if (currentList.isNotEmpty && currentList.every((s) => s.isDone)) {
          task.isDone = true;
          await _notificationService.cancelReminder(taskId);
        }

        await _dbService.updateTask(task);
        notifyListeners();
      }
    }
  }

  Future<void> deleteSubTask(String taskId, String subTaskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final currentList = task.subtasks;
      currentList.removeWhere((s) => s.id == subTaskId);
      task.subtasks = currentList;
      await _dbService.updateTask(task);
      notifyListeners();
    }
  }

  // UPDATE
  Future<void> updateTask(TaskModel task) async {
    await _dbService.updateTask(task);

    // Reset reminder lama, schedule yang baru (kalau reminderTime berubah)
    await _notificationService.cancelReminder(task.id);
    await _notificationService.scheduleReminder(task);

    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
    notifyListeners();
  }

  // Toggle checklist
  Future<void> toggleTaskStatus(String id) async {
    await _dbService.toggleTaskStatus(id);

    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);

      // Kalau task siap, cancel reminder (tak perlu notify lagi)
      if (_tasks[index].isDone) {
        await _notificationService.cancelReminder(id);
      }
    }
    notifyListeners();
  }

  // DELETE
  Future<void> deleteTask(String id) async {
    await _dbService.deleteTask(id);
    await _notificationService.cancelReminder(id);

    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // Untuk calendar_screen — ambil task ikut tarikh dipilih
  List<TaskModel> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      return task.dueDate.year == date.year &&
          task.dueDate.month == date.month &&
          task.dueDate.day == date.day;
    }).toList();
  }

  // Untuk stats_screen — tracking progress
  int get completedCount => _tasks.where((t) => t.isDone).length;
  int get pendingCount => _tasks.where((t) => !t.isDone).length;
  double get completionRate =>
      _tasks.isEmpty ? 0.0 : completedCount / _tasks.length;
}