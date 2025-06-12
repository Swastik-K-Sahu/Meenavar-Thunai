import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../../core/services/gemini_service.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isServiceConfigured => _geminiService.isConfigured;
  Map<String, dynamic> get serviceStatus => _geminiService.serviceStatus;

  ChatProvider() {
    _initializeChat();
  }

  void _initializeChat() {
    if (!_geminiService.isConfigured) {
      _addMessage(
        ChatMessage.error(
          'Welcome to Meenavar Thunai! 🐟\n\n'
          'To get started, please configure your Gemini API key:\n'
          '1. Get your API key from Google AI Studio\n'
          '2. Add it to your .env file\n'
          '3. Restart the app',
        ),
      );
    } else {
      _addMessage(
        ChatMessage.system(
          '🌊 Welcome to Meenavar Thunai! 🐟\n\n'
          'I\'m your AI assistant, ready to help with:\n'
          '• Fishing tips and techniques\n'
          '• Weather and sea conditions\n'
          '• Local fishing regulations\n'
          '• Equipment recommendations\n'
          '• General questions\n\n'
          'How can I assist you today?',
        ),
      );
    }
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void _removeMessage(String messageId) {
    _messages.removeWhere((msg) => msg.id == messageId);
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    if (!_geminiService.isConfigured) {
      _addMessage(
        ChatMessage.error(
          'API key not configured. Please add your Gemini API key to the .env file and restart the app.',
        ),
      );
      return;
    }

    _error = null;

    final userMessage = ChatMessage.user(content.trim());
    _addMessage(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      final conversationHistory =
          _messages
              .where(
                (msg) =>
                    msg.type != MessageType.system &&
                    msg.type != MessageType.error,
              )
              .where((msg) => msg.id != userMessage.id)
              .takeLast(10) // Last 10 messages for context
              .map(
                (msg) =>
                    '${msg.type == MessageType.user ? "User" : "Assistant"}: ${msg.content}',
              )
              .toList();

      // Generate AI response with context
      final response = await _geminiService.generateResponseWithContext(
        conversationHistory,
        content,
      );

      _addMessage(ChatMessage.ai(response));
      _error = null;
    } catch (e) {
      _error = e.toString();

      String errorMessage = 'Failed to get response';
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('api key')) {
        errorMessage = 'API key error. Please check your configuration.';
      } else if (e.toString().contains('quota')) {
        errorMessage = 'API quota exceeded. Please try again later.';
      }

      _addMessage(ChatMessage.error(errorMessage));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> regenerateLastResponse() async {
    if (_messages.isEmpty) return;

    // Find the last user message
    final lastUserMessageIndex = _messages.lastIndexWhere(
      (msg) => msg.type == MessageType.user,
    );

    if (lastUserMessageIndex == -1) return;

    final lastUserMessage = _messages[lastUserMessageIndex];

    // Remove all messages after the last user message
    _messages.removeRange(lastUserMessageIndex + 1, _messages.length);
    notifyListeners();

    // Regenerate response
    await _sendMessageInternal(lastUserMessage.content);
  }

  Future<void> _sendMessageInternal(String content) async {
    _isLoading = true;
    notifyListeners();

    try {
      final conversationHistory =
          _messages
              .where(
                (msg) =>
                    msg.type != MessageType.system &&
                    msg.type != MessageType.error,
              )
              .takeLast(8)
              .map(
                (msg) =>
                    '${msg.type == MessageType.user ? "User" : "Assistant"}: ${msg.content}',
              )
              .toList();

      final response = await _geminiService.generateResponseWithContext(
        conversationHistory,
        content,
      );

      _addMessage(ChatMessage.ai(response));
    } catch (e) {
      _error = e.toString();
      _addMessage(
        ChatMessage.error('Failed to regenerate response: ${e.toString()}'),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    _initializeChat();
  }

  void deleteMessage(String messageId) {
    _removeMessage(messageId);
  }

  void copyMessage(String content) {
    print('Message copied: $content');
  }

  // Get conversation statistics
  Map<String, int> get conversationStats {
    final userMessages =
        _messages.where((msg) => msg.type == MessageType.user).length;
    final aiMessages =
        _messages.where((msg) => msg.type == MessageType.ai).length;
    final errorMessages =
        _messages.where((msg) => msg.type == MessageType.error).length;

    return {
      'total': _messages.length,
      'user': userMessages,
      'ai': aiMessages,
      'errors': errorMessages,
    };
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Extension to add takeLast method to Iterable
extension IterableExtension<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    if (count >= length) return this;
    return skip(length - count);
  }
}
