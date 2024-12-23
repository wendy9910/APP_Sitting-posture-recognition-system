import 'package:flutter/material.dart'; // Flutter的Material Design包
import 'package:provider/provider.dart'; // 狀態管理套件
import 'dart:async';
import '../global.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../bluetoothPage/BluetoothConnectionProvider.dart';
import '../database/task_db.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  Duration duration = Duration(); // 計時器初始時間為0
  Timer? timer;
  bool isRunning = false; // 計時器是否運行
  bool hasStarted = false; // 计时器是否开始过的标记

  PostureDetector detector = PostureDetector(); // 創建PostureDetector實例

  String backgroundImage = 'assets/images/background.jpg';
  List<String> upperbodyImage = [
    'assets/images/UPwB.png',
    'assets/images/UPwoB.png',
    'assets/images/LF.png',
    'assets/images/LR.png',
    'assets/images/RR.png',
    'assets/images/FRwB.png',
  ];
  List<String> lowerbodyImage = [
    'assets/images/LS.png',
    'assets/images/LKoRK.png',
    'assets/images/RKoLK.png'
  ];

  String upperBodyText = 'BackUpright';
  String lowerBodyText = 'FootStraight';

  // 总检测次数
  int totalDetect = 0;

  @override
  void initState() {
    super.initState();
    duration = Duration(minutes: globals.sittingTime.round());
  }

  void startTimer() async {
    final bluetoothProvider =
        Provider.of<BluetoothConnectionProvider>(context, listen: false);
    bluetoothProvider.startNewTask(); // 開始新任務

    // 記錄開始時間
    String startTime = DateTime.now().toIso8601String();
    int taskId = await TaskDB.instance.startNewTask(startTime);
    globals.currentTaskId = taskId; // 假設有一個全局變量來存儲當前任務ID

    if (duration.inSeconds > 0 && !isRunning) {
      setState(() {
        isRunning = true;
      });

      // 使用 Timer 每秒更新 UI
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        if (duration.inSeconds <= 0) {
          t.cancel();
          if (mounted) {
            setState(() {
              isRunning = false;
            });
          }
          _endTask();
        } else {
          if (mounted) {
            setState(() {
              duration -= Duration(seconds: 1);
            });
          }
        }

        final bluetoothProvider =
            Provider.of<BluetoothConnectionProvider>(context, listen: false);
        bluetoothProvider.sendMessage("0"); // Send start signal
        bluetoothProvider.setDataType("0");

        setState(() {
          // 从 BluetoothConnectionProvider 中获取数据并更新 UI
          upperBodyText = bluetoothProvider.getUpperBodyText();
          lowerBodyText = bluetoothProvider.getLowerBodyText();

          // 根據設定來處理偵測到的數據
          detector.receiveData(
              bluetoothProvider.getUpperBodyText(),
              bluetoothProvider.getLowerBodyText(),
              globals.isRealTime,
              context);
        });
      });
    }
  }

  void _endTask() async {
    await TaskDB.instance.endTask(globals.currentTaskId);
    await detector.saveData();

    detector.reset();
    final bluetoothProvider =
        Provider.of<BluetoothConnectionProvider>(context, listen: false);
    bluetoothProvider.sendMessage("1"); // Send start signal
    bluetoothProvider.setDataType("1");
    bluetoothProvider.endTask();

    globals.currentTaskId = 0;

    setState(() {
      isRunning = false;
    });
  }

  void pauseTimer() {
    setState(() {
      isRunning = false;
    });
    timer?.cancel();
    final bluetoothProvider =
        Provider.of<BluetoothConnectionProvider>(context, listen: false);
    bluetoothProvider.sendMessage("1"); // Send start signal
    bluetoothProvider.setDataType("1");
    bluetoothProvider.endTask();
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      duration = Duration(minutes: globals.sittingTime.round());
    });
    _endTask();
  }

  void toggleTimer() {
    if (isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    // final bluetoothProvider = Provider.of<BluetoothConnectionProvider>(context);

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 237, 244, 245),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 150),
            Text(
              'Your sitting posture is ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(221, 40, 39, 39), // 深色文字
              ),
            ),
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Image.asset(
                    'assets/images/sit2.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Image.asset(
                    'assets/images/add.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Image.asset(
                    'assets/images/sit1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(
                    upperBodyText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(146, 9, 9, 9),
                    ),
                  ),
                ),
                SizedBox(width: 50),
                Flexible(
                  flex: 2,
                  child: Text(
                    lowerBodyText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(146, 12, 12, 12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Text(formatDuration(duration),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                  iconSize: 36.0,
                  color: isRunning ? Colors.red : Colors.green,
                  onPressed: toggleTimer,
                ),
                IconButton(
                  icon: Icon(Icons.stop),
                  iconSize: 36.0,
                  color: isRunning ? Colors.grey : Colors.blue,
                  onPressed: isRunning ? null : resetTimer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum UpperBodyAction {
  BackRest,
  BackUpright,
  BackHunchedForward,
  BackSlouchingLeft,
  BackSlouchingRight,
  OnTheEdgeRest,
}

enum LowerBodyAction {
  FootStraight,
  FootCrossedLeft,
  FootCrossedRight,
}

// // PostureDetector 类负责处理姿势检测逻辑
class PostureDetector {
  Timer? errorTimer;
  bool isIncorrectPostureOngoing = false;
  int errorPostureCount = 0;
  // 计数器，记录各种姿势的检测次数
  final Map<UpperBodyAction, int> upperBodyCounters = {};
  final Map<LowerBodyAction, int> lowerBodyCounters = {};

  final int windowSize = 10; // 10秒滑動窗口
  List<bool> upperBodyHistory = [];
  List<bool> lowerBodyHistory = [];

  // 总检测次数
  int totalDetect = 0;

  PostureDetector() {
    // 初始化计数器
    UpperBodyAction.values.forEach((action) => upperBodyCounters[action] = 0);
    LowerBodyAction.values.forEach((action) => lowerBodyCounters[action] = 0);
  }

  // 更新姿势检测计数器
  void updateCounters(
      UpperBodyAction upperBodyAction, LowerBodyAction lowerBodyAction) {
    upperBodyCounters.update(upperBodyAction, (value) => value + 1,
        ifAbsent: () => 1);
    lowerBodyCounters.update(lowerBodyAction, (value) => value + 1,
        ifAbsent: () => 1);
    totalDetect++;
  }

  Map<String, dynamic> getStatistics() {
    return {
      'totalDetect': totalDetect,
      'upperBodyCounters': upperBodyCounters,
      'lowerBodyCounters': lowerBodyCounters,
    };
  }

  bool isUpperBodyPostureIncorrect(UpperBodyAction action) {
    // 定义上半身错误坐姿
    const incorrectPostures = {
      UpperBodyAction.BackHunchedForward,
      UpperBodyAction.BackSlouchingLeft,
      UpperBodyAction.BackSlouchingRight,
      UpperBodyAction.OnTheEdgeRest,
    };
    return incorrectPostures.contains(action);
  }

  bool isLowerBodyPostureIncorrect(LowerBodyAction action) {
    // 定义下半身错误坐姿
    const incorrectPostures = {
      LowerBodyAction.FootCrossedLeft,
      LowerBodyAction.FootCrossedRight,
    };
    return incorrectPostures.contains(action);
  }

  // 保存数据到 SharedPreferences
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().toIso8601String();

    final Map<String, dynamic> data = {
      'timestamp': timestamp,
      'upperBodyCounters':
          upperBodyCounters.map((k, v) => MapEntry(k.toString(), v)),
      'lowerBodyCounters':
          lowerBodyCounters.map((k, v) => MapEntry(k.toString(), v)),
    };

    final records = prefs.getStringList('postureRecords') ?? [];
    records.add(jsonEncode(data));
    await prefs.setStringList('postureRecords', records);
  }

  void updateSlidingWindow(bool upperIncorrect, bool lowerIncorrect) {
    upperBodyHistory.add(upperIncorrect);
    lowerBodyHistory.add(lowerIncorrect);

    // 保持窗口大小
    if (upperBodyHistory.length > windowSize) upperBodyHistory.removeAt(0);
    if (lowerBodyHistory.length > windowSize) lowerBodyHistory.removeAt(0);
  }

  bool shouldTriggerAlert() {
    int upperIncorrectCount = upperBodyHistory.where((e) => e).length;
    int lowerIncorrectCount = lowerBodyHistory.where((e) => e).length;

    double incorrectThreshold = 0.7; // 閾值為50%

    bool isUpperIncorrect =
        (upperIncorrectCount / windowSize) > incorrectThreshold;
    bool isLowerIncorrect =
        (lowerIncorrectCount / windowSize) > incorrectThreshold;

    return isUpperIncorrect || isLowerIncorrect;
  }

  Future<void> receiveData(String upperBodyText, String lowerBodyText,
      bool isRealTime, BuildContext context) async {
    try {
      UpperBodyAction upperAction = decodeUpperBodyAction(upperBodyText);
      LowerBodyAction lowerAction = decodeLowerBodyAction(lowerBodyText);
      updateCounters(upperAction, lowerAction);

      // 檢查姿勢是否不正確
      bool upperIncorrect = isUpperBodyPostureIncorrect(upperAction);
      bool lowerIncorrect = isLowerBodyPostureIncorrect(lowerAction);

      if (isRealTime) {
        if (upperIncorrect || lowerIncorrect && !globals.isDialogShowing) {
          await showAlert(context); // Wait for the user to close the dialog
        }
      } else {
        updateSlidingWindow(upperIncorrect, lowerIncorrect);
        if (shouldTriggerAlert() && !globals.isDialogShowing) {
          await showAlert(context);
        }
      }
    } catch (e) {
      print('Error processing data: $e');
    }
  }

  UpperBodyAction decodeUpperBodyAction(String code) {
    switch (code) {
      case 'BackRest':
        return UpperBodyAction.BackRest;
      case 'BackUpright':
        return UpperBodyAction.BackUpright;
      case 'BackHunchedForward':
        return UpperBodyAction.BackHunchedForward;
      case 'BackSlouchingLeft':
        return UpperBodyAction.BackSlouchingLeft;
      case 'BackSlouchingRight':
        return UpperBodyAction.BackSlouchingRight;
      case 'OnTheEdgeRest':
        return UpperBodyAction.OnTheEdgeRest;
      default:
        throw Exception('Invalid code for upper body action');
    }
  }

  LowerBodyAction decodeLowerBodyAction(String code) {
    switch (code) {
      case 'FootStraight':
        return LowerBodyAction.FootStraight;
      case 'FootCrossedLeft':
        return LowerBodyAction.FootCrossedLeft;
      case 'FootCrossedRight':
        return LowerBodyAction.FootCrossedRight;
      // Add other cases as needed
      default:
        throw Exception('Invalid code for lower body action');
    }
  }

  void resetErrorPosture() {
    errorPostureCount = 0;
    isIncorrectPostureOngoing = false;
    errorTimer?.cancel();
  }

  void showTopToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP, // 设置为顶部显示
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
      timeInSecForIosWeb: 1, // 设置提示框显示的时间（1秒）
    );
  }

  Future<void> showAlert(BuildContext context) async {
    if (globals.isDialogShowing) {
      return; // 如果已經有提示框在展示，則不再展示新的提示框
    }

    globals.isDialogShowing = true; // 設置標誌為真，表示提示框正在展示

    // 显示Toast消息
    showTopToast(
        'Incorrect Posture Detected. Please adjust your sitting position.');

    // 自动在1秒后重置对话框标志
    Future.delayed(Duration(seconds: 1), () {
      globals.isDialogShowing = false; // 重置提示框标志
    });
  }

  // Future<void> showAlert(BuildContext context) async {
  //   if (globals.isDialogShowing) {
  //     return; // 如果已經有對話框在展示，則不再展示新的對話框
  //   }
  //   globals.isDialogShowing = true; // 設置標誌為真，表示對話框正在展示

  //   await showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Incorrect Posture Detected'),
  //         content: Text(
  //             'Your posture is incorrect. Please adjust your sitting position.'),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // This will close the dialog
  //               globals.isDialogShowing = false; // 重置對話框顯示標誌
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // 重置计数器
  void reset() {
    upperBodyCounters.updateAll((key, value) => 0);
    lowerBodyCounters.updateAll((key, value) => 0);
    totalDetect = 0;
  }
}
