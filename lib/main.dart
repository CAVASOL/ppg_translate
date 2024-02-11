// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Translator',
      home: TranslateScreen(),
    );
  }
}

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  _TranslateScreenState createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  String _translatedText = '';
  String apiURL = dotenv.env["API_URL"]!;
  String xNaverClientId = dotenv.env["X_Naver_Client_Id"]!;
  String xNaverClientSecret = dotenv.env["X_Naver_Client_Secret"]!;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _translateText() async {
    final userInput = _textEditingController.text;
    if (userInput.isNotEmpty) {
      final translation = await translateText(userInput, 'ko', 'en');
      setState(() {
        _translatedText = translation;
      });
    }
  }

  Future<String> translateText(
      String text, String sourceLanguage, String targetLanguage) async {
    final apiUrl = Uri.parse(apiURL);
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Naver-Client-Id': xNaverClientId,
      'X-Naver-Client-Secret': xNaverClientSecret,
    };

    final body = {
      'source': sourceLanguage,
      'target': targetLanguage,
      'text': text,
    };

    final response = await http.post(
      apiUrl,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      final translatedText =
          decodedResponse['message']['result']['translatedText'];
      return translatedText ?? '';
    } else {
      throw Exception('Failed to translate text');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translator'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Enter text to translate',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _translateText,
                child: const Text('Translate'),
              ),
              const SizedBox(height: 16),
              Text(
                _translatedText,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
