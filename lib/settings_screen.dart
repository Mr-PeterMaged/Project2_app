// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _ipCtrl;

  @override
  void initState() {
    super.initState();
    _ipCtrl = TextEditingController(
        text: context.read<AppController>().espIp);
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppController>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('WIFI SETTINGS', style: TextStyle(
              fontSize: 11, letterSpacing: 1.2, color: Colors.white30,
            )),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF252525)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ESP32 IP Address', style: TextStyle(
                    fontSize: 13, color: Colors.white60,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ipCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: '192.168.1.35',
                            hintStyle: const TextStyle(color: Colors.white24),
                            filled: true,
                            fillColor: const Color(0xFF0A0A0A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF2a2a2a)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF2a2a2a)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF1a8a4a)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          ctrl.setIp(_ipCtrl.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Connecting to ${_ipCtrl.text.trim()}...'),
                              backgroundColor: const Color(0xFF1a8a4a),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1a8a4a),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Set', style: TextStyle(
                            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500,
                          )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('ABOUT', style: TextStyle(
              fontSize: 11, letterSpacing: 1.2, color: Colors.white30,
            )),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF252525)),
              ),
              child: Column(
                children: [
                  _InfoRow('App', 'Smart Home Controller'),
                  const Divider(color: Color(0xFF252525), height: 20),
                  _InfoRow('Protocol', 'HTTP REST / Bluetooth SPP'),
                  const Divider(color: Color(0xFF252525), height: 20),
                  _InfoRow('ESP Port', '8080'),
                  const Divider(color: Color(0xFF252525), height: 20),
                  _InfoRow('BT Device', 'SmartHome_ESP32'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white38)),
        Text(value, style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
