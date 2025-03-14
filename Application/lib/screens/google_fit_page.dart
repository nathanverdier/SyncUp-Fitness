import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothHeartRatePage extends StatefulWidget {
  const BluetoothHeartRatePage({super.key});

  @override
  _BluetoothHeartRatePageState createState() => _BluetoothHeartRatePageState();
}

class _BluetoothHeartRatePageState extends State<BluetoothHeartRatePage> {
  BluetoothDevice? _device;
  List<int> _heartRate = [];
  String _statusMessage = 'Scan for a smartwatch';
  void _scanDevices() async {
    var statusScan = await Permission.bluetoothScan.request();
    var statusConnect = await Permission.bluetoothConnect.request();
    var statusLocation = await Permission.locationWhenInUse.request();

    if (statusScan.isGranted &&
        statusConnect.isGranted &&
        statusLocation.isGranted) {
      setState(() => _statusMessage = 'Scanning...');

      await FlutterBluePlus.stopScan();
      await Future.delayed(Duration(seconds: 1));
      FlutterBluePlus.startScan(
          timeout: Duration(seconds: 10)); // Increased scan duration

      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          print('Device found: ${r.device.name}'); // Print all device names
          if (r.device.name.isNotEmpty) {
            _connectToDevice(r.device);
            FlutterBluePlus.stopScan(); // Stop scanning once a device is found
            break;
          }
        }
      });
    } else {
      setState(() => _statusMessage = 'Bluetooth permissions denied.');
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    setState(() => _statusMessage = 'Connecting to ${device.name}...');
    try {
      await device.connect();
      _device = device;
      _discoverServices();
      setState(() => _statusMessage = 'Connected to ${device.name}');
    } catch (e) {
      setState(() => _statusMessage = 'Failed to connect to ${device.name}');
    }
  }

  void _discoverServices() async {
    if (_device == null) return;
    setState(() => _statusMessage = 'Discovering services...');
    List<BluetoothService> services = await _device!.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.uuid.toString().contains("2a37")) {
          // UUID for heart rate
          await characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            setState(() => _heartRate = value);
          });
          setState(() => _statusMessage = 'Heart rate data received');
          return; // Exit once the heart rate characteristic is found
        }
      }
    }
    setState(() => _statusMessage = 'Heart rate service not found');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bluetooth Heart Rate Monitor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                "Heart Rate: ${_heartRate.isNotEmpty ? _heartRate[0] : 'N/A'} BPM"),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: _scanDevices, child: Text("Scan Devices")),
            SizedBox(height: 10),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}
