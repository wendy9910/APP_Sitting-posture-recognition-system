import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import '../database/task_db.dart';
import '../global.dart' as globals;

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
    } catch (e) {
      print('Error connecting to device: $e');
      _connection = null;
      notifyListeners();
    }
  }

  // 當數據到達時處理
  void _onDataReceived(Uint8List data) {
    _buffer += String.fromCharCodes(data);

    // print("Current buffer: $_buffer");

    if (_dataType == '0') {
      _processPoseData();
    } else if (_dataType == '2' || _dataType == '4') {
      print("IN");
      _processCoordinateData();
    }
  }

  // 處理坐姿數據
  // void _processPoseData() async {
  //   int separatorIndex = _buffer.indexOf('_');
  //   while (separatorIndex != -1) {
  //     String upperBodyData = _buffer.substring(0, separatorIndex);
  //     int nextSeparatorIndex = _buffer.indexOf('_', separatorIndex + 1);

  //     if (nextSeparatorIndex != -1) {
  //       String lowerBodyData =
  //           _buffer.substring(separatorIndex + 1, nextSeparatorIndex);

  //       _receivedUpperBodyData = upperBodyData;
  //       _receivedLowerBodyData = lowerBodyData;
  //       print('上半身資料: $_receivedUpperBodyData');
  //       print('下半身資料: $_receivedLowerBodyData');

  //       // 儲存到資料庫
  //       if (globals.currentTaskId != null) {
  //         await dbInstance.updatePostureStat(
  //             globals.currentTaskId!, upperBodyData, lowerBodyData);
  //       }

  //       notifyListeners();
  //       _buffer = _buffer.substring(nextSeparatorIndex + 1);
  //     } else {
  //       break;
  //     }
  //     separatorIndex = _buffer.indexOf('_');
  //   }
  // }

  void _processPoseData() async {
    // 檢查緩衝區中是否有完整的數據集
    int start = _buffer.indexOf('/');
    int end = _buffer.indexOf('*');

    // 確保開始和結束標記都存在，且結束標記在開始標記之後
    while (start != -1 && end != -1 && end > start) {
      // 提取數據
      String dataChunk = _buffer.substring(start + 1, end);
      List<String> parts = dataChunk.split(',');

      if (parts.length == 2) {
        _receivedUpperBodyData = parts[0];
        _receivedLowerBodyData = parts[1];

        print('上半身資料: $_receivedUpperBodyData');
        print('下半身資料: $_receivedLowerBodyData');

        notifyListeners();
      }

      // 儲存到資料庫
      if (globals.currentTaskId != null) {
        await dbInstance.updatePostureStat(globals.currentTaskId!,
            _receivedUpperBodyData, _receivedLowerBodyData);
      }

      // 更新緩衝區，移除已處理的數據
      // _buffer = _buffer.substring(end + 1);

      if (end + 1 < _buffer.length) {
        _buffer = _buffer.substring(end + 1);
      } else {
        _buffer = ""; // 如果字符串末尾已達到，重置緩衝區
      }

      // 重新尋找下一組數據的標記
      start = _buffer.indexOf('/');
      end = _buffer.indexOf('*');
    }
  }

  // void _processPoseData() {
  //   // 檢查緩衝區中是否有完整的數據集
  //   int start = _buffer.indexOf('/');
  //   int end = _buffer.indexOf('*');

  //   // 確保開始和結束標記都存在，且結束標記在開始標記之後
  //   while (start != -1 && end != -1 && end > start) {
  //     // 提取數據
  //     String dataChunk = _buffer.substring(start + 1, end);
  //     List<String> parts = dataChunk.split(',');

  //     if (parts.length == 2) {
  //       _receivedUpperBodyData = parts[0].trim();
  //       _receivedLowerBodyData = parts[1].trim();

  //       print(
  //           'Upper Body Action: $_receivedUpperBodyData, Lower Body Action: $_receivedLowerBodyData');
  //       notifyListeners();
  //     }

  //     // 更新緩衝區，移除已處理的數據
  //     _buffer = _buffer.substring(end + 1);

  //     // 重新尋找下一組數據的標記
  //     start = _buffer.indexOf('/');
  //     end = _buffer.indexOf('*');
  //   }
  // }

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

  // 開始新任務時，創建新任務紀錄
  // Future<void> startNewTask() async {
  //   String startTime = DateTime.now().toString();
  //   notifyListeners(); // 通知聽眾更新
  // }

  Future<void> startNewTask() async {
    String startTime = DateTime.now().toString();
    // globals.currentTaskId = await dbInstance.startNewTask(); // 開始新任務，並獲取新任務的ID
    notifyListeners(); // 通知聽眾更新
  }

  // 結束任務時，重置狀態
  Future<void> endTask() async {
    notifyListeners(); // 通知聽眾更新
  }

  // Future<void> endTask() async {
  //   if (_currentTaskId != null) {
  //     await TaskDB.instance
  //         .endTask(_currentTaskId!, DateTime.now().toIso8601String());
  //     _currentTaskId = null; // 重置當前任務ID
  //     notifyListeners(); // 通知聽眾更新
  //   }
  // }

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
