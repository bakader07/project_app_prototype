import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project App Prototype',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: "Project App"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DateTime _start = DateTime.now();
  DateTime _now = DateTime.now();
  String _currentAddress = "Waiting...";
  String _duration = "no duration detected";
  String _deviceIdentifier = "Waiting...";

  // Platform messages are async in nature
  // that's why we made a async function.

  void _calculateDuration() {
    setState(() {
      _duration = DateTime.now().difference(_start).toString();
    });
  }

  void _getDeviceIdentifier() async {
    String deviceIdentifier = "unknown";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceIdentifier = androidInfo.androidId!;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceIdentifier = iosInfo.identifierForVendor!;
    }

    setState(() {
      _deviceIdentifier = deviceIdentifier;
    });
  }

  void _currentTime() {
    setState(() {
      _now = DateTime.now();
    });
  }

  void _currentLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      _currentAddress =
          ' $_locationData\n latitude: ${_locationData.altitude}\n accuracy: ${_locationData.accuracy}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                const Text(
                  'Device Identifier:',
                ),
                Text(
                  _deviceIdentifier,
                  style: Theme.of(context).textTheme.headline5,
                ),
                ElevatedButton(
                  onPressed: _getDeviceIdentifier,
                  child: const Text("Get ID"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                const Text(
                  'Duration between two dates:',
                ),
                Text(
                  _duration,
                  style: Theme.of(context).textTheme.headline5,
                ),
                ElevatedButton(
                  onPressed: _calculateDuration,
                  child: const Text("Get Duration"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                const Text(
                  'Current location is:',
                ),
                Text(
                  _currentAddress,
                  style: Theme.of(context).textTheme.headline5,
                ),
                ElevatedButton(
                  onPressed: _currentLocation,
                  child: const Text("Refresh"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                const Text(
                  'Current time is:',
                ),
                Text(
                  (DateFormat('kk:mm:ss').format(_now)),
                  style: Theme.of(context).textTheme.headline5,
                ),
                ElevatedButton(
                  onPressed: _currentTime,
                  child: const Text("Refresh"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
