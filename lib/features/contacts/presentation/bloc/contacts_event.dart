abstract class ContactsEvent {}

class FetchContacts extends ContactsEvent {}

class CheckOrCreateConversationEvent extends ContactsEvent {
  final String contactId;
  final String contactName;

  CheckOrCreateConversationEvent(
      {required this.contactName, required this.contactId});
}

class AddContact extends ContactsEvent {
  final String email;

  AddContact(this.email);
}
