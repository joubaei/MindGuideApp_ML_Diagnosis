import 'dart:convert';
import 'signup.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'gemini.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _HomeState();
}

class _HomeState extends State<Login> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

  Future<void> checklogin() async {
    final Uri url = Uri.parse('http://192.168.1.2/MindGuide/login.php');
    final response = await http.post(url, body: {
      'email': _emailcontroller.text.toString(),
      'password': _passwordcontroller.text.toString(),
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == 1) {
        await _encryptedData.setString('token', jsonResponse['token']);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Gemini()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to connect to server')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 30),
          PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: AppBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 5),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                    ),
                  ),
                  Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              automaticallyImplyLeading: false,
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset('assets/welcome.jpg'),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          child: TextField(
                            enableSuggestions: false,
                            autocorrect: false,
                            controller: _emailcontroller,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              hintText: 'Email',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            controller: _passwordcontroller,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              hintText: 'Password',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: checklogin,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                'Log In',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SignUp();
                                  },
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Sign up',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black54,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
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
}
