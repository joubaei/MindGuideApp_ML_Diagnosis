import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'intro1.dart'; // Import Intro1 page
import 'articles.dart';
import 'diagnosis.dart';
import 'gemini.dart';
import 'mappage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int _currentIndex = 3;
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  void _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        userEmail = decodedToken['email'];
      });
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Intro1()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('Email'),
              subtitle: Text(userEmail),
              leading: Icon(Icons.email),
            ),
            Divider(),
            ListTile(
              title: Text('Change Password'),
              leading: Icon(Icons.lock),
              onTap: () {
                // Handle password change logic here
              },
            ),
            ListTile(
              title: Text('Notification Settings'),
              leading: Icon(Icons.notifications),
              onTap: () {
                // Handle notification settings logic here
              },
            ),
            Divider(),
            ListTile(
              title: Text('Log Out'),
              leading: Icon(Icons.logout),
              onTap: _logout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        currentIndex: _currentIndex,
        onTap: (index) {
          switch(index) {
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
              break;
          }
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.mark_chat_unread_sharp),
            label: 'HealthBot',
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
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
