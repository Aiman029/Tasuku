import 'package:hive/hive.dart';
import '../models/task_model.dart';

class DatabaseService {
  static const String taskBoxName = 'tasks';

  static Future<void> init() async {
    Hive.registerAdapter(TaskModelAdapter());
    await Hive.openBox<TaskModel>(taskBoxName);
  }

  Box<TaskModel> get _taskBox => Hive.box<TaskModel>(taskBoxName);

  Future<void> addTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
  }

  List<TaskModel> getAllTasks() {
    return _taskBox.values.toList();
  }

  TaskModel? getTaskById(String id) {
    return _taskBox.get(id);
  }

  List<TaskModel> getTasksByDate(DateTime date) {
    return _taskBox.values.where((task) {
      return task.dueDate.year == date.year &&
          task.dueDate.month == date.month &&
          task.dueDate.day == date.day;
    }).toList();
  }

  Future<void> updateTask(TaskModel task) async {
    await task.save();
  }

  Future<void> toggleTaskStatus(String id) async {
    final task = getTaskById(id);
    if (task != null) {
      task.isDone = !task.isDone;
      await task.save();
    }
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  int getCompletedCount() => _taskBox.values.where((t) => t.isDone).length;
  int getPendingCount() => _taskBox.values.where((t) => !t.isDone).length;
  double getCompletionRate() {
    if (_taskBox.isEmpty) return 0.0;
    return getCompletedCount() / _taskBox.length;
  }
}