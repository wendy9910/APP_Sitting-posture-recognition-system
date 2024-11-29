import 'package:flutter/material.dart'; // Flutter的Material Design包
import 'package:provider/provider.dart'; // 狀態管理套件
import '../bluetoothPage/BluetoothConnectionProvider.dart';

class CalibrationPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 244, 245),
      appBar: AppBar(
        title: Text('Calibration Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // 當按下 "upper sensor" 按鈕時，跳轉到 UpperCalibrationPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpperCalibrationPage()),
                );
              },
              child: Text('Upper Sensor Calibration'),
            ),
            SizedBox(height: 20), // 增加一些空白區域
            ElevatedButton(
              onPressed: () {
                // 當按下 "lower sensor" 按鈕時，跳轉到 LowerCalibrationPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LowerCalibrationPage()),
                );
              },
              child: Text('Lower Sensor Calibration'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCalibrationPage extends StatefulWidget {
  @override
  _UpperCalibrationPageState createState() => _UpperCalibrationPageState();
}

class _UpperCalibrationPageState extends State<UpperCalibrationPage> {
  bool isCalibrating = false; // State to track calibration status
  bool isCalibrating0 = false;

  void toggleCalibration(BuildContext context) {
    final bluetoothProvider =
        Provider.of<BluetoothConnectionProvider>(context, listen: false);

    if (!isCalibrating) {
      bluetoothProvider.sendMessage("2"); // Start calibration
      bluetoothProvider.setDataType("2");
      isCalibrating =
          true; // Update state to reflect that calibration has started
    } else {
      bluetoothProvider.sendMessage("3"); // Stop calibration
      bluetoothProvider.setDataType("3");
      isCalibrating =
          false; // Update state to reflect that calibration has stopped
    }

    setState(() {}); // Trigger a rebuild to update the UI
  }

  @override
  Widget build(BuildContext context) {
    // Code to retrieve data and handle the display remains the same...

    final bluetoothProvider = Provider.of<BluetoothConnectionProvider>(context);
    String X1_str = bluetoothProvider.getX1(); // 取得 x1 (String)
    String Y1_str = bluetoothProvider.getY1(); // 取得 y1 (String)
    String X2_str = bluetoothProvider.getX2(); // 取得 x2 (String)
    String Y2_str = bluetoothProvider.getY2(); // 取得 y2 (String)

    // 將 String 轉換為 double
    double X1 = double.tryParse(X1_str) ?? 0; // 如果轉換失敗，預設為 0
    double Y1 = double.tryParse(Y1_str) ?? 0;
    double X2 = double.tryParse(X2_str) ?? 0;
    double Y2 = double.tryParse(Y2_str) ?? 0;

    int x1 = int.tryParse(X1_str) ?? 0; // 如果轉換失敗，預設為 0
    int y1 = int.tryParse(Y1_str) ?? 0;
    int x2 = int.tryParse(X2_str) ?? 0;
    int y2 = int.tryParse(Y2_str) ?? 0;

    Rectangle rectA = Rectangle(230, 70, 400, 250);
    Rectangle rectB = Rectangle(x1, y1, x2, y2);

    // 計算重疊率
    var result = calculateOverlapRatio(rectA, rectB);
    double overlapRatio = result['overlapRatio']!;
    double coverageRatio = result['coverageRatio']!;

    print('重疊率: $overlapRatio');
    print('覆蓋率: $coverageRatio');

    if (overlapRatio > 0.85 && coverageRatio > 0.85) {
      if (210 < x1 && y1 > 60 && x2 < 420) {
        print("Correct!!");
        isCalibrating = true;
        isCalibrating0 = true;
        bluetoothProvider.sendMessage("3");
        bluetoothProvider.setDataType("3");
      }
    }

    double W = (X2 - X1) / 2; // 計算寬度
    double H = (Y2 - Y1) / 2; // 計算高度

    double X = X1 / 2;
    double Y = Y1 / 2;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 237, 244, 245),
      appBar: AppBar(
        title: Text('Sensor Calibration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Calibrating......',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            isCalibrating0
                ? Icon(Icons.check, size: 50, color: Colors.green)
                : CircularProgressIndicator(),
            SizedBox(height: 50),
            Stack(
              children: <Widget>[
                Container(
                  width: 320,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Stack(
                    children: <Widget>[
                      // 固定方框
                      Positioned(
                        top: 35,
                        left: 115,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                        ),
                      ),
                      // 動態方框
                      Positioned(
                        top: Y, // 動態調整 top 的位置
                        left: X,
                        child: Container(
                          width: W,
                          height: H,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: Center(child: Text('Head')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => toggleCalibration(context),
              child: Text(isCalibrating
                  ? 'Stop Calibration'
                  : 'Start Calibration'), // Toggle button text
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.blue, // Button color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LowerCalibrationPage extends StatefulWidget {
  @override
  _LowerCalibrationPage createState() => _LowerCalibrationPage();
}

class _LowerCalibrationPage extends State<LowerCalibrationPage> {
  bool isCalibrating = false; // State to track calibration status
  bool isCalibrating0 = false;

  void toggleCalibration(BuildContext context) {
    final bluetoothProvider =
        Provider.of<BluetoothConnectionProvider>(context, listen: false);

    if (!isCalibrating) {
      bluetoothProvider.sendMessage("4"); // Start calibration
      bluetoothProvider.setDataType("4");
      isCalibrating =
          true; // Update state to reflect that calibration has started
    } else {
      bluetoothProvider.sendMessage("5"); // Stop calibration
      bluetoothProvider.setDataType("5");
      isCalibrating =
          false; // Update state to reflect that calibration has stopped
    }

    setState(() {}); // Trigger a rebuild to update the UI
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothConnectionProvider>(context);

    bool isCalibrating = false;

    String X1_str = bluetoothProvider.getX1(); // 取得 x1 (String)
    String Y1_str = bluetoothProvider.getY1(); // 取得 y1 (String)
    String X2_str = bluetoothProvider.getX2(); // 取得 x2 (String)
    String Y2_str = bluetoothProvider.getY2(); // 取得 y2 (String)

    // 將 String 轉換為 int
    double X1 = double.tryParse(X1_str) ?? 0; // 如果轉換失敗，預設為 0
    double Y1 = double.tryParse(Y1_str) ?? 0;
    double X2 = double.tryParse(X2_str) ?? 0;
    double Y2 = double.tryParse(Y2_str) ?? 0;

    int x1 = int.tryParse(X1_str) ?? 0; // 如果轉換失敗，預設為 0
    int y1 = int.tryParse(Y1_str) ?? 0;
    int x2 = int.tryParse(X2_str) ?? 0;
    int y2 = int.tryParse(Y2_str) ?? 0;

    Rectangle rectA = Rectangle(280, 160, 640, 480);
    Rectangle rectB = Rectangle(x1, y1, x2, y2);

    // 計算重疊率
    var result = calculateOverlapRatio(rectA, rectB);
    double overlapRatio = result['overlapRatio']!;
    double coverageRatio = result['coverageRatio']!;

    print('重疊率: $overlapRatio');
    print('覆蓋率: $coverageRatio');

    if (overlapRatio > 0.85 && coverageRatio > 0.85) {
      if (270 < x1 && y1 > 150) {
        print("Correct!!");
        isCalibrating = true;
        isCalibrating0 = true;
        bluetoothProvider.sendMessage("5");
        bluetoothProvider.setDataType("5");
      }
    }

    double W = (X2 - X1) / 2; // 計算寬度
    double H = (Y2 - Y1) / 2; // 計算高度

    double X = X1 / 2;
    double Y = Y1 / 2;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 237, 244, 245),
      appBar: AppBar(
        title: Text('Sensor Calibration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Calibrating......',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            isCalibrating0
                ? Icon(Icons.check, size: 50, color: Colors.green)
                : CircularProgressIndicator(),
            SizedBox(height: 50),
            Stack(
              children: <Widget>[
                Container(
                  width: 320,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Stack(
                    children: <Widget>[
                      // 固定方框
                      Positioned(
                        top: 80,
                        left: 140,
                        child: Container(
                          width: 180,
                          height: 160,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                        ),
                      ),
                      // 動態方框
                      Positioned(
                        top: Y, // 動態調整 top 的位置
                        left: X,
                        child: Container(
                          width: W,
                          height: H,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: Center(child: Text('Feet')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => toggleCalibration(context),
              child: Text(isCalibrating
                  ? 'Stop Calibration'
                  : 'Start Calibration'), // Toggle button text
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.blue, // Button color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 定義一個類來存儲矩形的坐標
class Rectangle {
  int x1, y1, x2, y2;

  Rectangle(this.x1, this.y1, this.x2, this.y2);
}

Map<String, double> calculateOverlapRatio(Rectangle rectA, Rectangle rectB) {
  // 計算重疊的左上角坐標
  int overlapX1 = (rectA.x1 > rectB.x1) ? rectA.x1 : rectB.x1;
  int overlapY1 = (rectA.y1 > rectB.y1) ? rectA.y1 : rectB.y1;

  // 計算重疊的右下角坐標
  int overlapX2 = (rectA.x2 < rectB.x2) ? rectA.x2 : rectB.x2;
  int overlapY2 = (rectA.y2 < rectB.y2) ? rectA.y2 : rectB.y2;

  // 計算重疊區域的寬度和高度
  int width = overlapX2 - overlapX1;
  int height = overlapY2 - overlapY1;

  // 如果有重疊，計算重疊面積
  int overlapArea = 0;
  if (width > 0 && height > 0) {
    overlapArea = width * height;
  }

  // 計算方形 A 和方形 B 的面積
  int areaA = (rectA.x2 - rectA.x1) * (rectA.y2 - rectA.y1);
  int areaB = (rectB.x2 - rectB.x1) * (rectB.y2 - rectB.y1);

  // 計算重疊率
  double overlapRatio = 0;
  if (overlapArea > 0) {
    int minArea = (areaA < areaB) ? areaA : areaB;
    overlapRatio = overlapArea / minArea;
  }

  // 計算覆蓋率（矩形 B 的重疊區域佔矩形 A 的比例）
  double coverageRatio = 0;
  if (areaA > 0 && overlapArea > 0) {
    coverageRatio = overlapArea / areaA;
  }

  // 返回 overlapRatio、areaB 和 coverageRatio
  return {'overlapRatio': overlapRatio, 'coverageRatio': coverageRatio};
}


// 計算兩個矩形的重疊率
// double calculateOverlapRatio(Rectangle rectA, Rectangle rectB) {
//   // 計算重疊的左上角坐標
//   int overlapX1 = (rectA.x1 > rectB.x1) ? rectA.x1 : rectB.x1;
//   int overlapY1 = (rectA.y1 > rectB.y1) ? rectA.y1 : rectB.y1;

//   // 計算重疊的右下角坐標
//   int overlapX2 = (rectA.x2 < rectB.x2) ? rectA.x2 : rectB.x2;
//   int overlapY2 = (rectA.y2 < rectB.y2) ? rectA.y2 : rectB.y2;

//   // 計算重疊區域的寬度和高度
//   int width = overlapX2 - overlapX1;
//   int height = overlapY2 - overlapY1;

//   // 如果有重疊，計算重疊面積
//   int overlapArea = 0;
//   if (width > 0 && height > 0) {
//     overlapArea = width * height;
//   }

//   // 計算方形 A 和方形 B 的面積
//   int areaA = (rectA.x2 - rectA.x1) * (rectA.y2 - rectA.y1);
//   int areaB = (rectB.x2 - rectB.x1) * (rectB.y2 - rectB.y1);

//   // 計算重疊率
//   double overlapRatio = 0;
//   if (overlapArea > 0) {
//     int minArea = (areaA < areaB) ? areaA : areaB;
//     overlapRatio = overlapArea / minArea;
//   }

//   return overlapRatio;
// }
