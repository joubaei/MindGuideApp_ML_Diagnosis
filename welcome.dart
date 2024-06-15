import 'package:flutter/material.dart';
import 'dart:ui';
import 'login.dart';
import 'signup.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10),
            Text(
              'Welcome to',
              style: TextStyle(
                color: Colors.deepPurple, // Setting text color to dark purple
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'HealthBot',
              style: TextStyle(
                color: Colors.deepPurple, // Setting text color to dark purple
                fontWeight: FontWeight.bold,
                fontSize: 27,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Making the background of AppBar transparent
        elevation: 0, // Removing the shadow under the AppBar
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image Widget Positioned Above Buttons
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset('assets/welcome.jpg'),
                ),
                // Blur Effect Over the Image
                /**  Positioned.fill(
                    child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                    color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
                    ),
                    ),
                    ),**/
              ],
            ),
          ),
          // Buttons Centered on Screen
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SizedBox(
                  width: 300, // Set specific width for the buttons
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Login();
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('Log In', style: TextStyle(color: Colors.white,fontSize: 15,),),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple, // Change the color of the button
                    ),
                  ),
                ),
                SizedBox(height: 10), // Added space between the buttons
                SizedBox(
                  width: 300, // Set specific width for the buttons
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SignUp();
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('Sign Up', style: TextStyle(color: Colors.deepPurple,fontSize: 15,)),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70, // Change the color of the button
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
