import 'package:chatter/features/contacts/data/datasources/contacts_remote_datasource.dart';
import 'package:chatter/features/contacts/domain/entities/contact_entities.dart';
import 'package:chatter/features/contacts/domain/repositories/contacts_repository.dart';

class ContactRepositoryImpl implements ContactsRepository{
  final ContactsRemoteDatasource contactsRemoteDatasource;

  ContactRepositoryImpl({required this.contactsRemoteDatasource});

  @override
  Future<void> addContact(String email) async {
    await contactsRemoteDatasource.addContact(email);
  }

  @override
  Future<List<ContactEntity>> fetchContacts() async {
    return await contactsRemoteDatasource.fetchContacts();
  }
}