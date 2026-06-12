# Smart Home Flutter App

تطبيق Flutter للتحكم في نظام Smart Home عبر WiFi أو Bluetooth.

---

## خطوات التشغيل

### 1. تثبيت Flutter
```
https://docs.flutter.dev/get-started/install
```

### 2. تثبيت Dependencies
```bash
cd smart_home
flutter pub get
```

### 3. تشغيل على الموبايل
```bash
flutter run
```

### 4. بناء APK
```bash
flutter build apk --release
# الـ APK في: build/app/outputs/flutter-apk/app-release.apk
```

---

## إعداد الـ ESP32

### أضف CORS Options في setup() قبل server.begin():
```cpp
server.on("/status", HTTP_OPTIONS, []() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.sendHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  server.sendHeader("Access-Control-Allow-Headers", "Content-Type");
  server.send(204);
});

server.on("/control", HTTP_OPTIONS, []() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.sendHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  server.sendHeader("Access-Control-Allow-Headers", "Content-Type");
  server.send(204);
});
```

---

## WiFi Mode
- الموبايل والـ ESP على نفس شبكة WiFi
- افتح Settings في الـ app وحط IP الـ ESP
- الـ app يعمل GET /status كل 3 ثواني

## Bluetooth Mode
- اشغّل ESP بدون WiFi (أو خلّي WiFi يفشل)
- Pair "SmartHome_ESP32" من إعدادات الموبايل
- افتح Bluetooth في الـ app واختار الجهاز

---

## Structure
```
lib/
├── main.dart           # Entry point
├── models.dart         # HomeState model
├── app_controller.dart # State management + logic
├── wifi_service.dart   # HTTP communication
├── bt_service.dart     # Bluetooth communication
├── home_screen.dart    # Main UI
├── bt_screen.dart      # Bluetooth device picker
└── settings_screen.dart # IP settings
```
