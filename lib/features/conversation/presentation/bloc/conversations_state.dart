import 'package:chatter/features/conversation/domain/entities/conversation_entity.dart';

abstract class ConversationsState {}

class ConversationsInitial extends ConversationsState {}

class ConversationsLoading extends ConversationsState {}

class ConversationsLoaded extends ConversationsState {
  final List<ConversationEntity> conversations;

  ConversationsLoaded({required this.conversations});
}

class ConversationsError extends ConversationsState {
  final String message;

  ConversationsError({required this.message});
}