import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart'; // 狀態管理套件
import 'bluetoothcontrol.dart';
import 'analyticsPage.dart';
import 'StartPage.dart';
import 'SettingPage.dart';
import 'CalibrationPage.dart';
import 'dart:ui';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../bluetoothPage/BackgroundCollectingTask.dart';
import '../bluetoothPage/DiscoveryPage.dart';
import '../bluetoothPage/SelectBondedDevicePage.dart';
import '../bluetoothPage/BluetoothConnectionProvider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider是provider套件中的一個widget，用於將狀態向下傳遞給子widget
    return ChangeNotifierProvider(
      // MyAppState是一個狀態管理類，它繼承自ChangeNotifier
      create: (context) => MyAppState(),
      // MaterialApp是Flutter中的一個widget，用於配置一些全局設定，比如主題
      child: MaterialApp(
        title: 'Name App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(), // 首頁的widget
        // navigatorObservers: [BluetoothConnectionProvider()],
      ),
    );
  }
}

// MyAppState是一個用於存儲應用狀態的類
class MyAppState extends ChangeNotifier {
  // 初始化一些狀態變量
  var selectedIndex = 0; // ...其他狀態變量

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}

// MyHomePage是有狀態的widget，會創建一個狀態對象 _MyHomePageState
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 切換頁面的函數
  void _onItemTapped(int index) {
    setState(() {
      context.read<MyAppState>().setSelectedIndex(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MyAppState>(
        builder: (context, appState, child) {
          final List<Widget> pages = [
            GeneratorPage(),
            StartPage(),
            AnalyticsPage(),
            SettingPage()
          ];
          return pages[appState.selectedIndex];
        },
      ),
      bottomNavigationBar: Consumer<MyAppState>(
        builder: (context, appState, child) {
          return Column(
            mainAxisSize: MainAxisSize.min, // 選單區域緊湊排列
            children: [
              // 分隔線
              Container(
                height: 1,
                color: const Color.fromARGB(255, 220, 220, 220), // 分隔線顏色
              ),
              // 底部導航欄
              BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor:
                    const Color.fromARGB(255, 240, 240, 240), // 調整背景顏色為淺灰色
                selectedItemColor:
                    const Color.fromARGB(255, 0, 86, 179), // 調整選中項目顏色為深藍色
                unselectedItemColor:
                    const Color.fromARGB(255, 130, 130, 130), // 調整未選中項目顏色為中灰色
                selectedFontSize: 14, // 選中項目文字大小
                unselectedFontSize: 12, // 未選中項目文字大小
                elevation: 8, // 提升選單陰影效果
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.slideshow_rounded),
                    label: 'Start',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics),
                    label: 'Analytics',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_rounded),
                    label: 'Settings',
                  ),
                ],
                currentIndex: appState.selectedIndex,
                // selectedItemColor: Theme.of(context).colorScheme.secondary,
                onTap: _onItemTapped,
              ),
            ],
          );
        },
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BTButton(),
            SizedBox(height: 20),
            BigCard(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CalibrationPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50), // 設置按鈕尺寸
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16), // 調整內邊距
                    backgroundColor:
                        const Color.fromARGB(255, 36, 64, 114), // 背景顏色
                    foregroundColor: Colors.white, // 文字顏色
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // 設置直角樣式
                    ),
                    elevation: 4, // 增加輕微陰影，提升層次感
                    shadowColor: Colors.black.withOpacity(0.2), // 陰影顏色
                  ),
                  child: const Text(
                    'Calibration Task',
                    style: TextStyle(
                      fontSize: 24, // 文字大小
                      fontWeight: FontWeight.w600, // 字體加粗
                      fontFamily: 'DengXian',
                      color: Color.fromARGB(255, 245, 247, 250), // 文字顏色
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 150),
          ],
        ),
      ),
    );
  }
}

class BTButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight, // 對齊右上角
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, right: 12.0), // 設定邊距
        child: Container(
          width: 30, // 按鈕寬度
          height: 50, // 按鈕高度
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15), // 圓角設計
            color: Color.fromARGB(255, 36, 64, 114), // 背景顏色
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15), // 確保 InkWell 匹配邊角
            onTap: () async {
              final BluetoothDevice? selectedDevice =
                  await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return SelectBondedDevicePage(checkAvailability: false);
                  },
                ),
              );

              if (selectedDevice != null) {
                print('Connect -> selected ' + selectedDevice.address);

                // 获取 BluetoothConnectionProvider 并使用它来连接设备
                final bluetoothProvider =
                    Provider.of<BluetoothConnectionProvider>(context,
                        listen: false);
                await bluetoothProvider.connectToDevice(selectedDevice);

                // 连接成功后，可以在应用程序的其他页面使用 bluetoothProvider.connection 访问连接
              } else {
                print('Connect -> no device selected');
              }
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => BluetoothPage(), // 跳轉到藍牙頁面
              //   ),
              // );
            },
            child: Center(
              child: Icon(
                Icons.bluetooth,
                color: Colors.white, // 白色圖標
                size: 24, // 圖標大小
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // 居中對齊
      children: <Widget>[
        Text(
          'Sit smart, Stay healthy',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'DengXian',
            color: Color.fromARGB(255, 30, 30, 30), // 深色文字
          ),
        ),
        const SizedBox(height: 200),
        DefaultTextStyle(
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'DengXian',
            color: Color.fromARGB(255, 108, 117, 125), // 深色文字
          ),
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Hi! Welcome back...', // 動畫文字
                textAlign: TextAlign.center, // 居中對齊
                speed: const Duration(milliseconds: 100), // 每字動畫速度
              ),
            ],
            totalRepeatCount: 1, // 動畫播放一次
            pause: const Duration(milliseconds: 500), // 播放結束停頓
            displayFullTextOnTap: true, // 點擊時顯示全部文字
            stopPauseOnTap: true, // 點擊跳過動畫
          ),
        ),
        const SizedBox(height: 70),
      ],
    );
  }
}

// class BigCard extends StatelessWidget {
//   const BigCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center, // 居中對齊
//       children: <Widget>[
//         Text(
//           'Sit smart, Stay healthy',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'DengXian',
//             color: Color.fromARGB(255, 30, 30, 30), // 深色文字
//           ),
//         ),
//         SizedBox(height: 200),
//         Text(
//           'Hi ! Welcome back...',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'DengXian',
//             color: Color.fromARGB(255, 108, 117, 125), // 深色文字
//           ),
//         ),
//         SizedBox(height: 50),
//       ],
//     );
//   }
// }
