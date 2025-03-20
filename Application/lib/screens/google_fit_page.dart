import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothHeartRatePage extends StatefulWidget {
  const BluetoothHeartRatePage({Key? key}) : super(key: key);

  @override
  _BluetoothHeartRatePageState createState() => _BluetoothHeartRatePageState();
}

class _BluetoothHeartRatePageState extends State<BluetoothHeartRatePage> {
  BluetoothDevice? _device;
  List<BluetoothService> _services = [];
  // Stockage des valeurs lues pour chaque caractéristique (UUID)
  Map<String, List<int>> _charValues = {};
  String _statusMessage = 'Scan for a smartwatch';

  Future<void> _scanDevices() async {
    var statusScan = await Permission.bluetoothScan.request();
    var statusConnect = await Permission.bluetoothConnect.request();
    var statusLocation = await Permission.locationWhenInUse.request();

    if (statusScan.isGranted &&
        statusConnect.isGranted &&
        statusLocation.isGranted) {
      setState(() => _statusMessage = 'Scanning...');
      await FlutterBluePlus.stopScan();
      await Future.delayed(Duration(seconds: 1));
      FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.name.isNotEmpty) {
            _connectToDevice(r.device);
            FlutterBluePlus.stopScan();
            break;
          }
        }
      });
    } else {
      setState(() => _statusMessage = 'Bluetooth permissions denied.');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => _statusMessage = 'Connecting to ${device.name}...');
    try {
      await device.connect();
      _device = device;
      setState(() => _statusMessage = 'Connected to ${device.name}');
      await Future.delayed(Duration(seconds: 2));
      _discoverServices();
    } catch (e) {
      setState(() => _statusMessage = 'Failed to connect to ${device.name}');
      debugPrint('Error connecting to device: $e');
    }
  }

  Future<void> _discoverServices() async {
    if (_device == null) return;
    setState(() => _statusMessage = 'Discovering services...');

    try {
      List<BluetoothService> services = await _device!.discoverServices();
      setState(() {
        _services = services;
      });

      // Pour chaque service et caractéristique, on tente de lire ou activer les notifications
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          String uuidStr = characteristic.uuid.toString().toLowerCase();

          if (_isRelevantCharacteristic(uuidStr)) {
            // Si la caractéristique supporte la lecture, on la lit
            if (characteristic.properties.read) {
              try {
                var value = await characteristic.read();
                setState(() {
                  _charValues[uuidStr] = value;
                });
              } catch (e) {
                debugPrint("Error reading $uuidStr: $e");
              }
            }
            // Si la caractéristique supporte les notifications, on vérifie la présence du descripteur CCCD (UUID 2902) avant de l'activer
            if (characteristic.properties.notify) {
              bool hasCCCD = characteristic.descriptors
                  .any((d) => d.uuid.toString().toLowerCase().contains("2902"));
              if (hasCCCD) {
                try {
                  await characteristic.setNotifyValue(true);
                  characteristic.value.listen((value) {
                    setState(() {
                      _charValues[uuidStr] = value;
                    });
                  });
                } catch (e) {
                  debugPrint("Error enabling notifications for $uuidStr: $e");
                }
              } else {
                debugPrint(
                    "Characteristic $uuidStr does not have a CCCD descriptor; skipping notifications.");
              }
            }
          }
        }
      }
      setState(() => _statusMessage = 'Data retrieved');
    } catch (e) {
      debugPrint('Error discovering services: $e');
      setState(() => _statusMessage = 'Error discovering services');
    }
  }

  // Filtre des caractéristiques pertinentes liées à l'activité physique
  bool _isRelevantCharacteristic(String uuid) {
    return uuid.startsWith("2a37") || // Fréquence cardiaque
        uuid.startsWith("2a98") || // Calories (si supporté)
        uuid.startsWith("2a7e") || // VO2 max (exemple)
        uuid.startsWith("2a53"); // Pression artérielle (exemple)
  }

  // Formatage spécifique pour certaines caractéristiques
  String _formatValue(String uuid, List<int>? value) {
    if (value == null || value.isEmpty) return 'N/A';
    if (uuid.startsWith("2a37")) {
      // La première octet est le flag, le deuxième est la valeur de la fréquence cardiaque en BPM
      return "Heart Rate: ${value.length > 1 ? value[1] : value[0]} BPM";
    } else if (uuid.startsWith("2a98")) {
      return "Calories: ${value[0]} kcal";
    } else if (uuid.startsWith("2a7e")) {
      return "VO2 max: ${value[0]}"; // à ajuster selon le format réel
    } else if (uuid.startsWith("2a53")) {
      return "Blood Pressure: ${value.join(', ')} mmHg";
    }
    return value.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Physical Activity Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_statusMessage, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _scanDevices, child: const Text("Scan Devices")),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _services.length,
                itemBuilder: (context, serviceIndex) {
                  final service = _services[serviceIndex];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text('Service: ${service.uuid}'),
                      children: service.characteristics.map((characteristic) {
                        String uuidStr =
                            characteristic.uuid.toString().toLowerCase();
                        return ListTile(
                          title: Text('Characteristic: $uuidStr'),
                          subtitle: Text(
                              'Value: ${_formatValue(uuidStr, _charValues[uuidStr])}\nProperties: ${characteristic.properties.toString()}'),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
