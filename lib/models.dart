// models.dart
class HomeState {
  bool system;
  bool gasSensor;
  bool tempSensor;
  bool ledSensor;
  bool pirSensor;
  bool ldrSensor;
  bool buzzer;
  bool autoLight;
  bool mq2Pwr;
  bool lcdPwr;
  bool dhtPwr;

  double temperature;
  double humidity;
  int gasPercent;
  bool gasDetected;
  bool led2;
  bool locked;

  HomeState({
    this.system = true,
    this.gasSensor = true,
    this.tempSensor = true,
    this.ledSensor = false,
    this.pirSensor = true,
    this.ldrSensor = true,
    this.buzzer = true,
    this.autoLight = false,
    this.mq2Pwr = true,
    this.lcdPwr = true,
    this.dhtPwr = true,
    this.temperature = 0,
    this.humidity = 0,
    this.gasPercent = 0,
    this.gasDetected = false,
    this.led2 = false,
    this.locked = true,
  });

  factory HomeState.fromJson(Map<String, dynamic> json) {
    return HomeState(
      system: json['system'] ?? true,
      gasSensor: json['gasSensor'] ?? true,
      tempSensor: json['tempSensor'] ?? true,
      ledSensor: json['ledSensor'] ?? false,
      pirSensor: json['pirSensor'] ?? true,
      ldrSensor: json['ldrSensor'] ?? true,
      buzzer: json['buzzer'] ?? true,
      autoLight: json['autoLight'] ?? false,
      mq2Pwr: json['mq2Pwr'] ?? true,
      lcdPwr: json['lcdPwr'] ?? true,
      dhtPwr: json['dhtPwr'] ?? true,
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      gasPercent: (json['gasPercent'] ?? 0).toInt(),
      gasDetected: json['gasDetected'] ?? false,
      led2: json['led2'] ?? false,
      locked: json['locked'] ?? true,
    );
  }

  HomeState copyWith({
    bool? system, bool? gasSensor, bool? tempSensor, bool? ledSensor,
    bool? pirSensor, bool? ldrSensor, bool? buzzer, bool? autoLight,
    bool? mq2Pwr, bool? lcdPwr, bool? dhtPwr, double? temperature, double? humidity,
    int? gasPercent, bool? gasDetected, bool? led2, bool? locked,
  }) {
    return HomeState(
      system: system ?? this.system,
      gasSensor: gasSensor ?? this.gasSensor,
      tempSensor: tempSensor ?? this.tempSensor,
      ledSensor: ledSensor ?? this.ledSensor,
      pirSensor: pirSensor ?? this.pirSensor,
      ldrSensor: ldrSensor ?? this.ldrSensor,
      buzzer: buzzer ?? this.buzzer,
      autoLight: autoLight ?? this.autoLight,
      mq2Pwr: mq2Pwr ?? this.mq2Pwr,
      lcdPwr: lcdPwr ?? this.lcdPwr,
      dhtPwr: dhtPwr ?? this.dhtPwr,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      gasPercent: gasPercent ?? this.gasPercent,
      gasDetected: gasDetected ?? this.gasDetected,
      led2: led2 ?? this.led2,
      locked: locked ?? this.locked,
    );
  }
  Map<String, dynamic> toJson() => {
    'system': system,
    'gasSensor': gasSensor,
    'tempSensor': tempSensor,
    'ledSensor': ledSensor,
    'pirSensor': pirSensor,
    'ldrSensor': ldrSensor,
    'buzzer': buzzer,
    'autoLight': autoLight,
    'mq2Pwr': mq2Pwr,
    'lcdPwr': lcdPwr,
    'dhtPwr': dhtPwr, // قم بإضافة هذا السطر لضمان اكتمال البيانات المرسلة
  };


}