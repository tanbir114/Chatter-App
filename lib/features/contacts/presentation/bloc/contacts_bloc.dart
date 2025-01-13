import 'package:chatter/features/contacts/domain/usecases/add_contact_usecase.dart';
import 'package:chatter/features/contacts/domain/usecases/fetch_contacts_usecase.dart';
import 'package:chatter/features/contacts/presentation/bloc/contacts_event.dart';
import 'package:chatter/features/contacts/presentation/bloc/contacts_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final FetchContactsUseCase fetchContactsUseCase;
  final AddContactUseCase addContactUseCase;

  ContactsBloc(
      {required this.fetchContactsUseCase, required this.addContactUseCase})
      : super(ContactsInitial()) {
    on<FetchContacts>(_onFetchContacts);
    on<AddContact>(_onAddContacts);
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
}
