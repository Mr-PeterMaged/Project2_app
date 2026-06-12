// bt_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'app_controller.dart';

class BtScreen extends StatefulWidget {
  const BtScreen({super.key});
  @override
  State<BtScreen> createState() => _BtScreenState();
}

class _BtScreenState extends State<BtScreen> {
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() => _scanning = true);
    await context.read<AppController>().scanBluetooth();
    setState(() => _scanning = false);
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
        title: const Text('Bluetooth Devices',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: Icon(_scanning ? Icons.hourglass_empty : Icons.refresh,
                color: const Color(0xFF2dcc6f)),
            onPressed: _scanning ? null : _scan,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF252525)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.white38),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Make sure ESP32 is powered and not connected to WiFi. Pair "SmartHome_ESP32" in phone Bluetooth settings first.',
                      style: TextStyle(fontSize: 12, color: Colors.white38, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('PAIRED DEVICES', style: TextStyle(
              fontSize: 11, letterSpacing: 1.2, color: Colors.white30,
            )),
            const SizedBox(height: 10),
            if (_scanning)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: Color(0xFF2dcc6f)),
                ),
              )
            else if (ctrl.btDevices.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF252525)),
                ),
                child: const Center(
                  child: Text('No paired devices found.\nPair the ESP32 in Bluetooth settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.6)),
                ),
              )
            else
              ...ctrl.btDevices.map((device) => _DeviceTile(
                device: device,
                onTap: () async {
                  await ctrl.connectBluetooth(device);
                  if (context.mounted) Navigator.pop(context);
                },
              )),
          ],
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final BluetoothDevice device;
  final VoidCallback onTap;
  const _DeviceTile({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEsp = (device.name ?? '').contains('SmartHome');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isEsp ? const Color(0xFF0d2d1a) : const Color(0xFF151515),
          border: Border.all(
            color: isEsp ? const Color(0xFF1a8a4a) : const Color(0xFF252525),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.bluetooth,
              color: isEsp ? const Color(0xFF2dcc6f) : Colors.white38, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name ?? 'Unknown', style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: isEsp ? const Color(0xFF7ecfa0) : Colors.white70,
                  )),
                  Text(device.address, style: const TextStyle(
                    fontSize: 11, color: Colors.white30,
                  )),
                ],
              ),
            ),
            if (isEsp)
              const Text('Connect', style: TextStyle(
                fontSize: 12, color: Color(0xFF2dcc6f), fontWeight: FontWeight.w500,
              )),
          ],
        ),
      ),
    );
  }
}
