enum MessageType {
  user,
  ai,
  system,
  error,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isLoading;
  final Map<String, dynamic>? metadata;
  
  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    DateTime? timestamp,
    this.isLoading = false,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();
  
  // Copy with method for updating messages
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isLoading,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
      metadata: metadata ?? this.metadata,
    );
  }
  
  // Factory constructors for different message types
  factory ChatMessage.user(String content, {Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: _generateId(),
      content: content,
      type: MessageType.user,
      metadata: metadata,
    );
  }
  
  factory ChatMessage.ai(String content, {Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: _generateId(),
      content: content,
      type: MessageType.ai,
      metadata: metadata,
    );
  }
  
  factory ChatMessage.system(String content, {Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: _generateId(),
      content: content,
      type: MessageType.system,
      metadata: metadata,
    );
  }
  
  factory ChatMessage.loading({String? customMessage}) {
    return ChatMessage(
      id: 'loading_${_generateId()}',
      content: customMessage ?? 'AI is thinking...',
      type: MessageType.ai,
      isLoading: true,
      metadata: {'isTyping': true},
    );
  }
  
  factory ChatMessage.error(String error, {Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: _generateId(),
      content: error,
      type: MessageType.error,
      metadata: {
        'isError': true,
        ...?metadata,
      },
    );
  }
  
  // Generate unique ID
  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
  
  // Utility getters
  bool get isFromUser => type == MessageType.user;
  bool get isFromAI => type == MessageType.ai;
  bool get isSystemMessage => type == MessageType.system;
  bool get isErrorMessage => type == MessageType.error;
  
  // Get formatted timestamp
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  // Get relative time (e.g., "2 minutes ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
  
  // Check if message contains specific content types
  bool get hasLinks => content.contains(RegExp(r'https?://'));
  bool get hasEmail => content.contains(RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'));
  bool get hasPhoneNumber => content.contains(RegExp(r'\b\d{10,}\b'));
  
  // Get word count
  int get wordCount => content.trim().split(RegExp(r'\s+')).length;
  
  // Get character count
  int get characterCount => content.length;
  
  // Check if message is long
  bool get isLongMessage => wordCount > 100 || characterCount > 500;
  
  // Convert to Map for storage/serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
      'metadata': metadata,
    };
  }
  
  // Create from Map (for loading from storage)
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      content: map['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.ai,
      ),
      timestamp: DateTime.parse(map['timestamp'] as String),
      isLoading: map['isLoading'] as bool? ?? false,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
  
  @override
  String toString() {
    return 'ChatMessage(id: $id, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}, type: $type, timestamp: $timestamp, isLoading: $isLoading)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}