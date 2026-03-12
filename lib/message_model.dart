
enum MessageRole { user, bot }


class MessageModel {

 
  final String      id;        
  final String      content;   
  final MessageRole role;       
  final DateTime    timestamp;  
  final bool        isLoading; 

  
  const MessageModel({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false, 
  });

 
  factory MessageModel.fromUser(String content) {
    return MessageModel(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      content:   content,
      role:      MessageRole.user,
      timestamp: DateTime.now(),
    );
  }


  factory MessageModel.fromBot(String content, {bool isLoading = false}) {
    return MessageModel(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      content:   content,
      role:      MessageRole.bot,
      timestamp: DateTime.now(),
      isLoading: isLoading,
    );
  }

  MessageModel copyWith({String? content, bool? isLoading}) {
    return MessageModel(
      id:        id,
      content:   content   ?? this.content,
      role:      role,
      timestamp: timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isUser => role == MessageRole.user;
}
