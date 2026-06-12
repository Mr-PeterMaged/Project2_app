// home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_controller.dart';
import 'models.dart';
import 'bt_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, ctrl, _) {
        final s = ctrl.state;
        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A0A0A),
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1a8a4a),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
            title: const Text(
              'Full Control',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white60),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white60),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ConnBar(ctrl: ctrl),
                  const SizedBox(height: 10),
                  _ConnStatus(ctrl: ctrl),
                  const SizedBox(height: 16),
                  _ControlGrid(ctrl: ctrl, state: s),
                  const SizedBox(height: 20),
                  const _SectionLabel('Sensors'),
                  const SizedBox(height: 8),
                  _SensorRow(
                    icon: Icons.thermostat_outlined,
                    label: 'Temperature / Humidity',
                    value: s.tempSensor
                        ? '${s.temperature.toStringAsFixed(1)}°C  /  ${s.humidity.toStringAsFixed(0)}%'
                        : 'Sensor OFF',
                    sub: 'DHT11',
                    alert: false,
                  ),
                  const SizedBox(height: 8),
                  _SensorRow(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Gas Level',
                    value: s.gasSensor ? '${s.gasPercent}%' : 'Sensor OFF',
                    sub: 'MQ2',
                    alert: s.gasDetected,
                  ),
                  const SizedBox(height: 8),
                  _SensorRow(
                    icon: Icons.door_front_door_outlined,
                    label: 'Door / RFID',
                    value: s.locked ? 'Locked 🔒' : 'Unlocked ✅',
                    sub: 'MFRC522',
                    alert: false,
                  ),
                  const SizedBox(height: 8),
                  _DoorButton(
                    isLocked: s.locked,
                    disabled: !s.system,
                    onTap: () => ctrl.toggleDoor(),
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel('Power Controls'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _PowerTile(
                          label: 'MQ2 Power',
                          icon: Icons.power_outlined,
                          isOn: s.mq2Pwr,
                          disabled: !s.system,
                          onTap: () => ctrl.toggle('mq2Pwr'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PowerTile(
                          label: 'LCD Power',
                          icon: Icons.display_settings_outlined,
                          isOn: s.lcdPwr,
                          disabled: !s.system,
                          onTap: () => ctrl.toggle('lcdPwr'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Connection bar ─────────────────────────────────────────
class _ConnBar extends StatelessWidget {
  final AppController ctrl;
  const _ConnBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ConnBtn(
          label: 'WiFi',
          icon: Icons.wifi,
          active: ctrl.mode == ConnMode.wifi,
          onTap: () => ctrl.connectWifi(),
        )),
        const SizedBox(width: 10),
        Expanded(child: _ConnBtn(
          label: 'Bluetooth',
          icon: Icons.bluetooth,
          active: ctrl.mode == ConnMode.bluetooth,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BtScreen())),
        )),
      ],
    );
  }
}

class _ConnBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ConnBtn({required this.label, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0d2d1a) : const Color(0xFF1a1a1a),
          border: Border.all(
            color: active ? const Color(0xFF1a8a4a) : const Color(0xFF2a2a2a),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: active ? const Color(0xFF2dcc6f) : Colors.white38),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: active ? const Color(0xFF2dcc6f) : Colors.white38,
            )),
          ],
        ),
      ),
    );
  }
}

// ── Connection status ──────────────────────────────────────
class _ConnStatus extends StatelessWidget {
  final AppController ctrl;
  const _ConnStatus({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    switch (ctrl.connStatus) {
      case ConnStatus.connected: dotColor = const Color(0xFF2dcc6f); break;
      case ConnStatus.connecting: dotColor = const Color(0xFFf5c400); break;
      case ConnStatus.error: dotColor = const Color(0xFFe24b4a); break;
      default: dotColor = Colors.white24;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2a2a2a)),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8, height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(ctrl.statusMsg,
              style: const TextStyle(fontSize: 12, color: Colors.white54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (ctrl.connStatus == ConnStatus.error)
            GestureDetector(
              onTap: () => ctrl.connectWifi(),
              child: const Text('Retry', style: TextStyle(fontSize: 11, color: Color(0xFF2dcc6f))),
            ),
        ],
      ),
    );
  }
}

