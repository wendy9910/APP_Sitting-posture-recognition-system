import 'package:english_words/english_words.dart'; // 用於生成隨機英文單詞
import 'package:flutter/material.dart'; // Flutter的Material Design包
import 'package:provider/provider.dart'; // 狀態管理套件
import 'dart:async';
import '../global.dart' as globals; // 引用全局變量

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // 不再需要本地的 isRealTime 變量，直接使用 globals 中的全局變量

  String backgroundImage = 'assets/images/background.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(150, 237, 244, 245),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bad Posture Remind:',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 50),
              ListTile(
                title: Text('Real Time', style: TextStyle(fontSize: 20)),
                leading: Radio(
                  value: true,
                  groupValue: globals.isRealTime, // 使用全局變量
                  onChanged: (bool? value) {
                    setState(() {
                      globals.isRealTime = value!; // 更新全局變量
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('10 seconds', style: TextStyle(fontSize: 20)),
                leading: Radio(
                  value: false,
                  groupValue: globals.isRealTime, // 使用全局變量
                  onChanged: (bool? value) {
                    setState(() {
                      globals.isRealTime = value!; // 更新全局變量
                    });
                  },
                ),
              ),
              SizedBox(height: 50),
              Text(
                'Sitting Time Setting:',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                min: 10,
                max: 90,
                divisions: 8,
                value: globals.sittingTime,
                label: '${globals.sittingTime.round()} minutes',
                onChanged: (double value) {
                  setState(() {
                    globals.sittingTime = value; // 更新全局變量
                  });
                },
              ),
              Text('${globals.sittingTime.round()} minutes',
                  style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
