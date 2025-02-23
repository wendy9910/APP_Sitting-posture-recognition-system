import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import '../database/task_db.dart';
import '../global.dart' as globals;
import 'package:fluttertoast/fluttertoast.dart';

class BluetoothConnectionProvider with ChangeNotifier {
  BluetoothConnection? _connection;
  String _buffer = '';
  String _receivedUpperBodyData = '';
  String _receivedLowerBodyData = '';

  String _dataType = '';

  // int? _currentTaskId; // 記錄當前的任務ID，用於資料庫更新
  // int? get currentTaskId => _currentTaskId; // 公開讀取器

  String get receivedUpperBodyData => _receivedUpperBodyData;
  String get receivedLowerBodyData => _receivedLowerBodyData;

  String _received_x1 = '';
  String _received_y1 = '';
  String _received_x2 = '';
  String _received_y2 = '';

  String get received_x1 => _received_x1;
  String get received_y1 => _received_y1;
  String get received_x2 => _received_x2;
  String get received_y2 => _received_y2;

  BluetoothConnection? get connection => _connection;

  // Database instance
  var dbInstance = TaskDB.instance;

  // 設置數據類型
  void setDataType(String type) {
    _dataType = type;
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _connection?.input!.listen(_onDataReceived).onDone(() {
        print('Disconnected by remote');
        disconnect();
      });
      notifyListeners();
      print('Connected to ${device.name}');
      await showAlert(device);
    } catch (e) {
      print('Error connecting to device: $e');
      _connection = null;
      notifyListeners();
    }
  }

  // 當數據到達時處理
  void _onDataReceived(Uint8List data) {
    _buffer += String.fromCharCodes(data);

    print("Current buffer: $_buffer");

    if (_dataType == '0') {
      print("IN");
      _processPoseData();
    } else if (_dataType == '2' || _dataType == '4') {
      print("IN");
      _processCoordinateData();
    }
  }

  void _processPoseData() async {
    while (true) {
      int start = _buffer.indexOf('/');
      int end = _buffer.indexOf('*');

      //當沒有完整的 `/` 和 `*`，直接退出等待更多數據
      if (start == -1 || end == -1 || end <= start) {
        return; // 等待更多數據
      }

      // 提取完整數據
      String dataChunk = _buffer.substring(start + 1, end);
      List<String> parts = dataChunk.split(',');

      // 確保數據格式正確
      if (parts.length == 2) {
        _receivedUpperBodyData = parts[0];
        _receivedLowerBodyData = parts[1];

        print('上半身: $_receivedUpperBodyData');
        print('下半身: $_receivedLowerBodyData');

        notifyListeners();

        // 儲存到資料庫
        await dbInstance.updatePostureStat(globals.currentTaskId!,
            _receivedUpperBodyData, _receivedLowerBodyData);
      } else {
        print("數據格式錯誤，丟棄！");
      }

      // **正確移除已處理的部分**
      _buffer = _buffer.substring(end + 1);

      // **如果 _buffer 變空，結束 while 迴圈**
      if (_buffer.isEmpty) break;
    }
  }

  void _processCoordinateData() {
    // 檢查緩衝區中是否有完整的數據集
    int start = _buffer.indexOf('/');
    int end = _buffer.indexOf('*');

    // 確保開始和結束標記都存在，且結束標記在開始標記之後
    while (start != -1 && end != -1 && end > start) {
      // 提取數據
      String dataChunk = _buffer.substring(start + 1, end);
      List<String> parts = dataChunk.split(',');

      if (parts.length == 4) {
        _received_x1 = parts[0];
        _received_y1 = parts[1];
        _received_x2 = parts[2];
        _received_y2 = parts[3];

        print(
            'Coordinates: ($_received_x1, $_received_y1), ($_received_x2, $_received_y2)');
        notifyListeners();
      }

      // 更新緩衝區，移除已處理的數據
      _buffer = _buffer.substring(end + 1);

      // 重新尋找下一組數據的標記
      start = _buffer.indexOf('/');
      end = _buffer.indexOf('*');
    }
  }

  Future<void> startNewTask() async {
    // String startTime = DateTime.now().toString();
    // globals.currentTaskId = await dbInstance.startNewTask(); // 開始新任務，並獲取新任務的ID
    notifyListeners(); // 通知聽眾更新
  }

  // 結束任務時，重置狀態
  Future<void> endTask() async {
    notifyListeners(); // 通知聽眾更新
  }

  Future<void> showAlert(BluetoothDevice device) async {
    if (globals.isDialogShowing) {
      return;
    }
    globals.isDialogShowing = true;

    Fluttertoast.showToast(
      msg: 'Connected to ${device.name}',
      toastLength: Toast.LENGTH_SHORT, // 可選：Toast.LENGTH_LONG
      gravity: ToastGravity.TOP, // 可調整為 CENTER 或 BOTTOM
      backgroundColor: const Color.fromARGB(255, 80, 145, 237), // 背景顏色
      textColor: Colors.white, // 文字顏色
      fontSize: 16.0, // 文字大小
      timeInSecForIosWeb: 1, // iOS/Web 運行時間
    );

    Future.delayed(Duration(seconds: 1), () {
      globals.isDialogShowing = false;
    });
  }

  void sendMessage(String message) {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(message.codeUnits));
    }
  }

  void disconnect() {
    _connection?.dispose();
    _connection = null;
    notifyListeners();
  }

  bool get isConnected => _connection?.isConnected ?? false;

  String getUpperBodyText() => _receivedUpperBodyData;
  String getLowerBodyText() => _receivedLowerBodyData;

  String getX1() => _received_x1;
  String getY1() => _received_y1;
  String getX2() => _received_x2;
  String getY2() => _received_y2;
}
