import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 1)
class ReminderModel extends HiveObject {
  @HiveField(0)
  String taskId; // rujuk balik ke TaskModel.id

  @HiveField(1)
  DateTime scheduledTime;

  @HiveField(2)
  bool isRepeating;

  @HiveField(3)
  String repeatType; // "None", "Daily", "Weekly"

  @HiveField(4)
  bool isActive; // untuk cancel/disable reminder tanpa delete

  ReminderModel({
    required this.taskId,
    required this.scheduledTime,
    this.isRepeating = false,
    this.repeatType = 'None',
    this.isActive = true,
  });
}