import 'dart:async';
import 'dart:convert';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'articles.dart';
import 'diagnosis.dart';
import 'gemini.dart';
import 'settings.dart';
import 'login.dart';

class MapSample extends StatefulWidget {
  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  int _currentIndex = 3;
  final TextEditingController _searchController = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedTherapist;
  final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(33.5588, 35.3750),
    zoom: 15,
  );

  final String apiKey = 'AIzaSyA8614XXV7Q7AWE9Pu4O5c3T1ZmC4iG7TM';

  Future<void> _logout() async {
    await _encryptedData.remove('token');
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _goToInitialLocation();
    _searchTherapistsByCity("Saida");
  }

  Future<void> _goToInitialLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(_initialCameraPosition),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Locate Nearby Therapists',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter a location ',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  //borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.deepPurple),
                  onPressed: () => _searchTherapistsByCity(_searchController.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          if (_selectedTherapist != null)
            Container(
              padding: EdgeInsets.all(12.0),
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Name: ${_selectedTherapist!['name']}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text("Address: ${_selectedTherapist!['formatted_address'] ?? 'Address not available'}"),
                  if (_selectedTherapist!['formatted_phone_number'] != null)
                    Text("Phone: ${_selectedTherapist!['formatted_phone_number']}"),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _launchDirections(),
                    child: Text('Directions',style: TextStyle(color: Colors.white) ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.push(context, MaterialPageRoute(builder: (context) => Gemini()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => Article()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => DiagnosisPage()));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (context) => MapSample()));
              break;
            case 4:
              _showLogoutConfirmationDialog();
              break;
          }
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.mark_chat_unread_sharp),
            label: 'MindGuide',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_open_rounded),
            label: 'Diagnosis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.zoom_in_map_sharp),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_rounded),
            label: 'Log Out',
          ),
        ],
      ),
    );
  }

  Future<void> _searchTherapistsByCity(String location) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=therapists+in+$location&key=$apiKey';
    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);

    setState(() {
      _markers.clear();
      for (var result in json['results']) {
        final marker = Marker(
          markerId: MarkerId(result['place_id']),
          position: LatLng(result['geometry']['location']['lat'], result['geometry']['location']['lng']),
          infoWindow: InfoWindow(title: result['name']),
          onTap: () {
            setState(() {
              _selectedTherapist = result;
            });
          },
        );
        _markers.add(marker);
      }
    });

    if (json['results'].isNotEmpty) {
      final firstResult = json['results'][0];
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              firstResult['geometry']['location']['lat'],
              firstResult['geometry']['location']['lng'],
            ),
            zoom: 15,
          ),
        ),
      );
    }
  }

  void _launchDirections() async {
    if (_selectedTherapist != null) {
      final String destination = '${_selectedTherapist!['geometry']['location']['lat']},${_selectedTherapist!['geometry']['location']['lng']}';
      final String url = 'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
