import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:qibla_finder/constants.dart';
import '../models/location.dart';

class UpdateLocation extends StatefulWidget {
  final Location location;
  const UpdateLocation({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  State<UpdateLocation> createState() => _UpdateLocationState();
}

class _UpdateLocationState extends State<UpdateLocation> {
  late double screenHeight, screenWidth, ctrwidth;
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    locationNameController.text = widget.location.locationName.toString();
    latitudeController.text = widget.location.locationLatitude.toString();
    longitudeController.text = widget.location.locationLongitude.toString();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 800) {
      ctrwidth = screenWidth / 1.5;
    }
    if (screenWidth < 800) {
      ctrwidth = screenWidth / 1.1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kemas Kini Lokasi'),
      ),
      body: SingleChildScrollView(
          child: Center(
              child: SizedBox(
        width: ctrwidth,
        child: Form(
          key: _formKey,
          child: Column(children: [
            const SizedBox(height: 10),
            TextFormField(
              controller: locationNameController,
              decoration: InputDecoration(
                  labelText: 'Nama Lokasi',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Sila masukkan nama lokasi';
                }
                return null;
              },
            ),
            const SizedBox(height: 5),
            TextFormField(
              controller: latitudeController,
              decoration: InputDecoration(
                  labelText: 'Latitud',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Sila masukkan nilai latitud';
                }
                return null;
              },
            ),
            const SizedBox(height: 5),
            TextFormField(
              controller: longitudeController,
              decoration: InputDecoration(
                  labelText: 'Longitud',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Sila masukkan nilai longitud';
                }
                return null;
              },
            ),
            const SizedBox(height: 5),
            const SizedBox(height: 10),
            SizedBox(
              width: screenWidth,
              height: 50,
              child: ElevatedButton(
                child: const Text("Kemas Kini"),
                onPressed: () {
                  _updateDialog();
                },
              ),
            ),
            const SizedBox(height: 10),
          ]),
        ),
      ))),
    );
  }

  void _updateDialog() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: const Text(
              "Kemas kini lokasi ini",
              style: TextStyle(),
            ),
            content: const Text("Adakah anda pasti?", style: TextStyle()),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  "Ya",
                  style: TextStyle(),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  _updateLocation();
                },
              ),
              TextButton(
                child: const Text(
                  "Tidak",
                  style: TextStyle(),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _updateLocation() {
    String _locationName = locationNameController.text;
    String _latitude = latitudeController.text;
    String _longitude = longitudeController.text;
    http.post(
        Uri.parse(
            CONSTANTS.server + "/carikiblat/mobile/php/update_location.php"),
        body: {
          "locationId": widget.location.locationId.toString(),
          "locationName": _locationName,
          "latitude": _latitude,
          "longitude": _longitude,
        }).then((response) {
      //print(response.body);
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        //Admin admin = Admin.fromJson(data['data']);
        Fluttertoast.showToast(
            msg: "Berjaya",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        //pd.update(value: 100, msg: "Completed");
        //pd.close();
        Navigator.of(context).pop();
      } else {
        Fluttertoast.showToast(
            msg: data['status'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        //pd.update(value: 0, msg: "Failed");
        //pd.close();
      }
    });
  }
}
