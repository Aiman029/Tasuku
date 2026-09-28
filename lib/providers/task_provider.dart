import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

enum TaskSortOption {
  dueDate,
  priority,
  title,
  createdAt,
}

class TaskProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  List<TaskModel> _tasks = [];
  String _filterStatus = 'All'; // "All", "Completed", "Pending"
  String _filterCategory = 'All';
  String _searchQuery = '';
  String _filterPriority = 'All'; // "All", "High", "Medium", "Low"
  TaskSortOption _sortBy = TaskSortOption.dueDate;
  bool _sortAscending = true;

  List<TaskModel> get tasks => _filteredTasks();
  List<TaskModel> get allTasks => _tasks;
  String get filterStatus => _filterStatus;
  String get filterCategory => _filterCategory;
  String get searchQuery => _searchQuery;
  String get filterPriority => _filterPriority;
  TaskSortOption get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  bool get hasActiveSearchOrFilter =>
      _searchQuery.trim().isNotEmpty ||
      _filterPriority != 'All' ||
      _filterStatus != 'All' ||
      _filterCategory != 'All' ||
      _sortBy != TaskSortOption.dueDate ||
      !_sortAscending;

  // Panggil sekali masa app start (contoh: initState di home_screen)
  void loadTasks() {
    _tasks = _dbService.getAllTasks();
    // Sort ikut dueDate terdekat dulu
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  List<TaskModel> _filteredTasks() {
    var result = List<TaskModel>.from(_tasks);

    // 1. Status Filter
    if (_filterStatus == 'Completed') {
      result = result.where((t) => t.isDone).toList();
    } else if (_filterStatus == 'Pending') {
      result = result.where((t) => !t.isDone).toList();
    }

    // 2. Category Filter
    if (_filterCategory != 'All') {
      result = result.where((t) => t.category == _filterCategory).toList();
    }

    // 3. Priority / Rank Filter
    if (_filterPriority != 'All') {
      result = result.where((t) =>
          t.priority.toLowerCase() == _filterPriority.toLowerCase()).toList();
    }

    // 4. Keyword Search Filter (Title, description, category, subtask items)
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((t) {
        final titleMatch = t.title.toLowerCase().contains(q);
        final descMatch = t.description.toLowerCase().contains(q);
        final catMatch = t.category.toLowerCase().contains(q);
        final subtaskMatch =
            t.subtasks.any((s) => s.title.toLowerCase().contains(q));
        return titleMatch || descMatch || catMatch || subtaskMatch;
      }).toList();
    }

    // 5. Sorting
    result.sort((a, b) {
      int cmp = 0;
      switch (_sortBy) {
        case TaskSortOption.dueDate:
          cmp = a.dueDate.compareTo(b.dueDate);
          break;
        case TaskSortOption.priority:
          int weight(String p) {
            switch (p.toLowerCase()) {
              case 'high':
              case 's':
              case 's-rank':
                return 3;
              case 'medium':
              case 'a':
              case 'a-rank':
                return 2;
              case 'low':
              case 'b':
              case 'b-rank':
                return 1;
              default:
                return 0;
            }
          }
          // Default ascending for priority means S-Rank (Highest) first
          cmp = weight(b.priority).compareTo(weight(a.priority));
          break;
        case TaskSortOption.title:
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case TaskSortOption.createdAt:
          // Default ascending for created at means newest first
          cmp = b.createdAt.compareTo(a.createdAt);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

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

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterPriority(String priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  void setSortOption(TaskSortOption option) {
    if (_sortBy == option) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = option;
      _sortAscending = true;
    }
    notifyListeners();
  }

  void toggleSortDirection() {
    _sortAscending = !_sortAscending;
    notifyListeners();
  }

  void clearSearchAndFilters() {
    _searchQuery = '';
    _filterPriority = 'All';
    _filterCategory = 'All';
    _filterStatus = 'All';
    _sortBy = TaskSortOption.dueDate;
    _sortAscending = true;
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