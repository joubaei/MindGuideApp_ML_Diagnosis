import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class TTSService {
  static const String _apiKey = "AIzaSyCJKhO4PsOzve1BI5vAF5ZxCjLQjxOBt6o";
  static const String _url = "https://texttospeech.googleapis.com/v1/text:synthesize";

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> speak(String text) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
      },
      body: jsonEncode({
        'input': {'text': text},
        'voice': {
          'languageCode': 'en-US',
          'ssmlGender': 'NEUTRAL',
        },
        'audioConfig': {
          'audioEncoding': 'MP3',
        },
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final audioContent = responseData['audioContent'];
      final bytes = base64Decode(audioContent);
      await _audioPlayer.play(BytesSource(bytes));
    } else {
      throw Exception('Failed to synthesize text');
    }
  }
  Future<void> stop() async {
    await _audioPlayer.stop();
  }
}
