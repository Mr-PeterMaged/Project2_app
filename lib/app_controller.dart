// app_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'models.dart';
import 'wifi_service.dart';
import 'bt_service.dart';

enum ConnMode { wifi, bluetooth }
enum ConnStatus { disconnected, connecting, connected, error }

class AppController extends ChangeNotifier {
  HomeState state = HomeState();
  ConnMode mode = ConnMode.wifi;
  ConnStatus connStatus = ConnStatus.disconnected;
  String statusMsg = 'Not connected';
  List<BluetoothDevice> btDevices = [];

  late WifiService _wifi;
  final BtService _bt = BtService();
  Timer? _pollTimer;

  AppController() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('esp_ip') ?? '192.168.1.35';
    _wifi = WifiService(savedIp);
    connectWifi();
  }

  String get espIp => _wifi.ip;

  Future<void> setIp(String ip) async {
    _wifi.ip = ip;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('esp_ip', ip);
    connectWifi();
  }

  // ── WiFi ──────────────────────────────────────────────────
  Future<void> connectWifi() async {
    mode = ConnMode.wifi;
    connStatus = ConnStatus.connecting;
    statusMsg = 'Connecting to ${_wifi.ip}...';
    notifyListeners();

    final result = await _wifi.getStatus();
    if (result != null) {
      state = result;
      connStatus = ConnStatus.connected;
      statusMsg = 'WiFi — ${_wifi.ip}';
      _startPolling();
    } else {
      connStatus = ConnStatus.error;
      statusMsg = 'Cannot reach ESP at ${_wifi.ip}';
    }
    notifyListeners();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (mode != ConnMode.wifi) return;
      final result = await _wifi.getStatus();
      if (result != null) {
        state = result;
        if (connStatus != ConnStatus.connected) {
          connStatus = ConnStatus.connected;
          statusMsg = 'WiFi — ${_wifi.ip}';
        }
        notifyListeners();
      } else {
        if (connStatus == ConnStatus.connected) {
          connStatus = ConnStatus.error;
          statusMsg = 'WiFi lost — retrying...';
          notifyListeners();
        }
      }
    });
  }

  // ── Bluetooth ─────────────────────────────────────────────
  Future<void> scanBluetooth() async {
    btDevices = await _bt.getPairedDevices();
    notifyListeners();
  }

  // ── تعديل دالة البلوتوث في AppController ──────────────────
  Future<void> connectBluetooth(BluetoothDevice device) async {
    _pollTimer?.cancel();
    mode = ConnMode.bluetooth;
    connStatus = ConnStatus.connecting;
    statusMsg = 'Connecting to ${device.name}...';
    notifyListeners();

    final ok = await _bt.connect(device);
    if (ok) {
      // تعديل هنا: استقبال البيانات فوراً عند وصولها من الـ ESP32 وتحديث الواجهة
      _bt.listenToInput((receivedState) {
        state = receivedState;
        notifyListeners();
      });
      connStatus = ConnStatus.connected;
      statusMsg = 'Bluetooth — ${device.name}';
    } else {
      connStatus = ConnStatus.error;
      statusMsg = 'Failed to connect to ${device.name}';
    }
    notifyListeners();
  }

  void disconnectBluetooth() {
    _bt.disconnect();
    connStatus = ConnStatus.disconnected;
    statusMsg = 'Bluetooth disconnected';
    notifyListeners();
  }

  // ── تعديل دالة toggle ───────────────────
  Future<void> toggle(String key) async {
    final updated = _applyToggle(key);
    state = updated;
    notifyListeners();

    final body = _buildBody(key, updated);

    if (mode == ConnMode.wifi) {
      final result = await _wifi.sendControl(body);
      if (result != null) {
        state = result;
        notifyListeners();
      }
    } else if (mode == ConnMode.bluetooth && _bt.isConnected) {
      await _bt.sendCommand(body); // البلوتوث سيرسل والرد سيأتي عبر الـ Stream تلقائياً
    }
  }

  HomeState _applyToggle(String key) {
    final cur = state;
    switch (key) {
      case 'system':
        final newVal = !cur.system;
        if (!newVal) {
          return cur.copyWith(
            system: false, gasSensor: false, tempSensor: false,
            ledSensor: false, pirSensor: false, ldrSensor: false,
            buzzer: false, autoLight: false, mq2Pwr: false, lcdPwr: false,
          );
        }
        return cur.copyWith(system: true);
      case 'gas':     return cur.copyWith(gasSensor: !cur.gasSensor);
      case 'temp':    return cur.copyWith(tempSensor: !cur.tempSensor);
      case 'led':     return cur.copyWith(ledSensor: !cur.ledSensor);
      case 'pir':     return cur.copyWith(pirSensor: !cur.pirSensor);
      case 'ldr':     return cur.copyWith(ldrSensor: !cur.ldrSensor);
      case 'buzzer':  return cur.copyWith(buzzer: !cur.buzzer);
      case 'autoLight': return cur.copyWith(autoLight: !cur.autoLight);
      case 'mq2Pwr':  return cur.copyWith(mq2Pwr: !cur.mq2Pwr);
      case 'lcdPwr':  return cur.copyWith(lcdPwr: !cur.lcdPwr);
      default:        return cur;
    }
  }

  Map<String, dynamic> _buildBody(String key, HomeState s) {
    switch (key) {
      case 'system':    return {'system': s.system, 'gasSensor': s.gasSensor, 'tempSensor': s.tempSensor, 'ledSensor': s.ledSensor, 'pirSensor': s.pirSensor, 'ldrSensor': s.ldrSensor, 'buzzer': s.buzzer, 'autoLight': s.autoLight, 'mq2Pwr': s.mq2Pwr, 'lcdPwr': s.lcdPwr};
      case 'gas':       return {'gasSensor': s.gasSensor};
      case 'temp':      return {'tempSensor': s.tempSensor};
      case 'led':       return {'ledSensor': s.ledSensor};
      case 'pir':       return {'pirSensor': s.pirSensor};
      case 'ldr':       return {'ldrSensor': s.ldrSensor};
      case 'buzzer':    return {'buzzer': s.buzzer};
      case 'autoLight': return {'autoLight': s.autoLight};
      case 'mq2Pwr':    return {'mq2Pwr': s.mq2Pwr};
      case 'lcdPwr':    return {'lcdPwr': s.lcdPwr};
      default:          return {};
    }
  }

// ── تعديل دالة toggleDoor ───────────────────
  Future<void> toggleDoor() async {
    final action = state.locked ? 'open' : 'close';
    final body = {'door': action};

    if (mode == ConnMode.wifi) {
      final result = await _wifi.sendControl(body);
      if (result != null) {
        state = result;
        notifyListeners();
      }
    } else if (mode == ConnMode.bluetooth && _bt.isConnected) {
      await _bt.sendCommand(body); // البلوتوث سيرسل والرد سيأتي عبر الـ Stream تلقائياً
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _bt.disconnect();
    super.dispose();
  }
}