import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import '../../../core/storage/hive_storage.dart';
import '../../../core/storage/storage_keys.dart';
import 'ai_models.dart';

class AIAgentProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  List<AIMessage> _messages = [];
  bool _isLoading = false;
  String _error = '';
  String _apiKey = '';
  String _model = 'openai'; // openai or gemini

  List<AIMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get model => _model;

  AIAgentProvider() {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    _apiKey = HiveStorage.getSettings(StorageKeys.aiApiKey, defaultValue: '') as String;
    _model = HiveStorage.getSettings(StorageKeys.selectedAiModel, defaultValue: 'openai') as String;
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    await HiveStorage.setSettings(StorageKeys.aiApiKey, key);
  }

  Future<void> setModel(String model) async {
    _model = model;
    await HiveStorage.setSettings(StorageKeys.selectedAiModel, model);
    notifyListeners();
  }

  Future<void> sendMessage(String prompt) async {
    _messages.add(AIMessage(
      role: 'user',
      content: prompt,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    try {
      if (_apiKey.isEmpty) {
        _messages.add(AIMessage(
          role: 'assistant',
          content: 'Please set your AI API key in Settings. You can use OpenAI or Gemini API.',
          timestamp: DateTime.now(),
        ));
      } else if (_model == 'openai') {
        await _callOpenAI(prompt);
      } else {
        await _callGemini(prompt);
      }
      _error = '';
    } catch (e) {
      _error = 'Failed to get AI response';
      _logger.e('AI error: $e');
      _messages.add(AIMessage(
        role: 'assistant',
        content: 'Sorry, I encountered an error. Please check your API key and try again.',
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _callOpenAI(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are LifeSync AI, a helpful assistant for a personal dashboard app. You help users analyze their income, expenses, water intake, and analytics data. Keep responses concise and insightful.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 500,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      _messages.add(AIMessage(
        role: 'assistant',
        content: content,
        timestamp: DateTime.now(),
      ));
    } else {
      throw Exception('OpenAI API error: ${response.statusCode}');
    }
  }

  Future<void> _callGemini(String prompt) async {
    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': 'You are LifeSync AI, a helpful assistant for a personal dashboard app. You help users analyze their income, expenses, water intake, and analytics data. Keep responses concise and insightful.\n\nUser: $prompt',
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
      _messages.add(AIMessage(
        role: 'assistant',
        content: content,
        timestamp: DateTime.now(),
      ));
    } else {
      throw Exception('Gemini API error: ${response.statusCode}');
    }
  }

  void clearChat() {
    _messages = [];
    notifyListeners();
  }
}
