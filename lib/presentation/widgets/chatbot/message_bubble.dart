import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:meenavar_thunai/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    this.onDelete,
    this.onCopy,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          message.isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!message.isFromUser) _buildAvatar(context),
        if (!message.isFromUser) const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment:
                message.isFromUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            children: [
              _buildMessageBubble(context),
              const SizedBox(height: 4),
              _buildMessageInfo(context),
            ],
          ),
        ),
        if (message.isFromUser) const SizedBox(width: 8),
        if (message.isFromUser) _buildUserAvatar(context),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    IconData icon;
    Color backgroundColor;

    switch (message.type) {
      case MessageType.ai:
        icon = Icons.smart_toy_outlined;
        backgroundColor = Colors.blue.shade100;
        break;
      case MessageType.system:
        icon = Icons.info_outline;
        backgroundColor = Colors.green.shade100;
        break;
      case MessageType.error:
        icon = Icons.error_outline;
        backgroundColor = Colors.red.shade100;
        break;
      default:
        icon = Icons.help_outline;
        backgroundColor = Colors.grey.shade100;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        size: 18,
        color:
            message.isErrorMessage ? Colors.red.shade700 : Colors.blue.shade700,
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.person, size: 18, color: Colors.white),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: _getBubbleColor(context),
          borderRadius: _getBorderRadius(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: _buildMessageContent(context),
      ),
    );
  }

  Color _getBubbleColor(BuildContext context) {
    switch (message.type) {
      case MessageType.user:
        return Theme.of(context).colorScheme.primary;
      case MessageType.error:
        return Colors.red.shade50;
      case MessageType.system:
        return Colors.green.shade50;
      default:
        return Theme.of(context).colorScheme.surfaceVariant;
    }
  }

  BorderRadius _getBorderRadius() {
    if (message.isFromUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(18),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(18),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(18),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(18),
      );
    }
  }

  Widget _buildMessageContent(BuildContext context) {
    if (message.isLoading) {
      return _buildLoadingContent();
    }
    bool hasMarkdown =
        message.content.contains('**') ||
        message.content.contains('*') ||
        message.content.contains('`') ||
        message.content.contains('#') ||
        message.content.contains('-') ||
        message.content.contains('1.');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child:
          hasMarkdown && !message.isFromUser
              ? _buildMarkdownContent(context)
              : _buildTextContent(context),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return SelectableText(
      message.content,
      style: TextStyle(
        color:
            message.isFromUser
                ? Colors.white
                : message.isErrorMessage
                ? Colors.red.shade700
                : Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildMarkdownContent(BuildContext context) {
    return MarkdownBody(
      data: message.content,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 15,
          height: 1.4,
        ),
        code: TextStyle(
          backgroundColor: Theme.of(context).colorScheme.surface,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      selectable: true,
    );
  }

  Widget _buildLoadingContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            message.content,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInfo(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.formattedTime,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        if (message.isLongMessage) ...[
          const SizedBox(width: 8),
          Icon(Icons.article_outlined, size: 12, color: Colors.grey.shade500),
        ],
        if (message.isErrorMessage && onRetry != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              'Retry',
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy'),
                  onTap: () {
                    Navigator.pop(context);
                    onCopy?.call();
                  },
                ),
                if (!message.isSystemMessage && onDelete != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onDelete?.call();
                    },
                  ),
                if (message.isErrorMessage && onRetry != null)
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: const Text('Retry'),
                    onTap: () {
                      Navigator.pop(context);
                      onRetry?.call();
                    },
                  ),
              ],
            ),
          ),
    );
  }
}
