import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qibla_finder/screen/qiblah_screen.dart';
import 'package:geolocator/geolocator.dart';

class GPSScreen extends StatefulWidget {
  const GPSScreen({Key? key}) : super(key: key);

  @override
  State<GPSScreen> createState() => _GPSScreenState();
}

class _GPSScreenState extends State<GPSScreen> {
  bool hasPermission = false;

  Future<void> _getPermission() async {
    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      var status = await Permission.locationWhenInUse.status;
      if (status.isGranted) {
        setState(() {
          hasPermission = true;
        });
      } else {
        var permissionStatus = await Permission.locationWhenInUse.request();
        setState(() {
          hasPermission = permissionStatus.isGranted;
        });
      }
    }
  }

  Future<Position?> _getCurrentLocation() async {
    if (hasPermission) {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _getPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FutureBuilder<Position?>(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(color: Colors.white);
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Text('Error retrieving location');
          } else {
            final position = snapshot.data!;
            return QiblahScreen(
              latitude: position.latitude,
              longitude: position.longitude,
            );
          }
        },
      ),
    );
  }
}
