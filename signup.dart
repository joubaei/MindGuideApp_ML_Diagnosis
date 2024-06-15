import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isEmailValid(String email) => RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+'
  ).hasMatch(email);

  Future<void> register() async {
    if (!isEmailValid(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email format'))
      );
      return;
    }
    final Uri url = Uri.parse('http://192.168.1.2/MindGuide/signup.php');
    final response = await http.post(url, body: {
      'email': _emailController.text.toString(),
      'password': _passwordController.text.toString(),
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == 1) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Login()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed')));
      }
    } else {
      print('Failed to register: ${response.reasonPhrase}');
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
            preferredSize: Size.fromHeight(50.0), // Increase the height of the AppBar
            child: AppBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const <Widget>[
                  SizedBox(height: 5),
                  Text(
                    'Welcome To HealthBot',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              automaticallyImplyLeading: false,
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          Expanded(
            child:SingleChildScrollView(
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
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              hintText: 'Enter Email',
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
                            controller: _passwordController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              hintText: 'Enter Password',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: register,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                'Sign Up',
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
                                MaterialPageRoute(builder: (context) => const Login()),
                              );
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Log In',
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
                        const SizedBox(height: 30),
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
