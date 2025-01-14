import 'package:chatter/features/contacts/domain/usecases/add_contact_usecase.dart';
import 'package:chatter/features/contacts/domain/usecases/fetch_contacts_usecase.dart';
import 'package:chatter/features/contacts/presentation/bloc/contacts_event.dart';
import 'package:chatter/features/contacts/presentation/bloc/contacts_state.dart';
import 'package:chatter/features/conversation/domain/usecases/check_or_create_conversation_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final FetchContactsUseCase fetchContactsUseCase;
  final AddContactUseCase addContactUseCase;
  final CheckOrCreateConversationUseCase checkOrCreateConversationUseCase;

  ContactsBloc(
      {required this.checkOrCreateConversationUseCase,
      required this.fetchContactsUseCase,
      required this.addContactUseCase})
      : super(ContactsInitial()) {
    on<FetchContacts>(_onFetchContacts);
    on<AddContact>(_onAddContacts);
    on<CheckOrCreateConversationEvent>(_onCheckOrCreateConversationEvent);
  }

  Future<void> _onFetchContacts(
      FetchContacts event, Emitter<ContactsState> emit) async {
    emit(ContactsLoading());
    try {
      final contacts = await fetchContactsUseCase.call();
      print("Contacts: ");
      print(contacts);
      emit(ContactsLoaded(contacts));
    } catch (error) {
      emit(ContactsError(message: 'Failed to fetch contacts'));
    }
  }

  Future<void> _onAddContacts(
      AddContact event, Emitter<ContactsState> emit) async {
    emit(ContactsLoading());
    try {
      await addContactUseCase(event.email);
      emit(ContactAdded());
      add(FetchContacts());
    } catch (error) {
      emit(ContactsError(message: 'Failed to add contact'));
    }
  }

  Future<void> _onCheckOrCreateConversationEvent(
      CheckOrCreateConversationEvent event, Emitter<ContactsState> emit) async {
    try {
      emit(ContactsLoading());
      print("Contacts loading.........");
      print(event.contactId);
      final conversationId =
          await checkOrCreateConversationUseCase.call(event.contactId);
      print(
          "Conversation Idddddddddddddddddddd: \n $conversationId \n This is the conversationIdddddddddddd");
      emit(ConversationReady(
        conversationId: conversationId,
        contactName: event.contactName,
      ));
    } catch (error) {
      emit(ContactsError(message: 'Failed to start conversation'));
    }
  }
}
