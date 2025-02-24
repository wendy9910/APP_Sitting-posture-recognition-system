import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import '../database/task_db.dart';
import '../global.dart' as globals;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:async';

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

  Timer? bufferResetTimer;

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

  String generateSHA256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  void resetBufferIfStuck() {
    if (bufferResetTimer != null) {
      bufferResetTimer!.cancel();
    }

    bufferResetTimer = Timer(Duration(seconds: 3), () {
      if (_buffer.isNotEmpty) {
        print("`_buffer` 長時間未變化，強制清除！");
        _buffer = "";
      }
    });
  }

  void _processPoseData() async {
    try {
      while (true) {
        int start = _buffer.indexOf('[');
        int end = _buffer.lastIndexOf(']'); // 改用 `lastIndexOf()` 確保取到最後一個 `]`

        // 當沒有完整的 `[` 和 `]`，直接退出等待更多數據
        if (start == -1 || end == -1 || end <= start) {
          return; // 等待更多數據
        }

        // 檢查 `_buffer` 長度是否異常，防止卡住
        if (_buffer.length > 1024) {
          print("`_buffer` 過大，強制清除舊數據！");
          _buffer = "";
          return;
        }

        // **提取完整數據**
        String fullSegment = _buffer.substring(start + 1, end);

        // **檢查是否包含 SHA-256 校驗碼**
        List<String> segmentParts = fullSegment.split('|');
        if (segmentParts.length != 2) {
          print("SHA-256 格式錯誤，請求重發！");
          _buffer = _buffer.substring(end + 1);
          continue;
        }

        String dataChunk = segmentParts[0].trim(); // 主要座標數據
        String receivedChecksum = segmentParts[1].trim(); // SHA-256 校驗碼

        // 確保 SHA-256 長度正確
        if (receivedChecksum.length != 64) {
          print("SHA-256 長度錯誤，請求重發！");
          _buffer = _buffer.substring(end + 1);
          continue;
        }

        // 驗證 SHA-256
        if (generateSHA256(dataChunk) == receivedChecksum) {
          print("SHA-256 校驗成功，解析數據: $dataChunk");

          // **去掉 `*` 和 `/` 再分割數據**
          String cleanData = dataChunk.replaceAll('*', '').trim();
          cleanData = cleanData.replaceAll('/', '').trim();
          List<String> parts = cleanData.split(',');

          if (parts.length == 2) {
            _receivedUpperBodyData = parts[0].trim();
            _receivedLowerBodyData = parts[1].trim();

            print('上半身: $_receivedUpperBodyData');
            print('下半身: $_receivedLowerBodyData');
            notifyListeners();

            //  儲存到資料庫
            await dbInstance.updatePostureStat(globals.currentTaskId!,
                _receivedUpperBodyData, _receivedLowerBodyData);

            // 成功解析後，防止 `_buffer` 長時間卡住
            resetBufferIfStuck();
          } else {
            print("數據格式錯誤，請求重發！");
          }
        } else {
          print(" SHA-256 驗證失敗，請求重發！");
        }

        // 清理已處理的 `_buffer`
        _buffer = _buffer.substring(end + 1);

        // 如果 `_buffer` 變空，結束 while 迴圈
        if (_buffer.isEmpty) break;
      }
    } catch (e) {
      print("錯誤發生: $e");
      _buffer = ""; //  避免 `_buffer` 出錯後卡住
    }
  }

  void _processCoordinateData() async {
    try {
      while (true) {
        int start = _buffer.indexOf('[');
        int end = _buffer.lastIndexOf(']'); // 改用 `lastIndexOf()` 確保取到最後一個 `]`

        // 當沒有完整的 `[` 和 `]`，直接退出等待更多數據
        if (start == -1 || end == -1 || end <= start) {
          return; // 等待更多數據
        }

        // 檢查 `_buffer` 長度是否異常，防止卡住
        if (_buffer.length > 1024) {
          print("`_buffer` 過大，強制清除舊數據！");
          _buffer = "";
          return;
        }

        // 提取完整數據
        String fullSegment = _buffer.substring(start + 1, end);

        // **檢查是否包含 SHA-256 校驗碼**
        List<String> segmentParts = fullSegment.split('|');
        if (segmentParts.length != 2) {
          print("SHA-256 格式錯誤，請求重發！");
          _buffer = _buffer.substring(end + 1);
          continue;
        }

        String dataChunk = segmentParts[0].trim(); // 主要座標數據
        String receivedChecksum = segmentParts[1].trim(); // SHA-256 校驗碼

        // 確保 SHA-256 長度正確
        if (receivedChecksum.length != 64) {
          print("SHA-256 長度錯誤，請求重發！");
          _buffer = _buffer.substring(end + 1);
          continue;
        }

        // 驗證 SHA-256
        if (generateSHA256(dataChunk) == receivedChecksum) {
          print("SHA-256 校驗成功，解析數據: $dataChunk");

          // 去掉 `*` 和 `/` 再分割座標
          String cleanData = dataChunk.replaceAll('*', '').trim();
          cleanData = cleanData.replaceAll('/', '').trim();
          List<String> parts = cleanData.split(',');

          if (parts.length == 4) {
            _received_x1 = parts[0].trim();
            _received_y1 = parts[1].trim();
            _received_x2 = parts[2].trim();
            _received_y2 = parts[3].trim();

            print(
                '座標資料: ($_received_x1, $_received_y1), ($_received_x2, $_received_y2)');
            notifyListeners();
          } else {
            print("數據格式錯誤，請求重發！");
          }

          // ✅ **成功解析數據後，防止 `_buffer` 長時間卡住**
          resetBufferIfStuck();
        } else {
          print("SHA-256 驗證失敗，請求重發！");
        }

        // **清理已處理的 `_buffer`**
        _buffer = _buffer.substring(end + 1);

        // **如果 `_buffer` 變空，結束 while 迴圈**
        if (_buffer.isEmpty) break;
      }
    } catch (e) {
      print("錯誤發生: $e");
      _buffer = ""; // 避免 `_buffer` 出錯後卡住
    }
  }

  Future<void> startNewTask() async {
    _buffer = '';
    notifyListeners(); // 通知聽眾更新
  }

  // 結束任務時，重置狀態
  Future<void> endTask() async {
    _buffer = '';
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
