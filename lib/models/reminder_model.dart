import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 1)
class ReminderModel extends HiveObject {
  @HiveField(0)
  String taskId;

  @HiveField(1)
  DateTime scheduledTime;

  @HiveField(2)
  bool isRepeating;

  @HiveField(3)
  String repeatType;

  @HiveField(4)
  bool isActive;

  ReminderModel({
    required this.taskId,
    required this.scheduledTime,
    this.isRepeating = false,
    this.repeatType = 'None',
    this.isActive = true,
  });
}