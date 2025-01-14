import 'package:chatter/features/conversation/domain/entities/conversation_entity.dart';

abstract class ConversationsRepository {
  Future<List<ConversationEntity>> fetchConversations();

  Future<String> checkOrCreateConversation(String contactId);
}
