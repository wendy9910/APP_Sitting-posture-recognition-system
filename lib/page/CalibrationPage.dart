import 'package:flutter/material.dart'; // Flutter的Material Design包
import 'package:provider/provider.dart'; // 狀態管理套件
import '../bluetoothPage/BluetoothConnectionProvider.dart';

class CalibrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calibration Page'),
      ),
      body: Container(
        // 添加背景圖片和漸變色
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BG3.jpg'), // 背景圖片
            fit: BoxFit.cover, // 覆蓋整個容器
          ),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(120, 240, 240, 240), // 淺灰色
              Color.fromARGB(180, 116, 116, 116), // 深灰色
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // 上半部區塊：坐姿引導
            const SizedBox(height: 40.0),
            const Text(
              "Confirm sitting posture",
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'DengXian',
                color: Color.fromARGB(255, 30, 30, 30), // 深色文字
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              flex: 4, // 上方佔 4 比例空間
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18.0, vertical: 30.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(54, 199, 199, 199)
                        .withOpacity(0.8), // 背景顏色 + 透明度
                    borderRadius: BorderRadius.circular(18.0), // 圓角
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 靠左對齊
                    children: const [
                      Text(
                        "• Sit with your back straight and shoulders relaxed naturally.",
                        style: TextStyle(
                          fontSize: 18, // 文字大小
                          fontWeight: FontWeight.w600, // 字體加粗
                          color: Color.fromARGB(255, 50, 50, 50), // 文字顏色
                        ),
                      ),
                      SizedBox(height: 8.0), // 行間距
                      Text(
                        "• Keep your neck and head upright, aligning your ears with your shoulders.",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 50, 50, 50),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "• Bend your knees at approximately a 90-degree angle.",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 50, 50, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 下半部區塊：裝置校正按鈕
            Expanded(
              flex: 3, // 下方佔 3 比例空間
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // 中心對齊
                children: [
                  const SizedBox(height: 20.0),
                  const Text(
                    "Confirm device location",
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpperCalibrationPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50), // 設置按鈕尺寸
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12), // 調整內邊距
                        backgroundColor:
                            const Color.fromARGB(255, 36, 64, 114), // 背景顏色
                        foregroundColor: Colors.white, // 文字顏色
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // 設置直角樣式
                        ),
                        elevation: 4, // 增加輕微陰影，提升層次感
                        shadowColor: Colors.black.withOpacity(0.2), // 陰影顏色
                      ),
                      child: const Text("Upper Sensor Calibration"),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LowerCalibrationPage()),
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
                      child: const Text("Lower Sensor Calibration"),
                    ),
                  ),
                ],
              ),
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
  bool isCalibrating = false; // 是否開始校正
  bool isCalibrating_show = false; // 是否開始校正(顯示校正狀態icon用)
  bool isCalibrating_button = false; // 是否開始校正(顯示校正狀態icon用)

  @override
  void initState() {
    super.initState();

    // 初始化校正狀態
    isCalibrating = false;
    isCalibrating_show = false;
  }

  void toggleCalibration(BuildContext context) {
    final bluetoothProvider =
        Provider.of<BluetoothConnectionProvider>(context, listen: false);

    if (!isCalibrating) {
      bluetoothProvider.sendMessage("2"); // Start calibration
      bluetoothProvider.setDataType("2");
      isCalibrating_button = true;
      isCalibrating_show = false;
    } else {
      bluetoothProvider.sendMessage("3"); // Stop calibration
      bluetoothProvider.setDataType("3");
      isCalibrating_button = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    //get value from BluetoothConnectionProvider.dart
    final bluetoothProvider = Provider.of<BluetoothConnectionProvider>(context);
    String x1Str = bluetoothProvider.getX1();
    String y1Str = bluetoothProvider.getY1();
    String x2Str = bluetoothProvider.getX2();
    String y2Str = bluetoothProvider.getY2();

    // 將 String 轉換為 int
    int x1 = int.tryParse(x1Str) ?? 0;
    int y1 = int.tryParse(y1Str) ?? 0;
    int x2 = int.tryParse(x2Str) ?? 0;
    int y2 = int.tryParse(y2Str) ?? 0;
    y2 = y1 + (x2 - x1); //調成等比正方形

    Rectangle rectA = Rectangle(230, 70, 400, 250);
    Rectangle rectB = Rectangle(x1, y1, x2, y2);

    // 計算重疊率
    double result = calculateIoU(rectA, rectB);

    print('重合率: $result');

    if (result > 0.7) {
      print("Correct!!");
      isCalibrating = false;
      isCalibrating_show = true;
      isCalibrating_button = false;
      bluetoothProvider.sendMessage("3");
      bluetoothProvider.setDataType("3");
    }

    //畫面用途
    // 將 String 轉換為 double
    double X1 = double.tryParse(x1Str) ?? 0; // 如果轉換失敗，預設為 0
    double Y1 = double.tryParse(y1Str) ?? 0;
    double X2 = double.tryParse(x2Str) ?? 0;
    double Y2 = double.tryParse(y2Str) ?? 0;

    Y2 = Y1 + (X2 - X1); //調成等比正方形

    double W = (X2 - X1) / 2; // 計算寬度
    double H = (Y2 - Y1) / 2; // 計算高度

    double X = X1 / 2;
    double Y = Y1 / 2;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 255, 255),
      appBar: AppBar(
        title: Text('Sensor Calibration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Calibrating......',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'DengXian',
                color: Color.fromARGB(255, 15, 49, 99),
              ),
            ),
            SizedBox(height: 20),
            isCalibrating_show
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
              onPressed: () => toggleCalibration(context), // Toggle button text
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: const Color.fromARGB(255, 36, 64, 114), // 背景顏色
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(isCalibrating_button
                  ? 'Stop Calibration'
                  : 'Start Calibration'),
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
  bool isCalibrating = false;
  bool isCalibrating_show = false;
  bool isCalibrating_button = false;

  @override
  void initState() {
    super.initState();

    // 初始化校正狀態
    isCalibrating = false;
    isCalibrating_show = false;
  }

  void toggleCalibration(BuildContext context) {
    final bluetoothProvider =
        Provider.of<BluetoothConnectionProvider>(context, listen: false);

    if (!isCalibrating) {
      bluetoothProvider.sendMessage("4"); // Start calibration
      bluetoothProvider.setDataType("4");
      isCalibrating_button = true;
      isCalibrating_show = false;
    } else {
      bluetoothProvider.sendMessage("5"); // Stop calibration
      bluetoothProvider.setDataType("5");
      isCalibrating_button = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothConnectionProvider>(context);

    String x1Str = bluetoothProvider.getX1(); // 取得 x1 (String)
    String y1Str = bluetoothProvider.getY1(); // 取得 y1 (String)
    String x2Str = bluetoothProvider.getX2(); // 取得 x2 (String)
    String y2Str = bluetoothProvider.getY2(); // 取得 y2 (String)

    // 將 String 轉換為 int
    int x1 = int.tryParse(x1Str) ?? 0; // 如果轉換失敗，預設為 0
    int y1 = int.tryParse(y1Str) ?? 0;
    int x2 = int.tryParse(x2Str) ?? 0;
    int y2 = int.tryParse(y2Str) ?? 0;

    Rectangle rectA = Rectangle(280, 160, 640, 480);
    Rectangle rectB = Rectangle(x1, y1, x2, y2);

    // 計算重合率
    double result = calculateIoU(rectA, rectB);
    print('重合率: $result');

    if (result > 0.8) {
      print("Correct!!");
      isCalibrating = false;
      isCalibrating_show = true;
      isCalibrating_button = false;
      bluetoothProvider.sendMessage("5");
      bluetoothProvider.setDataType("5");
    }

    //畫出畫面
    // 將 String 轉換為 double
    double X1 = double.tryParse(x1Str) ?? 0; // 如果轉換失敗，預設為 0
    double Y1 = double.tryParse(y1Str) ?? 0;
    double X2 = double.tryParse(x2Str) ?? 0;
    double Y2 = double.tryParse(y2Str) ?? 0;

    double W = (X2 - X1) / 2; // 計算寬度
    double H = (Y2 - Y1) / 2; // 計算高度

    double X = X1 / 2;
    double Y = Y1 / 2;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text('Sensor Calibration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Calibrating......',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'DengXian',
                color: Color.fromARGB(255, 15, 49, 99),
              ),
            ),
            SizedBox(height: 20),
            isCalibrating_show
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
              onPressed: () => toggleCalibration(context), // Toggle button text
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor:
                    Color.fromARGB(255, 15, 49, 99), // Button color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(isCalibrating_button
                  ? 'Stop Calibration'
                  : 'Start Calibration'),
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

double calculateIoU(Rectangle rectA, Rectangle rectB) {
  // 計算交集的左上角與右下角
  int xInter1 = rectA.x1 > rectB.x1 ? rectA.x1 : rectB.x1;
  int yInter1 = rectA.y1 > rectB.y1 ? rectA.y1 : rectB.y1;
  int xInter2 = rectA.x2 < rectB.x2 ? rectA.x2 : rectB.x2;
  int yInter2 = rectA.y2 < rectB.y2 ? rectA.y2 : rectB.y2;

  // 計算交集的寬度與高度
  int interWidth = (xInter2 > xInter1) ? (xInter2 - xInter1) : 0;
  int interHeight = (yInter2 > yInter1) ? (yInter2 - yInter1) : 0;

  // 計算交集的面積
  int intersectionArea = interWidth * interHeight;

  // 計算兩個矩形的面積
  int areaA = (rectA.x2 - rectA.x1) * (rectA.y2 - rectA.y1);
  int areaB = (rectB.x2 - rectB.x1) * (rectB.y2 - rectB.y1);

  // 計算聯集的面積
  int unionArea = areaA + areaB - intersectionArea;

  // 計算 IOU
  double iou = unionArea != 0 ? intersectionArea / unionArea : 0;

  return iou;
}
