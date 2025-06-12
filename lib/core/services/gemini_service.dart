import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:meenavar_thunai/secrets.dart';

class GeminiService {
  static String apiKey =
      AppSecrets.geminiApiKey; // Gemini API Key in AppSecrets
  static String modelName = 'gemini-2.0-flash-lite';

  late final GenerativeModel _model;

  GeminiService() {
    _initializeModel();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.01,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2000,
        stopSequences: [],
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
      systemInstruction: Content.text(
        'You are a helpful AI assistant for the Meenavar Thunai app. '
        'You assist fishermen and coastal communities with information, '
        'weather updates, fishing tips, and general support. '
        'Be friendly, helpful, and culturally sensitive.',
      ),
    );
  }

  Future<String> generateResponse(String message) async {
    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!.trim();
      } else {
        return 'Sorry, I couldn\'t generate a response. Please try again.';
      }
    } on GenerativeAIException catch (e) {
      print('Gemini API Error: ${e.message}');
      return _handleGeminiError(e);
    } catch (e) {
      print('Unexpected error: $e');
      return 'Sorry, something went wrong. Please check your connection and try again.';
    }
  }

  Future<String> generateResponseWithContext(
    List<String> conversationHistory,
    String newMessage,
  ) async {
    try {
      // Build more efficient conversation context
      List<Content> contents = [];

      // Add recent conversation history (last 6 exchanges to avoid token limits)
      final recentHistory = conversationHistory.take(12).toList();

      if (recentHistory.isNotEmpty) {
        String contextMessage =
            'Recent conversation:\n${recentHistory.join('\n')}\n\nCurrent question: $newMessage';
        contents.add(Content.text(contextMessage));
      } else {
        contents.add(Content.text(newMessage));
      }

      final response = await _model.generateContent(contents);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!.trim();
      } else {
        return 'Sorry, I couldn\'t generate a response. Please try again.';
      }
    } on GenerativeAIException catch (e) {
      print('Gemini API Error: ${e.message}');
      return _handleGeminiError(e);
    } catch (e) {
      print('Unexpected error: $e');
      return 'Sorry, something went wrong. Please check your connection and try again.';
    }
  }

  Future<String> generateStreamResponse(String message) async {
    try {
      final content = [Content.text(message)];
      final response = _model.generateContentStream(content);

      String fullResponse = '';
      await for (final chunk in response) {
        if (chunk.text != null) {
          fullResponse += chunk.text!;
        }
      }

      return fullResponse.trim().isNotEmpty
          ? fullResponse.trim()
          : 'Sorry, I couldn\'t generate a response. Please try again.';
    } on GenerativeAIException catch (e) {
      print('Gemini API Error: ${e.message}');
      return _handleGeminiError(e);
    } catch (e) {
      print('Unexpected error: $e');
      return 'Sorry, something went wrong. Please check your connection and try again.';
    }
  }

  String _handleGeminiError(GenerativeAIException e) {
    switch (e.message.toLowerCase()) {
      case String msg when msg.contains('api key'):
        return 'API key error. Please check your configuration.';
      case String msg when msg.contains('quota'):
        return 'API quota exceeded. Please try again later.';
      case String msg when msg.contains('safety'):
        return 'Message blocked by safety filters. Please rephrase your question.';
      case String msg when msg.contains('network'):
        return 'Network error. Please check your internet connection.';
      default:
        return 'AI service temporarily unavailable. Please try again.';
    }
  }

  // Check if service is properly configured
  bool get isConfigured =>
      apiKey.isNotEmpty && apiKey != 'your_actual_api_key_here';

  // Get service status
  Map<String, dynamic> get serviceStatus => {
    'configured': isConfigured,
    'model': modelName,
    'apiKeyLength': apiKey.length,
    'hasValidKey': apiKey.isNotEmpty && apiKey.length > 20,
  };
}
