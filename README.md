# APP_Sitting-posture-recognition-system
坐姿辨識系統APP端

#紀錄遇到的release問題
我在輸出release.apk檔時，輸出失敗!原因是flutter_bluetooth_serial套件問題，flutter_bluetooth_serial的最新版本與Android 12(sdk 31以上)的版本不匹配
做了幾項修改:
1. 修改flutter_bluetooth_serial中 的 build.gradle，同步sdk版本
2. 添加Android 12需要的藍芽支援權限
