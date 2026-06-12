import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'models.dart';

class BtService {
  BluetoothConnection? _connection;
  bool get isConnected => _connection?.isConnected ?? false;
  String _buffer = '';

  static const String deviceName = 'SmartHome_ESP32';

  Future<List<BluetoothDevice>> getPairedDevices() async {
    return await FlutterBluetoothSerial.instance.getBondedDevices();
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address)
          .timeout(const Duration(seconds: 6));
      return true;
    } catch (_) {
      return false;
    }
  }

  void disconnect() {
    _connection?.finish();
    _connection = null;
  }

  // تعديل: الدالة هنا ترسل فقط ولا تنتظر بشكل يدوي معلق
  Future<void> sendCommand(Map<String, dynamic> body) async {
    if (!isConnected) return;
    try {
      final json = jsonEncode(body) + '\n';
      _connection!.output.add(Uint8List.fromList(utf8.encode(json)));
      await _connection!.output.allSent;
    } catch (_) {}
  }

  // تعديل: استقبال البيانات بشكل لحظي وتمريرها عبر Callback function للـ Controller
  void listenToInput(Function(HomeState) onDataReceived) {
    _connection?.input?.listen((Uint8List data) {
      _buffer += utf8.decode(data);

      while (_buffer.contains('\n')) {
        final line = _buffer.split('\n').first;
        _buffer = _buffer.substring(line.length + 1);
        try {
          if (line.trim().isNotEmpty) {
            final Map<String, dynamic> parsedJson = jsonDecode(line.trim());
            final homeState = HomeState.fromJson(parsedJson);
            onDataReceived(homeState); // تحديث الأبلكيشن فوراً
          }
        } catch (_) {
          // لتفادي أي كسر في الـ JSON أثناء النقل
        }
      }
    });
  }
}