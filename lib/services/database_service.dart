import 'package:hive/hive.dart';
import '../models/task_model.dart';

class DatabaseService {
  static const String taskBoxName = 'tasks';

  // Panggil sekali je dalam main.dart lepas Hive.initFlutter()
  static Future<void> init() async {
    Hive.registerAdapter(TaskModelAdapter());
    await Hive.openBox<TaskModel>(taskBoxName);
  }

  Box<TaskModel> get _taskBox => Hive.box<TaskModel>(taskBoxName);

  // CREATE
  Future<void> addTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
  }

  // READ - semua task
  List<TaskModel> getAllTasks() {
    return _taskBox.values.toList();
  }

  // READ - satu task by id
  TaskModel? getTaskById(String id) {
    return _taskBox.get(id);
  }

  // READ - task ikut tarikh (untuk calendar view)
  List<TaskModel> getTasksByDate(DateTime date) {
    return _taskBox.values.where((task) {
      return task.dueDate.year == date.year &&
          task.dueDate.month == date.month &&
          task.dueDate.day == date.day;
    }).toList();
  }

  // UPDATE
  Future<void> updateTask(TaskModel task) async {
    await task.save(); // HiveObject punya method, auto save balik ke box
  }

  // Toggle checklist (mark done/undone)
  Future<void> toggleTaskStatus(String id) async {
    final task = getTaskById(id);
    if (task != null) {
      task.isDone = !task.isDone;
      await task.save();
    }
  }

  // DELETE
  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  // Stats helper - untuk tracking screen
  int getCompletedCount() => _taskBox.values.where((t) => t.isDone).length;
  int getPendingCount() => _taskBox.values.where((t) => !t.isDone).length;
  double getCompletionRate() {
    if (_taskBox.isEmpty) return 0.0;
    return getCompletedCount() / _taskBox.length;
  }
}