// ── Control Grid ──────────────────────────────────────────
class _ControlGrid extends StatelessWidget {
  final AppController ctrl;
  final HomeState state;
  const _ControlGrid({required this.ctrl, required this.state});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _CardData('System', Icons.power_settings_new, 'system', state.system, false),
      _CardData('Gas Sensor', Icons.local_fire_department_outlined, 'gas', state.gasSensor, !state.system),
      _CardData('Temperature', Icons.thermostat_outlined, 'temp', state.tempSensor, !state.system),
      _CardData('LED s', Icons.lightbulb_outline, 'led', state.ledSensor, !state.system),
      _CardData('Buzzer', Icons.volume_up_outlined, 'buzzer', state.buzzer, !state.system),
      _CardData('Auto Light', Icons.auto_awesome_outlined, 'autoLight', state.autoLight, !state.system),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.4,
      children: cards.map((c) => _CtrlCard(
        data: c,
        onTap: () => ctrl.toggle(c.key),
      )).toList(),
    );
  }
}

class _CardData {
  final String label;
  final IconData icon;
  final String key;
  final bool isOn;
  final bool disabled;
  const _CardData(this.label, this.icon, this.key, this.isOn, this.disabled);
}

class _CtrlCard extends StatelessWidget {
  final _CardData data;
  final VoidCallback onTap;
  const _CtrlCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final on = data.isOn;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: data.disabled ? 0.35 : 1.0,
      child: GestureDetector(
        onTap: data.disabled ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: on ? const Color(0xFF0d2d1a) : const Color(0xFF151515),
            border: Border.all(
              color: on ? const Color(0xFF1a8a4a) : const Color(0xFF252525),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(data.icon, size: 26,
                  color: on ? const Color(0xFF2dcc6f) : Colors.white24),
              const SizedBox(height: 6),
              Text(data.label, style: TextStyle(
                fontSize: 11, letterSpacing: 0.4,
                color: on ? const Color(0xFF7ecfa0) : Colors.white38,
              )),
              const SizedBox(height: 2),
              Text(on ? 'ON' : 'OFF', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: on ? const Color(0xFF2dcc6f) : Colors.white30,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sensor Row ────────────────────────────────────────────
class _SensorRow extends StatelessWidget {
  final IconData icon;
  final String label, value, sub;
  final bool alert;
  const _SensorRow({required this.icon, required this.label,
    required this.value, required this.sub, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: alert ? const Color(0xFF2d0d0d) : const Color(0xFF151515),
        border: Border.all(
          color: alert ? const Color(0xFFe24b4a) : const Color(0xFF252525),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20,
              color: alert ? const Color(0xFFf09595) : Colors.white38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(
                  fontSize: 13, color: alert ? const Color(0xFFf09595) : Colors.white70,
                )),
                Text(value, style: TextStyle(
                  fontSize: 12,
                  color: alert ? const Color(0xFFe24b4a) : Colors.white38,
                )),
              ],
            ),
          ),
          Text(sub, style: const TextStyle(fontSize: 11, color: Colors.white24)),
        ],
      ),
    );
  }
}

// ── Power Tile ────────────────────────────────────────────
class _PowerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isOn, disabled;
  final VoidCallback onTap;
  const _PowerTile({required this.label, required this.icon,
    required this.isOn, required this.disabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: disabled ? 0.35 : 1,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: isOn ? const Color(0xFF0d2d1a) : const Color(0xFF151515),
            border: Border.all(
              color: isOn ? const Color(0xFF1a8a4a) : const Color(0xFF252525),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18,
                  color: isOn ? const Color(0xFF2dcc6f) : Colors.white24),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: TextStyle(
                fontSize: 12,
                color: isOn ? const Color(0xFF7ecfa0) : Colors.white38,
              ))),
              Text(isOn ? 'ON' : 'OFF', style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isOn ? const Color(0xFF2dcc6f) : Colors.white30,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: const TextStyle(
      fontSize: 11, letterSpacing: 1.2, color: Colors.white30,
    ));
  }
}

// ── Door Button ───────────────────────────────────────────
class _DoorButton extends StatelessWidget {
  final bool isLocked;
  final bool disabled;
  final VoidCallback onTap;
  const _DoorButton({required this.isLocked, required this.disabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: disabled ? 0.35 : 1,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isLocked ? const Color(0xFF1a1a1a) : const Color(0xFF0d2d1a),
            border: Border.all(
              color: isLocked ? const Color(0xFFe24b4a) : const Color(0xFF1a8a4a),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
                size: 20,
                color: isLocked ? const Color(0xFFe24b4a) : const Color(0xFF2dcc6f),
              ),
              const SizedBox(width: 10),
              Text(
                isLocked ? 'Unlock Door' : 'Lock Door',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? const Color(0xFFe24b4a) : const Color(0xFF2dcc6f),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}