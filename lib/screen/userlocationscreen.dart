import 'dart:convert';
import '../models/location.dart';
import 'package:flutter/material.dart';
import 'package:qibla_finder/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class UserLocationScreen extends StatefulWidget {
  const UserLocationScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<UserLocationScreen> createState() => _UserLocationScreenState();
}

class _UserLocationScreenState extends State<UserLocationScreen> {
  List<Location>? locationList = <Location>[];
  String titlecenter = "Loading...";
  late double screenHeight, screenWidth, resWidth;
  var _tapPosition;
  String search = "";
  TextEditingController searchController = TextEditingController();
  int? selectedLocationIndex;

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
                          onTap: () {
                            setState(() {
                              selectedLocationIndex = index;
                            });
                          },
                          onLongPress: _displayImageDialog,
                          //onTapDown: _storePosition,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal:
                                    16.0), // Adjust the vertical and horizontal padding as needed
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 16,
                                  child: Text(
                                    location.locationId.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    location.locationName.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
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

  void _displayImageDialog() {
    final selectedLocation = locationList![selectedLocationIndex!];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CachedNetworkImage(
                  imageUrl: CONSTANTS.server +
                      "/carikiblat/mobile/assets/locations/" +
                      selectedLocation.locationId.toString() +
                      '.jpg',
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 45,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
