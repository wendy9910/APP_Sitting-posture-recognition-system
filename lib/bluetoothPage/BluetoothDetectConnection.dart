import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDetectConnection with ChangeNotifier {
  BluetoothConnection? _connection;
  bool get isConnected => _connection?.isConnected ?? false;

  Future<void> connectToDevice(BluetoothDevice device) async {
    _connection = await BluetoothConnection.toAddress(device.address);
    notifyListeners();
  }

  void sendMessage(String message) {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(message.codeUnits));
    }
  }

  void disposeConnection() {
    _connection?.dispose();
    _connection = null;
    notifyListeners();
  }
}
