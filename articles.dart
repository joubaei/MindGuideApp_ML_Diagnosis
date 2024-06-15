import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:mindguide/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'diagnosis.dart';
import 'gemini.dart';
import 'mappage.dart';
import 'settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Article extends StatefulWidget {
  const Article({Key? key}) : super(key: key);

  @override
  _ArticleState createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  int _currentIndex = 1;
  String _searchQuery = 'mental health';
  final TextEditingController _searchController = TextEditingController();
  final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

  Future<void> _logout() async {
    await _encryptedData.remove('token'); // Delete the token
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
  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Articles',
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for articles...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onSubmitted: _handleSearch,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ArticleModel>>(
              future: fetchArticles(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<ArticleModel>? articles = snapshot.data;
                  return ListView.builder(
                    itemCount: articles!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Card(
                          color: Colors.grey[50],
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                            minVerticalPadding: 20,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  articles[index].title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  articles[index].description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleDetail(article: articles[index]),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
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

  Future<List<ArticleModel>> fetchArticles(String query) async {
    final apiKey = '0635ef23f2a64b9cbc77253b5712a0ab';
    final url = 'https://newsapi.org/v2/everything?q=$query&apiKey=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      return List<ArticleModel>.from(parsed['articles'].map((article) => ArticleModel.fromJson(article)));
    } else {
      throw Exception('Failed to load articles');
    }
  }
}

class ArticleDetail extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetail({Key? key, required this.article}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();
    await _encryptedData.remove('token');
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
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
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Articles',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.deepPurple),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Author: ${article.author}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.deepPurple),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Published on: ${article.publishedAt}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              article.content.length > 300
                  ? '${article.content.substring(0, 300)}...'
                  : article.content,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
            if (article.content.length > 300)
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '[+${article.content.length - 300} chars]',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _launchURL(article.url);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0)),
              ),
              child: Text('Read Full Article', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
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
              _showLogoutConfirmationDialog(context);
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
            label: 'Log out',
          ),
        ],
      ),
    );
  }
}


class ArticleModel {
  final String title;
  final String description;
  final String url;
  final String author;
  final String publishedAt;
  final String content;

  ArticleModel({
    required this.title,
    required this.description,
    required this.url,
    required this.author,
    required this.publishedAt,
    required this.content,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'],
      description: json['description'],
      url: json['url'],
      author: json['author'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
