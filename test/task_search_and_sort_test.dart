import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_schedule_planner/models/task_model.dart';
import 'package:todo_schedule_planner/providers/task_provider.dart';
import 'package:todo_schedule_planner/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late Box<TaskModel> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tasuku_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
    box = await Hive.openBox<TaskModel>(DatabaseService.taskBoxName);
  });

  tearDown(() async {
    await box.close();
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('TaskProvider search by keyword filters matching titles and notes', () async {
    final provider = TaskProvider();

    final task1 = TaskModel(
      id: '1',
      title: 'Defeat Dragon in Dungeon',
      description: 'Bring ice sword',
      dueDate: DateTime(2026, 10, 1),
      priority: 'High',
    );
    final task2 = TaskModel(
      id: '2',
      title: 'Gather herbs in forest',
      description: 'Look for glowing mushrooms',
      dueDate: DateTime(2026, 10, 2),
      priority: 'Low',
    );

    await box.put('1', task1);
    await box.put('2', task2);
    provider.loadTasks();

    expect(provider.tasks.length, 2);

    // Search by title keyword
    provider.setSearchQuery('dragon');
    expect(provider.tasks.length, 1);
    expect(provider.tasks.first.title, 'Defeat Dragon in Dungeon');

    // Search by description keyword
    provider.setSearchQuery('mushrooms');
    expect(provider.tasks.length, 1);
    expect(provider.tasks.first.title, 'Gather herbs in forest');

    // Reset search
    provider.setSearchQuery('');
    expect(provider.tasks.length, 2);
  });

  test('TaskProvider filter by priority / rank works accurately', () async {
    final provider = TaskProvider();

    final task1 = TaskModel(
      id: '1',
      title: 'S-Rank Raid',
      dueDate: DateTime(2026, 10, 1),
      priority: 'High',
    );
    final task2 = TaskModel(
      id: '2',
      title: 'B-Rank Patrol',
      dueDate: DateTime(2026, 10, 2),
      priority: 'Low',
    );

    await box.put('1', task1);
    await box.put('2', task2);
    provider.loadTasks();

    provider.setFilterPriority('High');
    expect(provider.tasks.length, 1);
    expect(provider.tasks.first.title, 'S-Rank Raid');

    provider.setFilterPriority('Low');
    expect(provider.tasks.length, 1);
    expect(provider.tasks.first.title, 'B-Rank Patrol');

    provider.setFilterPriority('All');
    expect(provider.tasks.length, 2);
  });

  test('TaskProvider sorts by priority and due date with direction toggle', () async {
    final provider = TaskProvider();

    final task1 = TaskModel(
      id: '1',
      title: 'Beta Quest',
      dueDate: DateTime(2026, 10, 5),
      priority: 'Low',
    );
    final task2 = TaskModel(
      id: '2',
      title: 'Alpha Quest',
      dueDate: DateTime(2026, 10, 1),
      priority: 'High',
    );

    await box.put('1', task1);
    await box.put('2', task2);
    provider.loadTasks();

    // Default: DueDate ascending (earliest first)
    expect(provider.tasks.first.title, 'Alpha Quest');

    // Toggle direction: Furthest due date first
    provider.toggleSortDirection();
    expect(provider.tasks.first.title, 'Beta Quest');

    // Sort by Title A-Z
    provider.setSortOption(TaskSortOption.title);
    expect(provider.tasks.first.title, 'Alpha Quest');

    // Toggle direction: Z-A
    provider.toggleSortDirection();
    expect(provider.tasks.first.title, 'Beta Quest');

    // Sort by Priority: S-Rank (High) first
    provider.setSortOption(TaskSortOption.priority);
    expect(provider.tasks.first.title, 'Alpha Quest');

    // Clear filters and reset
    provider.clearSearchAndFilters();
    expect(provider.hasActiveSearchOrFilter, false);
    expect(provider.sortBy, TaskSortOption.dueDate);
    expect(provider.sortAscending, true);
  });
}
