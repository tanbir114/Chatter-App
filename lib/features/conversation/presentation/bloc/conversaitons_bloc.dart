import 'package:chatter/core/socket_service.dart';
import 'package:chatter/features/conversation/domain/usecases/fetch_conversations_usecase.dart';
import 'package:chatter/features/conversation/presentation/bloc/conversations_event.dart';
import 'package:chatter/features/conversation/presentation/bloc/conversations_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final FetchConversationsUseCase fetchConversationsUseCase;
  final SocketService _socketService = SocketService();

  ConversationsBloc({required this.fetchConversationsUseCase})
      : super(ConversationsInitial()) {
    on<FetchConversations>(_onFetchConversations);
    _initializeSocketListeners();
  }

  void _initializeSocketListeners() {
    try {
      _socketService.socket.on('conversationUpdated', _onConversationUpdated);
    } catch (e) {
      print('Error initializing socket listeners: $e');
    }
  }

  Future<void> _onFetchConversations(
      FetchConversations event, Emitter<ConversationsState> emit) async {
    emit(ConversationsLoading());
    try {
      print("Conversations loading................");
      final conversations = await fetchConversationsUseCase.call();
      emit(ConversationsLoaded(conversations: conversations));
    } catch (error) {
      emit(ConversationsError(message: 'Failed to load conversations'));
    }
  }

  void _onConversationUpdated(data) {
    add(FetchConversations());
  }
}
