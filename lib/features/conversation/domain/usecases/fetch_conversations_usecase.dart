import 'package:chatter/features/conversation/domain/entities/conversation_entity.dart';
import 'package:chatter/features/conversation/domain/repositories/conversations_repository.dart';

class FetchConversationsUseCase {
  final ConversationsRepository repository;

  FetchConversationsUseCase(this.repository);

  Future<List<ConversationEntity>> call() {
    return repository.fetchConversations();
  }
}
