import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:mindguide/login.dart';

import 'articles.dart';
import 'gemini.dart';
import 'mappage.dart';
import 'settings.dart';

class DiagnosisPage extends StatefulWidget {
  @override
  _DiagnosisPageState createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  int _currentIndex = 2;
  late final List<String> questions;
  final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();


  bool isLoading = false;
  String? age;
  late List<bool?> answers;

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
    questions = [
      "How old are you?",
      "Do you feel nervous most of the times?",
      "Do you experience panic attacks frequently?",
      "Do you experience rapid breathing in various situations?",
      "Do you experience sweating in various situations?",
      "Are you having trouble in concentrating while doing any task throughout your day?",
      "Are you having trouble in sleeping normally?",
      "Are you having trouble with doing work?",
      "Are you experience loss of hope?",
      "Do you tend to feel angry in most situations?",
      "Are you responding too strongly and overreacting to minor problems?",
      "Have you noticed any differences in your eating patterns lately?",
      "Are you having suicidal thoughts?",
      "Have you been feeling tired all the time?",
      "Do you have any close friends?",
      "Do you consider yourself addicted to social media?",
      "Have you experienced a significant and rapid increase in your weight?",
      "Do you consider yourself to be introverted?",
      "Are you referring to a distressing memory that suddenly comes to mind?",
      "Have you been having nightmares?",
      "Are you tending to avoid people or activities?",
      "Do you view life in a pessimistic way?",
      "Do you tend to hold yourself responsible for everything that goes wrong?",
      "Are you experiencing hallucinations?",
      "Do you engage in repetitive actions or behaviors?",
      "Do you notice any changes in your mental health symptoms that coincide with specific seasons of the year?",
      "Do you experience increased energy suddenly?",
    ];
    answers = List.generate(questions.length, (index) => null);
  }

  void _getDiagnosis(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> userData = {
      'age': int.tryParse(age ?? '0'),
      'feeling.nervous': answers[1] == true ? 1 : 0,
      'panic': answers[2] == true ? 1 : 0,
      'breathing.rapidly': answers[3] == true ? 1 : 0,
      'sweating': answers[4] == true ? 1 : 0,
      'trouble.in.concentration': answers[5] == true ? 1 : 0,
      'having.trouble.in.sleeping': answers[6] == true ? 1 : 0,
      'having.trouble.with.work': answers[7] == true ? 1 : 0,
      'hopelessness': answers[8] == true ? 1 : 0,
      'anger': answers[9] == true ? 1 : 0,
      'over.react': answers[10] == true ? 1 : 0,
      'change.in.eating': answers[11] == true ? 1 : 0,
      'suicidal.thought': answers[12] == true ? 1 : 0,
      'feeling.tired': answers[13] == true ? 1 : 0,
      'close.friend': answers[14] == true ? 1 : 0,
      'social.media.addiction': answers[15] == true ? 1 : 0,
      'weight.gain': answers[16] == true ? 1 : 0,
      'introvert': answers[17] == true ? 1 : 0,
      'popping.up.stressful.memory': answers[18] == true ? 1 : 0,
      'having.nightmares': answers[19] == true ? 1 : 0,
      'avoids.people.or.activities': answers[20] == true ? 1 : 0,
      'feeling.negative': answers[21] == true ? 1 : 0,
      'blamming.yourself': answers[22] == true ? 1 : 0,
      'hallucinations': answers[23] == true ? 1 : 0,
      'repetitive.behaviour': answers[24] == true ? 1 : 0,
      'seasonally': answers[25] == true ? 1 : 0,
      'increased.energy': answers[26] == true ? 1 : 0,
    };

    String diagnosis = 'No diagnosis';

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.2:8001/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      print('Sending data: ${jsonEncode(userData)}');
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        diagnosis = jsonResponse['predictions']
            .join(", ");
      } else {
        throw Exception('Failed to get diagnosis: ${response.statusCode}');
      }
    } catch (error) {
      diagnosis = 'Failed to get diagnosis. Error: $error';
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            'Diagnosis Result',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/loadingAnimation.json',
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Text(
              'Diagnosis Result: $diagnosis',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 5),
            Text(
              'Feel free to discuss the diagnosis with our chatbot.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.0),
            ),
            SizedBox(height: 5),
            Text(
              'Contact your nearest therapist using our maps.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.0),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Get Diagnosis',
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              ...List.generate(
                questions.length,
                    (index) {
                  return DiagnosisContainer(
                    question: questions[index],
                    questionNumber: index + 1,
                    age: age,
                    onAnswerChanged: (bool? answer) {
                      setState(() {
                        if (index == 0) {
                          age = answer.toString();
                        } else {
                          answers[index] = answer;
                        }
                      });
                    },
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _getDiagnosis(context);
                },
                child: Text('Get Diagnosed'),
              ),
            ],
          ),
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
              label: 'log Ou',
            ),
          ],
        ),
      );
    }
  }
}

class DiagnosisContainer extends StatefulWidget {
  final String question;
  final int questionNumber;
  final String? age;
  final ValueChanged<bool?>? onAnswerChanged;

  DiagnosisContainer({
    required this.question,
    required this.questionNumber,
    this.age,
    this.onAnswerChanged,
  });

  @override
  _DiagnosisContainerState createState() => _DiagnosisContainerState();
}

class _DiagnosisContainerState extends State<DiagnosisContainer> {
  TextEditingController ageController = TextEditingController();
  bool isAgeConfirmed = false;
  bool? answer;
  late String? age;

  @override
  void initState() {
    super.initState();
    age = widget.age;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey[100],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${widget.questionNumber}: ${widget.question}',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8.0),
          if (widget.questionNumber == 1 && !isAgeConfirmed)
            Column(
              children: [
                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter your age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),),
                  ),
                  onChanged: (value) {
                    setState(() {
                      age = value;
                    });
                  },
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAgeConfirmed = true;
                    });
                    widget.onAnswerChanged?.call(null); //edited here
                  },
                  child: Text('Confirm'),
                ),
              ],
            ),
          if (widget.questionNumber != 1 && !isAgeConfirmed)
            Column(
              children: [
                RadioListTile<bool>(
                  title: Text('Yes'),
                  value: true,
                  groupValue: answer,
                  onChanged: (bool? value) {
                    setState(() {
                      answer = value;
                      widget.onAnswerChanged?.call(value);
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: Text('No'),
                  value: false,
                  groupValue: answer,
                  onChanged: (bool? value) {
                    setState(() {
                      answer = value;
                      widget.onAnswerChanged?.call(value);
                    });
                  },
                ),
              ],
            ),
          if (isAgeConfirmed)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Age: ${age ?? ''}',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAgeConfirmed = false;
                    });
                  },
                  child: Text('Edit'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    ageController.dispose();
    super.dispose();
  }
}


Future<String> makePrediction(
    Map<String, dynamic> userData, BuildContext context) async {
  final String apiUrl = 'http://192.168.1.2:8001/predict';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      final String diagnosis = jsonDecode(response.body)['predictions'];
      print('Predicted disorder: $diagnosis');
      return 'Diagnosis: $diagnosis';
    } else {
      throw Exception('1 Failed to get diagnosis');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to get diagnosis');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diagnosis App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DiagnosisPage(),
    );
  }
}