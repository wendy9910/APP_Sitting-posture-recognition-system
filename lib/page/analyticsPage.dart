import 'package:flutter/material.dart';
import '../database/task_db.dart';
import '../database/task.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<Task> tasks = [];
  List<Duration?> taskDurations = []; // 任務持續時間
  late Task selectedTask; // 當前選中的任務
  String displayType = 'upper'; // 切換顯示變量 Upper or Leg
  List<bool> isSelected = [true, false]; // 管理兩個按鈕狀態 Upper or Leg

  final Map<String, Color> colorMap = {
    "BackUpright": Colors.green,
    "BackRest": Colors.orange,
    "BackHunchedForward": Colors.blue,
    "BackSlouchingLeft": const Color.fromARGB(255, 244, 140, 204),
    "BackSlouchingRight": Colors.purple,
    "OnTheEdgeRest": const Color.fromARGB(255, 197, 23, 18),
    "LegStraight": Colors.green,
    "LegCrossedLeft": Colors.orange,
    "LegCrossedRight": const Color.fromARGB(255, 197, 23, 18),
  };

  final upperBodyLabels = [
    "BackUpright",
    "BackRest",
    "BackHunchedForward",
    "BackSlouchingLeft",
    "BackSlouchingRight",
    "OnTheEdgeRest"
  ];
  final feetLabels = ["LegStraight", "LegCrossedLeft", "LegCrossedRight"];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    List<Task> tasksData = await TaskDB.instance.getTasks(); // 加载所有任务
    List<Duration?> durations = List<Duration?>.filled(
        tasksData.length, null); // 初始化 taskDurations 的長度和初始值

    for (int i = 0; i < tasksData.length; i++) {
      Task task = tasksData[i];
      Duration? duration = await TaskDB.instance.getTaskDuration(task.taskId);
      durations[i] = duration; // 將計算的持續時間放入對應位置
      print(
          'Task ID: ${task.taskId}, Start Time: ${task.startTime}, Duration: ${duration?.inMinutes}');
    }

    if (tasksData.isNotEmpty) {
      List<MapEntry<Task, Duration?>> combined =
          tasksData.asMap().entries.map((entry) {
        int idx = entry.key;
        return MapEntry(entry.value, durations[idx]);
      }).toList();

      combined
          .sort((a, b) => b.key.startTime.compareTo(a.key.startTime)); // 按時間排序

      // 分開 tasks 和 durations
      tasksData = combined.map((e) => e.key).toList();
      durations = combined.map((e) => e.value).toList();

      setState(() {
        tasks = tasksData;
        taskDurations = durations; // 確保持續時間與任務列表一致
        selectedTask = tasks.first; // 設置最新的任務為選中的任務

        // 調試輸出：檢查初始化後的 tasks 和 taskDurations
        print(selectedTask.taskId);
        print('Tasks loaded: ${tasks.length}');
        print('Task Durations: ${taskDurations.length}');
      });
    } else {
      setState(() {
        tasks = [];
        taskDurations = [];
      });
    }
  }

  Future<void> _deleteTask() async {
    bool confirm = await _showConfirmDialog();
    if (confirm) {
      await TaskDB.instance.deleteTask(selectedTask.taskId); // 刪除任務
      await loadTasks(); // 重新加載任務
    }
  }

  // 顯示確認對話框
  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Deletion Confirmation"),
              content: Text(
                  "Are you sure you want to delete this task? This action cannot be undone."),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text("Confirm"),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false; // 防止 null 返回
  }

  // 格式化 Duration 為 HH:mm:ss
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(1, '0'); // 保證每個數字都顯示至少一位
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BG3.jpg'),
            fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(120, 240, 240, 240),
              Color.fromARGB(180, 116, 116, 116),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: tasks.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 40),
                  DropdownButton<Task>(
                    value: selectedTask,
                    onChanged: (Task? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedTask = newValue;
                          //loadPostureData();
                        });
                      }
                    },
                    items: tasks.map<DropdownMenuItem<Task>>((Task task) {
                      //下拉式選單
                      return DropdownMenuItem<Task>(
                        value: task,
                        child: Text(task.startTime),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  ToggleButtons(
                    //切換button
                    isSelected: isSelected,
                    onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0;
                            buttonIndex < isSelected.length;
                            buttonIndex++) {
                          isSelected[buttonIndex] = buttonIndex == index;
                        }
                        displayType = index == 0 ? 'upper' : 'leg';
                      });
                    },
                    color: Colors.black,
                    selectedColor: Colors.white,
                    fillColor: const Color.fromARGB(255, 163, 185, 195),
                    borderRadius: BorderRadius.zero,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Upper body posture'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Leg posture'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ...[
                    Text(
                      //計算總時長
                      ' ${taskDurations.isNotEmpty && tasks.contains(selectedTask) && taskDurations[tasks.indexOf(selectedTask)] != null ? formatDuration(taskDurations[tasks.indexOf(selectedTask)]!) : 'Not finished'}',
                      style: TextStyle(fontSize: 20),
                    ),
                    // 顯示總體時間
                    SizedBox(height: 10),
                  ],
                  SizedBox(height: 20),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: _createSampleData(),
                        centerSpaceRadius: 60,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  _buildLegend(),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        tooltip: "刪除此任務",
                        onPressed: _deleteTask,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
      ),
    );
  }

  Widget _buildLegend() {
    final labels = displayType == 'upper' ? upperBodyLabels : feetLabels;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(labels.length, (index) {
        final label = labels[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorMap[label] ?? Colors.grey, // 根據標籤顯示顏色，默認為灰色
                ),
              ),
              SizedBox(width: 5),
              Text(label), // 顯示固定標籤名稱
            ],
          ),
        );
      }),
    );
  }

  //圓餅圖顯示
  List<PieChartSectionData> _createSampleData() {
    var filteredStats = selectedTask.stats
        ?.where((stat) {
          if (displayType == 'upper') {
            return upperBodyLabels.contains(stat.postureType);
          } else {
            return feetLabels.contains(stat.postureType);
          }
        })
        .toSet()
        .toList();
    return List.generate(
      filteredStats?.length ?? 0,
      (index) {
        final currentStat = filteredStats![index];
        final color =
            colorMap[currentStat.postureType] ?? Colors.grey; // 若無對應顏色，使用灰色
        return PieChartSectionData(
          color: color,
          value: double.parse(currentStat.count.toString()),
          radius: 50,
          title: "",
        );
      },
    );
  }
}
