import 'package:flutter/material.dart';
import '../models/admin.dart';
import 'homescreen.dart';
import 'locationscreen.dart';
import 'newlocation.dart';

class AdminHomeScreen extends StatefulWidget {
  final Admin admin;
  const AdminHomeScreen({
    Key? key,
    required this.admin,
  }) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Utama Admin'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              key: const Key('drawer_header'),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.green[900]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  color: Colors.black,
                ),
                accountName: Text('Farah'),
                accountEmail: Text('farah@gmail.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),
              ),
            ),
            _createDrawerItem(
              icon: Icons.location_on,
              text: 'Senarai Lokasi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LocationScreen()),
                );
              },
            ),
            _createDrawerItem(
              icon: Icons.add,
              text: 'Tambah Lokasi Baru',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewLocation()),
                );
              },
            ),
            _createDrawerItem(
              icon: Icons.logout,
              text: 'Log Keluar Akaun',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomeScreen()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/map.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Urus lokasi-lokasi dalam Pekan Jitra.',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 300),
                  Center(
                    child: ButtonTheme(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LocationScreen()),
                          );
                        },
                        icon: Icon(Icons.location_on),
                        label: Text(
                          'Senarai Lokasi',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem(
      //custom widget builder
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: const EdgeInsets.only(left: 8 - 0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
