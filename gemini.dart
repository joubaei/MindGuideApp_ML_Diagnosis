import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mindguide/login.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'articles.dart';
import 'mappage.dart';
import 'settings.dart';
import 'diagnosis.dart';
import 'dart:async';
import 'texttospeech.dart';

void main() {
  runApp(const Gemini());
}

class Gemini extends StatefulWidget {
  const Gemini({super.key});

  @override
  State<Gemini> createState() => _GeminiState();
}

class _GeminiState extends State<Gemini> {
  final SpeechToText _speechToText = SpeechToText();
  int _currentIndex = 0;
  bool _isListening = false;
  TextEditingController _userInput = TextEditingController();
  final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

  static const apiKey = "AIzaSyCJKhO4PsOzve1BI5vAF5ZxCjLQjxOBt6o";
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final List<Message> _messages = [];
  bool _showWelcomeMessage = true;
  final StreamController<String> _responseController = StreamController<String>();
  Stream<String> get responseStream => _responseController.stream;

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
    initSpeech();
    responseStream.listen((response) {
      setState(() {
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages.last.message = response;
        } else {
          _messages.add(Message(isUser: false, message: response, date: DateTime.now()));
        }
      });
    });
  }

  @override
  void dispose() {
    _responseController.close();
    super.dispose();
  }

  void initSpeech() async {
    bool available = await _speechToText.initialize(onStatus: (status) {
      setState(() {
        _isListening = status == 'listening';
      });
    }, onError: (error) {
      setState(() {
        _isListening = false;
      });
    });
    if (!available) {
      print("The user has denied the use of speech recognition.");
    }
    setState(() {
      _isListening = false;
    });
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    _speechToText.listen(onResult: (result) {
      setState(() {
        _userInput.text = result.recognizedWords;
      });
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    await sendMessage();
    _userInput.clear();
  }

  Future<void> sendMessage() async {
    final message = _userInput.text.trim();
    if (message.isEmpty) {
      return;
    }
    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
      _userInput.clear();
      if (_showWelcomeMessage) {
        _showWelcomeMessage = false;
      }
    });
    await processResponse(message);
  }

  Future<void> processResponse(String message) async {
    final prompt = 'You are a mental health assistant. Please provide a helpful response related to mental health for the following query: "$message". If the query is not related to mental health, kindly ask the user to provide a question related to mental health.';
    final responseStream = model.generateContentStream([Content.text(prompt)]);
    String completeResponse = '';
    await for (var partialResponse in responseStream) {
      completeResponse += partialResponse.text ?? '';
      _responseController.add(completeResponse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Psychological Assistant',
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_showWelcomeMessage)
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Welcome to Your Psychological Assistant! Ask me anything about mental health.',
                style: TextStyle(color: Colors.black),
              ),
            ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return Messages(
                  isUser: message.isUser,
                  message: message.message,
                  date: DateFormat('HH:mm').format(message.date),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    style: TextStyle(color: Colors.deepPurple),
                    controller: _userInput,
                    decoration: InputDecoration(
                      hintText: 'Type or speak your message...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                SizedBox(width: 2),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                  ),
                  onPressed: sendMessage,
                  child: Icon(Icons.send, color: Colors.white),
                ),
                SizedBox(width: 1),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.green : Colors.deepPurple,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                  ),
                  onPressed: _toggleListening,
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
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
            icon: Icon(Icons.logout),
            label: 'logout',
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  String message;
  final DateTime date;

  Message({required this.isUser, required this.message, required this.date});
}

class Messages extends StatefulWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final TTSService _ttsService = TTSService();
  bool _isSpeaking = false;

  void _toggleSpeaking() async {
    if (_isSpeaking) {
      await _ttsService.stop();
    } else {
      await _ttsService.speak(widget.message);
    }
    setState(() {
      _isSpeaking = !_isSpeaking;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 15).copyWith(
        left: widget.isUser ? 100 : 10,
        right: widget.isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: widget.isUser ? Colors.deepPurpleAccent : Colors.grey.shade100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: widget.isUser ? Radius.circular(10) : Radius.zero,
          topRight: Radius.circular(10),
          bottomRight: widget.isUser ? Radius.zero : Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message,
            style: TextStyle(
              fontSize: 16,
              color: widget.isUser ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.date,
                style: TextStyle(
                  fontSize: 10,
                  color: widget.isUser ? Colors.white : Colors.black,
                ),
              ),
              if (!widget.isUser)
                IconButton(
                  icon: Icon(
                    _isSpeaking ? Icons.stop : Icons.volume_up,
                    color: Colors.black,
                  ),
                  onPressed: _toggleSpeaking,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
