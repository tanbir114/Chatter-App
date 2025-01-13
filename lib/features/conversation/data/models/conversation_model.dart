import 'package:chatter/features/conversation/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  final String id;
  final String participantName;
  final String lastMessage;
  final DateTime lastMessageTime;

  ConversationModel(
      {required this.id,
      required this.participantName,
      required this.lastMessage,
      required this.lastMessageTime})
      : super(
          id: id,
          participantName: participantName,
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
        );

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['_id'],
      participantName: json['participantName'],
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
    );
  }
}
