// wifi_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class WifiService {
  String _ip;
  static const int _port = 8080;
  static const Duration _timeout = Duration(seconds: 4);

  WifiService(this._ip);

  String get ip => _ip;
  set ip(String val) => _ip = val;

  String get _base => 'http://$_ip:$_port';

  Future<HomeState?> getStatus() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/status'))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return HomeState.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  Future<HomeState?> sendControl(Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/control'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return HomeState.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }
}
