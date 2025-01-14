import 'package:chatter/features/contacts/data/repositories/contact_repository_impl.dart';
import 'package:chatter/features/conversation/domain/repositories/conversations_repository.dart';

class CheckOrCreateConversationUseCase {
  final ConversationsRepository conversationsRepository;

  CheckOrCreateConversationUseCase({required this.conversationsRepository});

  Future<String> call(String contactId) async {
    return conversationsRepository.checkOrCreateConversation(contactId);
  }
}
