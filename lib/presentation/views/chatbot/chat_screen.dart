import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../core/widgets/message_input.dart';
import '../../../core/widgets/typing_indicator.dart';
import '../../../core/widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [Expanded(child: _buildMessagesList()), _buildInputArea()],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.waves, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meenavar Thunai',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'AI Assistant',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return PopupMenuButton<String>(
              onSelected:
                  (value) => _handleMenuAction(context, value, chatProvider),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all),
                          SizedBox(width: 8),
                          Text('Clear Chat'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'status',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 8),
                          Text('Service Status'),
                        ],
                      ),
                    ),
                    if (chatProvider.messages.isNotEmpty)
                      const PopupMenuItem(
                        value: 'stats',
                        child: Row(
                          children: [
                            Icon(Icons.analytics_outlined),
                            SizedBox(width: 8),
                            Text('Chat Stats'),
                          ],
                        ),
                      ),
                  ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.messages.isEmpty) {
          return _buildEmptyState();
        }

        // Auto-scroll when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollToBottom();
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount:
              chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == chatProvider.messages.length &&
                chatProvider.isLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: TypingIndicator(),
              );
            }

            final message = chatProvider.messages[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MessageBubble(
                message: message,
                onDelete:
                    () => _deleteMessage(context, chatProvider, message.id),
                onCopy: () => _copyMessage(message.content),
                onRetry:
                    message.isErrorMessage
                        ? () => chatProvider.regenerateLastResponse()
                        : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade400],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Meenavar Thunai!',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with your AI assistant',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
            ),
          ),
          child: Column(
            children: [
              if (chatProvider.error != null)
                _buildErrorBanner(chatProvider.error!),
              MessageInput(
                onSendMessage: chatProvider.sendMessage,
                isLoading: chatProvider.isLoading,
                enabled: chatProvider.isServiceConfigured,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red.shade50,
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    ChatProvider chatProvider,
  ) {
    switch (action) {
      case 'clear':
        _showClearChatDialog(context, chatProvider);
        break;
      case 'status':
        _showServiceStatusDialog(context, chatProvider);
        break;
      case 'stats':
        _showChatStatsDialog(context, chatProvider);
        break;
    }
  }

  void _showClearChatDialog(BuildContext context, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Chat'),
            content: const Text('Are you sure you want to clear all messages?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  chatProvider.clearChat();
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  void _showServiceStatusDialog(
    BuildContext context,
    ChatProvider chatProvider,
  ) {
    final status = chatProvider.serviceStatus;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Service Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusRow(
                  'Configured',
                  status['configured'] ? '✅ Yes' : '❌ No',
                ),
                _buildStatusRow('Model', status['model']),
                _buildStatusRow(
                  'API Key',
                  status['hasValidKey'] ? '✅ Valid' : '❌ Invalid',
                ),
                if (!status['configured'])
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'To configure:\n1. Add GEMINI_API_KEY to .env file\n2. Restart the app',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showChatStatsDialog(BuildContext context, ChatProvider chatProvider) {
    final stats = chatProvider.conversationStats;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chat Statistics'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusRow('Total Messages', '${stats['total']}'),
                _buildStatusRow('Your Messages', '${stats['user']}'),
                _buildStatusRow('AI Responses', '${stats['ai']}'),
                if (stats['errors']! > 0)
                  _buildStatusRow('Errors', '${stats['errors']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _deleteMessage(
    BuildContext context,
    ChatProvider chatProvider,
    String messageId,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  chatProvider.deleteMessage(messageId);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
