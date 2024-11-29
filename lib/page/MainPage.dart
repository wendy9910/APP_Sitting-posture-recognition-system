import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart'; // 狀態管理套件
import 'bluetoothcontrol.dart';
import 'analyticsPage.dart';
import 'StartPage.dart';
import 'SettingPage.dart';
import 'CalibrationPage.dart';
import 'dart:ui';

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
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color.fromARGB(255, 202, 235, 249), // 修改背景顏色
            selectedItemColor:
                const Color.fromARGB(255, 103, 187, 106), // 修改選中項目的顏色
            unselectedItemColor:
                const Color.fromARGB(255, 91, 90, 90), // 修改未選中項目的顏色
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
          );
        },
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //var appState = context.watch<MyAppState>();
    // String backgroundImage = 'assets/images/background.jpg';

    return Container(
      // color: const Color.fromARGB(255, 237, 244, 245),
      // decoration: BoxDecoration(
      //     // Use BoxDecoration to set the background image
      //     image: DecorationImage(
      //       image: AssetImage(backgroundImage),
      //       fit: BoxFit.cover, // Cover the entire widget area
      //     ),

      //     ),
      color: const Color.fromARGB(150, 237, 244, 245),
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topRight,
      //     end: Alignment.bottomLeft,
      //     colors: [
      //       Color.fromARGB(255, 184, 241, 252), // Subtle teal
      //       Color.fromARGB(255, 231, 245, 247), // Soft sky blue
      //       Color.fromARGB(
      //           255, 245, 245, 245), // Off-white for a light, airy feel
      //     ],
      //   ),
      // ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BTButton(),
            BigCard(),
            SizedBox(height: 50),
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
                    minimumSize: Size(200, 50), // 设置按钮的最小尺寸

                    padding:
                        EdgeInsets.symmetric(horizontal: 16), // 也可以通过内边距来调整按钮大小
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)), // 圓角大小
                    backgroundColor: const Color.fromARGB(255, 163, 185, 195),
                    foregroundColor: Colors.white, // 按鈕上文字的顏色
                  ),
                  child: Text(
                    'Calibration Task',
                    style: TextStyle(
                        fontSize: 25,
                        color: const Color.fromARGB(255, 251, 251, 251)),
                  ),
                ),
              ],
            ),
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
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, right: 8.0),
        child: Ink(
          // decoration: ShapeDecoration(
          //   shape:
          //       StadiumBorder(), // This makes the background of the button elliptical
          //   color: Color.fromARGB(221, 226, 225, 236), // You can set the background color of the button here
          // ),
          child: IconButton(
            icon: Icon(
              Icons.bluetooth,
              color: Color.fromARGB(221, 27, 2, 249),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BluetoothPage(), // Assuming BluetoothPage is a defined widget
                ),
              );
            },
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
          'Are you sitting right?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            fontFamily: 'Rainbow',
            color: Color.fromARGB(221, 40, 39, 39), // 深色文字
          ),
        ),
        SizedBox(height: 20),
        Image.asset(
          'assets/images/P1.png', // 確保這個路徑和檔案名稱與實際匹配
          fit: BoxFit.cover, // 根據需要選擇合適的 BoxFit 屬性
        ),
      ],
    );
  }
}
