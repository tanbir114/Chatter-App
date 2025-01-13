abstract class ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String conversationId;

  LoadMessagesEvent({required this.conversationId});
}

class SendMessageEvent extends ChatEvent {
  final String conversationId;
  final String content;

  SendMessageEvent({required this.conversationId, required this.content});
}

class ReceiveMessageEvent extends ChatEvent {
  final Map<String, dynamic> message;

  ReceiveMessageEvent({required this.message});
}
