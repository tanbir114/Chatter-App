import 'package:chatter/features/conversation/data/datasources/conversations_remote_data_source.dart';
import 'package:chatter/features/conversation/domain/entities/conversation_entity.dart';
import 'package:chatter/features/conversation/domain/repositories/conversations_repository.dart';

class ConversationsRepositoryImpl implements ConversationsRepository {
  final ConversationsRemoteDataSource conversationsRemoteDataSource;

  ConversationsRepositoryImpl({required this.conversationsRemoteDataSource});

  @override
  Future<List<ConversationEntity>> fetchConversations() async {
    return await conversationsRemoteDataSource.fetchConversations();
  }
}
