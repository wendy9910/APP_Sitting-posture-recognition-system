import 'package:flutter/material.dart'; // Flutter的Material Design包
import 'package:provider/provider.dart'; // 狀態管理套件
import 'dart:async';
import '../global.dart' as globals;
import '../bluetoothPage/BluetoothConnectionProvider.dart';
import '../database/task_db.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart'; // 用於加載音效
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  Duration duration = Duration(); // 計時器初始時間
  Timer? timer;
  bool isRunning = false; // 計時器是否正在運行
  bool hasStarted = false; // 計時器是否已經開始過

  PostureDetector detector = PostureDetector();
  String backgroundImage = 'assets/images/background.jpg';

  String upperBodyText = 'BackUpright';
  String lowerBodyText = 'LegStraight';

  int ImageID_upper = 0;
  int ImageID_lower = 0;

  List<String> UpperImageLabel = [
    'assets/images/UPwoB.png',
    'assets/images/UPwB.png',
    'assets/images/LF.png',
    'assets/images/LR.png',
    'assets/images/RR.png',
    'assets/images/FRwB.png'
  ];
  List<String> LegImageLabel = [
    'assets/images/LS.png',
    'assets/images/LKoRK.png',
    'assets/images/RKoLK.png',
  ];

  int UpperSelectID(String label) {
    switch (label) {
      case 'BackUpright':
        return 0;
      case 'BackRest':
        return 1;
      case 'BackHunchedForward':
        return 2;
      case 'BackSlouchingLeft':
        return 3;
      case 'BackSlouchingRight':
        return 4;
      case 'OnTheEdgeRest':
        return 5;
      default:
        return 0;
    }
  }

  int LowerSelectID(String label) {
    switch (label) {
      case 'LegStraight':
        return 0;
      case 'LegCrossedLeft':
        return 1;
      case 'LegCrossedRight':
        return 2;
      // Add other cases as needed
      default:
        return 0;
    }
  }

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
    if (hasStarted != true) {
      //當為新的任務時，進入判斷式
      //若是暫停後重啟，則不新增任務
      String startTime = DateTime.now().toIso8601String();
      int taskId = await TaskDB.instance.startNewTask(startTime);
      globals.currentTaskId = taskId; // 假設有一個全局變量來存儲當前任務ID
    }
    hasStarted = true;

    if (duration.inSeconds > 0 && !isRunning) {
      setState(() {
        isRunning = true;
      });

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
          // 从 BluetoothConnectionProvider 獲取數據更新 UI
          upperBodyText = bluetoothProvider.getUpperBodyText();
          lowerBodyText = bluetoothProvider.getLowerBodyText();

          ImageID_upper = UpperSelectID(upperBodyText);
          ImageID_lower = LowerSelectID(lowerBodyText);

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

  //暫停
  void pauseTimer() {
    setState(() {
      isRunning = false;
      hasStarted = true;
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

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm to leave'),
            content: Text(
                'The detection has not been completed yet. Are you sure you want to leave?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 100),
            Text(
              'Your sitting posture is ',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'DengXian',
                color: Color.fromARGB(255, 30, 30, 30), // 深色文字
              ),
            ),
            SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 5,
                  child: Image.asset(
                    UpperImageLabel[ImageID_upper],
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
                  flex: 4,
                  child: Image.asset(
                    LegImageLabel[ImageID_lower],
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
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
  LegStraight,
  LegCrossedLeft,
  LegCrossedRight,
}

// // PostureDetector 負責姿勢檢測邏輯
class PostureDetector {
  Timer? errorTimer;
  bool isIncorrectPostureOngoing = false;
  int errorPostureCount = 0;

  late Soundpool _soundpool;
  int? _soundId; // 儲存音效的 ID

  //姿勢計數
  final Map<UpperBodyAction, int> upperBodyCounters = {};
  final Map<LowerBodyAction, int> lowerBodyCounters = {};

  final int windowSize = 10; // 10秒滑動窗口
  List<bool> upperBodyHistory = [];
  List<bool> lowerBodyHistory = [];

  PostureDetector() {
    _soundpool = Soundpool(); // 初始化 Soundpool
    _loadSound(); // 加載音效
    // 初始化計數器
    for (var action in UpperBodyAction.values) {
      upperBodyCounters[action] = 0;
    }
    for (var action in LowerBodyAction.values) {
      lowerBodyCounters[action] = 0;
    }
  }

  bool isUpperBodyPostureIncorrect(UpperBodyAction action) {
    const incorrectPostures = {
      UpperBodyAction.BackRest,
      UpperBodyAction.BackHunchedForward,
      UpperBodyAction.BackSlouchingLeft,
      UpperBodyAction.BackSlouchingRight,
      UpperBodyAction.OnTheEdgeRest,
    };
    return incorrectPostures.contains(action);
  }

  bool isLowerBodyPostureIncorrect(LowerBodyAction action) {
    const incorrectPostures = {
      LowerBodyAction.LegCrossedLeft,
      LowerBodyAction.LegCrossedRight,
    };
    return incorrectPostures.contains(action);
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
      // updateCounters(upperAction, lowerAction);

      // 檢查姿勢是否不正確
      bool upperIncorrect = isUpperBodyPostureIncorrect(upperAction);
      bool lowerIncorrect = isLowerBodyPostureIncorrect(lowerAction);

      //提示音效

      //若有不良坐姿跳出提醒
      if (isRealTime) {
        if (upperIncorrect || lowerIncorrect && !globals.isDialogShowing) {
          await showAlert(context); // Wait for the user to close the dialog
          //提醒音效
          _soundpool.play(_soundId!);
          // FlutterRingtonePlayer().playNotification();
        } else {
          _soundpool.stop(_soundId!);
          // FlutterRingtonePlayer().stop();
        }
      } else {
        updateSlidingWindow(upperIncorrect, lowerIncorrect);
        if (shouldTriggerAlert() && !globals.isDialogShowing) {
          _soundpool.play(_soundId!);
          await showAlert(context);
          // FlutterRingtonePlayer().playNotification();
        } else {
          _soundpool.stop(_soundId!);
          // FlutterRingtonePlayer().stop();
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
      case 'LegStraight':
        return LowerBodyAction.LegStraight;
      case 'LegCrossedLeft':
        return LowerBodyAction.LegCrossedLeft;
      case 'LegCrossedRight':
        return LowerBodyAction.LegCrossedRight;
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
      gravity: ToastGravity.TOP, // 設置頂部提醒時間
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
      timeInSecForIosWeb: 1, // 設置顯示提醒時間（1秒）
    );
  }

  Future<void> _loadSound() async {
    try {
      var asset = await rootBundle.load('assets/mp3/notification.mp3');
      _soundId = await _soundpool.load(asset); // 加載音效並儲存 ID
      print('Sound loaded with ID: $_soundId');
    } catch (e) {
      print('Failed to load sound: $e');
      _soundId = null; // 確保初始化失敗時不拋出錯誤
    }
  }

  Future<void> showAlert(BuildContext context) async {
    if (globals.isDialogShowing) {
      return; // 如果已經有提示框在展示，則不再展示新的提示框
    }
    globals.isDialogShowing = true; // 設置標誌為真，表示提示框正在展示

    // 顯示提醒
    showTopToast(
        'Incorrect Posture Detected. Please adjust your sitting position.');
    // 自動在一秒後重置
    Future.delayed(Duration(seconds: 1), () {
      globals.isDialogShowing = false;
    });
  }
}
