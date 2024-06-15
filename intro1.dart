import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'intro2.dart';
import 'login.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'gemini.dart';

class Intro1 extends StatefulWidget {
  const Intro1({super.key});

  @override
  State<Intro1> createState() => _HomeState();
}

class _HomeState extends State<Intro1> {
  final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();
  int _currentPageIndex = 0;


  @override
  void initState() {
    super.initState();
    checkSavedData();
  }

  void checkSavedData() async {
    String? token = await _encryptedData.getString('token');
    if (token != null && token.isNotEmpty) {
      bool isTokenExpired = JwtDecoder.isExpired(token);
      if (!isTokenExpired) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Gemini()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Session expired. Please log in again.')));
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset('assets/intro1.jpg'),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(0, _currentPageIndex == 0),
              SizedBox(width: 5),
              _buildDot(1, _currentPageIndex == 1),
              SizedBox(width: 5),
              _buildDot(2, _currentPageIndex == 2),
            ],
          ),
          SizedBox(height: 40),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Ensure cross-axis alignment
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Text(
                    'Your Personal Mental Health Companion',
                    textAlign: TextAlign.center, // Center the text within its container
                    style: TextStyle(
                      fontSize: 21,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Intro2();
                          },
                        ),
                      );
                    },
                    child: Text(
                      'Next',
                      textAlign: TextAlign.center, // Center the text within its container
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Login();
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Skip Tour',
                    textAlign: TextAlign.center, // Center the text within its container
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          )

        ],
      ),
    );
  }

  Widget _buildDot(int index, bool isActive) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.deepPurple : Colors.grey.withOpacity(0.5),
      ),
    );
  }
}
