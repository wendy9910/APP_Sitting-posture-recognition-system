// task.dart

import 'dart:convert';

class Task {
  final int taskId;
  final String startTime;
  final String? endTime; // 可能為null，表示任務還在進行中
  final int totalReceptions;
  List<TaskStat>? stats;

  Task(
      {required this.taskId,
      required this.startTime,
      this.endTime,
      required this.totalReceptions,
      this.stats});

  factory Task.fromMap(Map<String, dynamic> map,
      [List<Map<String, dynamic>>? statsMaps]) {
    var stats = statsMaps?.map((e) => TaskStat.fromMap(e)).toList();
    return Task(
      taskId: map['task_id'] as int,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String?,
      totalReceptions: map['total_receptions'] as int? ?? 0,
      stats: stats,
    );
  }
}

class TaskStat {
  String postureType;
  int count;

  TaskStat({required this.postureType, required this.count});

  factory TaskStat.fromMap(Map<String, dynamic> map) {
    return TaskStat(
      postureType: map['posture_type'] as String,
      count: map['count'] as int,
    );
  }
}