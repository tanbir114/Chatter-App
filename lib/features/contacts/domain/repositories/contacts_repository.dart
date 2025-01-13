import 'package:chatter/features/contacts/domain/entities/contact_entities.dart';

abstract class ContactsRepository {
  Future<List<ContactEntity>> fetchContacts();
  Future<void> addContact(String email);
}