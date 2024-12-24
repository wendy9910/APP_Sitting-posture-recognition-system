import 'package:flutter/material.dart';
import '../database/task_db.dart';
import '../database/task.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<Task> tasks = []; // 儲存從數據庫讀取的任務列表
  List<Duration?> taskDurations = []; // 存储每个任务的持续时间
  late Task selectedTask; // 當前選中的任務
  String displayType = 'upper'; // 新增一个状态变量，用于跟踪当前应该显示哪种数据
  List<bool> isSelected = [true, false]; // 管理两个按钮的状态

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    const Color.fromARGB(255, 244, 140, 204),
  ];

  final upperBodyLabels = [
    "BackRest",
    "BackUpright",
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
      // tasksData.sort((a, b) => b.startTime.compareTo(a.startTime)); // 按时间排序
      List<MapEntry<Task, Duration?>> combined =
          tasksData.asMap().entries.map((entry) {
        int idx = entry.key;
        return MapEntry(entry.value, durations[idx]);
      }).toList();

      combined
          .sort((a, b) => b.key.startTime.compareTo(a.key.startTime)); // 按时间排序

      // 分開 tasks 和 durations
      tasksData = combined.map((e) => e.key).toList();
      durations = combined.map((e) => e.value).toList();

      setState(() {
        tasks = tasksData;
        taskDurations = durations; // 確保持續時間與任務列表一致
        selectedTask = tasks.first; // 設置最新的任務為選中的任務
        loadPostureData(); // 加载最新任务的数据

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
    if (selectedTask == null) return;

    // 顯示確認對話框
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

  // 根據選擇的任務ID加載坐姿數據
  Future<void> loadPostureData() async {
    // 使用選擇的任務ID從數據庫中獲取坐姿統計數據
    var postureData =
        await TaskDB.instance.getPostureStats(selectedTask.taskId);
    // 進一步處理或顯示數據
    // 這裡可以將 postureData 轉換為圓餅圖需要的數據格式，然後更新UI
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
      // backgroundColor: const Color.fromARGB(150, 237, 244, 245),
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
                          loadPostureData();
                        });
                      }
                    },
                    items: tasks.map<DropdownMenuItem<Task>>((Task task) {
                      return DropdownMenuItem<Task>(
                        value: task,
                        child: Text(task.startTime),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  ToggleButtons(
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
                  ),
                  SizedBox(height: 20),
                  if (selectedTask != null) ...[
                    Text(
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
                      swapAnimationDuration: Duration(milliseconds: 150),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(filteredStats?.length ?? 0, (index) {
        final originalLabel = filteredStats![index].postureType;

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
                  color: colors[index % colors.length],
                ),
              ),
              SizedBox(width: 5),
              Text(originalLabel), // 使用映射后的標籤
            ],
          ),
        );
      }),
    );
  }

  //圓餅圖顯示
  List<PieChartSectionData> _createSampleData() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      const Color.fromARGB(255, 244, 140, 204),
    ];

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

        return PieChartSectionData(
          color: colors[index % colors.length],
          value: double.parse(currentStat.count.toString()),
          radius: 50,
          title: "",
        );
      },
    );
  }
}
