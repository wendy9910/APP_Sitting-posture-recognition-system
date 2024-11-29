import 'package:flutter/material.dart'; // Flutter的Material Design包
import 'package:provider/provider.dart'; // 狀態管理套件
import 'page/MainPage.dart';
import '/bluetoothPage/BluetoothConnectionProvider.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => BluetoothConnectionProvider(),
        child: ExampleApplication(),
      ),
    );

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainPage());
  }
}
