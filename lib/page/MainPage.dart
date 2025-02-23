import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'analyticsPage.dart';
import 'StartPage.dart';
import 'SettingPage.dart';
import 'CalibrationPage.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../bluetoothPage/SelectBondedDevicePage.dart';
import '../bluetoothPage/BluetoothConnectionProvider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGuideSheet();
    });
  }

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
        home: MyHomePage(),
      ),
    );
  }

  void _showGuideSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // 圓角
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  "Let’s Get You Started!",
                  style: TextStyle(
                    fontSize: 20, // 放大字體
                    fontWeight: FontWeight.bold, // 加粗
                    color: const Color.fromARGB(255, 0, 86, 179), // 更顯眼
                  ),
                ),
              ),
              SizedBox(height: 10),
              Divider(thickness: 1), // 添加分隔線
              SizedBox(height: 10),
              _buildStep(Icons.bluetooth, "Connect Bluetooth to Toybrick"),
              _buildStep(Icons.settings, "Start device calibration"),
              _buildStep(
                  Icons.task, "Start the sitting posture recognition task"),
              Spacer(),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Confirm",
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 36, 64, 114),
                      )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // 初始化一些狀態變量
  var selectedIndex = 0; // ...其他狀態變量

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Navigator 的鍵
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // 在導航初始化時推入首頁
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => GeneratorPage()),
      );
    });
  }

  // 切換頁面的函數
  void _onItemTapped(int index) {
    setState(() {
      context.read<MyAppState>().setSelectedIndex(index);
    });

    // 根據索引切換導航頁面
    _navigatorKey.currentState!.push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return _buildPage(index);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // 根據索引構建對應的頁面
  Widget _buildPage(int index) {
    final List<Widget> pages = [
      GeneratorPage(),
      StartPage(),
      AnalyticsPage(),
      SettingPage()
    ];
    return pages[index];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 檢查 Navigator 的返回堆疊
        if (_navigatorKey.currentState!.canPop()) {
          _navigatorKey.currentState!.pop(); // 返回到上一页
          return false; // 攔截返回键
        }
        return true; // 允許退出應用
      },
      child: Scaffold(
        body: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (RouteSettings settings) {
            final appState = context.read<MyAppState>();
            return MaterialPageRoute(
              builder: (context) => _buildPage(appState.selectedIndex),
            );
          },
        ),
        bottomNavigationBar: Consumer<MyAppState>(
          builder: (context, appState, child) {
            return Column(
              mainAxisSize: MainAxisSize.min, // 緊湊排列導航欄
              children: [
                Container(
                  height: 1,
                  color: const Color.fromARGB(255, 220, 220, 220), // 分隔線顏色
                ),
                BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: const Color.fromARGB(255, 240, 240, 240),
                  selectedItemColor: const Color.fromARGB(255, 0, 86, 179),
                  unselectedItemColor: const Color.fromARGB(255, 130, 130, 130),
                  selectedFontSize: 14,
                  unselectedFontSize: 12,
                  elevation: 8,
                  currentIndex: appState.selectedIndex,
                  onTap: _onItemTapped,
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
                ),
              ],
            );
          },
        ),
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
                    minimumSize: const Size(200, 50),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: const Color.fromARGB(255, 36, 64, 114),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.2), // 陰影顏色
                  ),
                  child: const Text(
                    'Calibration Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DengXian',
                      color: Color.fromARGB(255, 245, 247, 250),
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
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, right: 12.0),
        child: Container(
          width: 30,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15),
            color: Color.fromARGB(255, 36, 64, 114),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
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
                print('Connect -> selected ${selectedDevice.address}');

                final bluetoothProvider =
                    Provider.of<BluetoothConnectionProvider>(context,
                        listen: false);
                await bluetoothProvider.connectToDevice(selectedDevice);
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
