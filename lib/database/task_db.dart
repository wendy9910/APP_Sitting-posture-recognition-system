import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'task.dart';

class TaskDB {
  static final TaskDB _instance = TaskDB._internal();
  static Database? _database;

  TaskDB._internal();

  // 提供一個方式來訪問類的實例
  static TaskDB get instance => _instance;

  // 獲取數據庫實例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  // 初始化資料庫
  Future<Database> initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'posture_db.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Tasks(
            task_id INTEGER PRIMARY KEY AUTOINCREMENT,
            start_time TEXT,
            end_time TEXT,
            total_receptions INTEGER
          );
        ''');
        await db.execute('''
          CREATE TABLE PostureStats(
            stat_id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id INTEGER,
            posture_type TEXT,
            count INTEGER,
            FOREIGN KEY (task_id) REFERENCES Tasks (task_id)
          );
        ''');
      },
      version: 1,
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> tasksMaps = await db.query('Tasks');
    List<Task> tasks = [];

    for (var taskMap in tasksMaps) {
      List<Map<String, dynamic>> statsMaps = await db.query('PostureStats',
          where: 'task_id = ?', whereArgs: [taskMap['task_id']]);

      // 可以考虑在 Task 的构造函数中直接处理 stats
      tasks.add(Task.fromMap(taskMap, statsMaps));
    }

    return tasks;
  }

  Future<Task> getLastTask() async {
    final db = await database;
    final List<Map<String, dynamic>> tasksMaps = await db.query(
      'Tasks',
      orderBy:
          'task_id DESC', // Ensure this is the correct column name for ordering
    );

    if (tasksMaps.isNotEmpty) {
      // Assuming the `task_id` is properly retrieved and your schema matches the query
      List<Map<String, dynamic>> statsMaps = await db.query('PostureStats',
          where: 'task_id = ?', whereArgs: [tasksMaps.first['task_id']]);

      // Create a Task object with stats included
      return Task.fromMap(tasksMaps.first, statsMaps);
    } else {
      throw Exception('No tasks found');
    }
  }

  // 根據任務ID獲取坐姿統計
  Future<List<Map<String, dynamic>>> getPostureStats(int taskId) async {
    final db = await database;
    return await db
        .query('PostureStats', where: 'task_id = ?', whereArgs: [taskId]);
  }

  Future<int> startNewTask(String startTime) async {
    final db = await database;
    int taskId = await db.insert('Tasks', {
      'start_time': startTime, // 記錄開始時間
      'end_time': null, // 初始為null，表示任務尚未結束
      'total_receptions': 0, // 初始化接收次數
    });
    print("Inserted new task with ID: $taskId and start time: $startTime");
    return taskId;
  }

  Future<void> endTask(int taskId) async {
    final db = await database;
    String endTime = DateTime.now().toIso8601String();
    await db.update(
      'Tasks',
      {'end_time': endTime}, // 更新結束時間
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
    print("Task ID: $taskId ended at $endTime");
  }

  Future<Duration?> getTaskDuration(int taskId) async {
    final db = await database;
    List<Map> results = await db.query('Tasks',
        columns: ['start_time', 'end_time'],
        where: 'task_id = ?',
        whereArgs: [taskId]);

    if (results.isNotEmpty && results.first['end_time'] != null) {
      DateTime startTime = DateTime.parse(results.first['start_time']);
      DateTime endTime = DateTime.parse(results.first['end_time']);

      Duration duration = endTime.difference(startTime);
      print(
          "Duration: ${duration.inHours}:${duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60)}");

      return duration;
    }
    return null;
  }

  // 更新坐姿統計數據
  Future<void> updatePostureStat(
      int taskId, String upperBody, String lowerBody) async {
    final db = await database;

    // 先更新上半身的統計
    await _updateSingleStat(db, taskId, upperBody);

    // 再更新下半身的統計
    await _updateSingleStat(db, taskId, lowerBody);
  }

  // 更新單個坐姿統計數據
  Future<void> _updateSingleStat(
      Database db, int taskId, String postureType) async {
    List<Map> result = await db.query('PostureStats',
        columns: ['count'],
        where: 'task_id = ? AND posture_type = ?',
        whereArgs: [taskId, postureType]);

    if (result.isEmpty) {
      await db.insert('PostureStats',
          {'task_id': taskId, 'posture_type': postureType, 'count': 1});
    } else {
      int currentCount = result.first['count'] as int;
      await db.update('PostureStats', {'count': currentCount + 1},
          where: 'task_id = ? AND posture_type = ?',
          whereArgs: [taskId, postureType]);
    }
  }

  // 刪除指定 task_id 的任務及相關姿勢統計數據
  Future<void> deleteTask(int taskId) async {
    final db = await database;

    // 先刪除 PostureStats 表中與該 task_id 相關的數據
    await db.delete(
      'PostureStats',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );

    // 再刪除 Tasks 表中指定的任務
    await db.delete(
      'Tasks',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );

    print("Deleted task with ID: $taskId and related PostureStats.");
  }
}
