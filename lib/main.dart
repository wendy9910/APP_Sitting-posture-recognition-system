import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
