import 'package:flutter/material.dart';
import 'intro3.dart';
import 'login.dart';

class Intro2 extends StatefulWidget {
  const Intro2({super.key});

  @override
  State<Intro2> createState() => _HomeState();
}

class _HomeState extends State<Intro2> {
  int _currentPageIndex = 1; // Track the current page index

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
                  padding: const EdgeInsets.all(15.0),
                  child: Image.asset('assets/intro2.jpg'),
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
                    'Get Diagnosed With Our ML Model',
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
                            return Intro3();
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
                    textAlign: TextAlign.center,
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
