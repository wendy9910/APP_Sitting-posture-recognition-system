import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import '../screens/scan_screen.dart';
// import '../screens/bluetooth_off_screen.dart';
import 'dart:async';
import 'dart:convert';

class BluetoothDataManager {
  BluetoothDevice? _device;
  StreamSubscription<List<int>>? _dataSubscription;

  // 私有的构造函数
  BluetoothDataManager._privateConstructor();

  // 单例实例
  static final BluetoothDataManager _instance =
      BluetoothDataManager._privateConstructor();

  // 提供获取实例的方法
  static BluetoothDataManager get instance => _instance;

  // 初始化蓝牙设备
  void initializeDevice(BluetoothDevice device) {
    _device = device;
  }

  // 开始监听数据
  void startListening() async {
    if (_device == null) {
      throw Exception("Bluetooth device is not initialized.");
    }

    // 发现设备上的服务
    List<BluetoothService> services = await _device!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == Guid('your-characteristic-uuid')) {
          // 开启通知并监听特征值的变化
          await characteristic.setNotifyValue(true);
          _dataSubscription = characteristic.value.listen((value) {
            // 处理接收到的数据
            print('Received data: ${utf8.decode(value)}');
          });
        }
      }
    }
  }

  // 停止监听数据
  void stopListening() {
    _dataSubscription?.cancel();
  }

  // 发送数据到设备
  Future<void> sendData(String data) async {
    if (_device == null) {
      throw Exception("Bluetooth device is not initialized.");
    }

    // 发送数据逻辑
    List<BluetoothService> services = await _device!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == Guid('your-characteristic-uuid')) {
          List<int> bytes = utf8.encode(data);
          await characteristic.write(bytes, withoutResponse: true);
          print("Data sent to device: $data");
        }
      }
    }
  }
}
