import 'dart:convert';
import 'package:qibla_finder/screen/updatelocation.dart';
import '../models/location.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qibla_finder/constants.dart';
import 'newlocation.dart';
import 'package:http/http.dart' as http;

class LocationScreen extends StatefulWidget {
  const LocationScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<Location>? locationList = <Location>[];
  String titlecenter = "Loading...";
  late double screenHeight, screenWidth, resWidth;
  var _tapPosition;
  String search = "";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocations(search);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
    } else {
      resWidth = screenWidth * 0.75;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Senarai Lokasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _loadSearchDialog();
            },
          )
        ],
      ),
      body: locationList!.isEmpty
          ? Center(
              child: Text(
                titlecenter,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                ),
                SizedBox(height: 15),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, // Display one item per row
                      childAspectRatio: 3, // Adjust the aspect ratio as needed
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: locationList!.length,
                    itemBuilder: (context, index) {
                      final location = locationList![index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          splashColor: Colors.green,
                          onLongPress: () {
                            _delete(index);
                          },
                          onTapDown: _storePosition,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 20,
                                  child: Text(
                                    location.locationId.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        location.locationName.toString(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Latitud: ${location.locationLatitude.toString()}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Longitud: ${location.locationLongitude.toString()}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          tooltip: "New Location",
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const NewLocation()));
          }),
    );
  }

  void _loadLocations(String _search) {
    http.post(
        Uri.parse(
            CONSTANTS.server + "/carikiblat/mobile/php/load_location.php"),
        body: {
          'search': _search,
        }).then((response) {
      //print(response.body);
      var jsondata = jsonDecode(response.body);
      //print(data);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        var extractdata = jsondata['data'];
        if (extractdata['locations'] != null) {
          locationList = <Location>[];
          extractdata['locations'].forEach((v) {
            locationList!.add(Location.fromJson(v));
          });
        }
        setState(() {});
      }
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  _delete(int index) async {
    RenderBox renderBox = context.findRenderObject()! as RenderBox;

    showMenu(
      context: context,
      items: [
        PopupMenuItem(
          child: GestureDetector(
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) => UpdateLocation(
                              location: locationList![index],
                            )));
                _loadLocations(search);
              },
              child: const Text(
                "Kemas Kini Lokasi",
                style: TextStyle(),
              )),
        ),
        PopupMenuItem(
          child: GestureDetector(
              onTap: () => {
                    Navigator.of(context).pop(),
                    _deleteLocationDialog(index),
                  },
              child: const Text(
                "Buang Lokasi",
                style: TextStyle(),
              )),
        ),
      ],
      position: RelativeRect.fromRect(
        _tapPosition & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & renderBox.size, // Bigger rect, the entire screen
      ),
    );
    //print("Load Menu" + index.toString());
  }

  _deleteLocationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Buang " + locationList![index].locationName.toString(),
            style: const TextStyle(),
          ),
          content: const Text(
            "Adakah anda pasti?",
            style: TextStyle(),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text(
                "Ya",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteLocation(index);
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

  void _deleteLocation(int index) {
    http.post(
        Uri.parse(
            CONSTANTS.server + "/carikiblat/mobile/php/delete_location.php"),
        body: {
          "location_id": locationList![index].locationId
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Berjaya",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        _loadLocations(search);
      } else {
        Fluttertoast.showToast(
            msg: "Gagal",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }

  void _loadSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text(
            "Cari Lokasi ",
          ),
          content: SizedBox(
            height: screenHeight / 6.2,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      labelText: 'Nama Lokasi',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
                ElevatedButton(
                  onPressed: () {
                    search = searchController.text;
                    Navigator.of(context).pop();
                    _loadLocations(search);
                  },
                  child: const Text("Cari"),
                )
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text(
                "Tutup",
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
