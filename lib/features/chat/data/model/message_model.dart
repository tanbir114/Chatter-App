import 'package:chatter/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel(
      {required super.id,
      required super.conversationId,
      required super.senderId,
      required super.content,
      required super.createdAt});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'],
      conversationId: json['_conversation_id'],
      senderId: json['_sender_id'],
      content: json['_content'],
      createdAt: json['_created_at'],
    );
  }
}
