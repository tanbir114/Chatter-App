import 'dart:convert';

import 'package:chatter/features/contacts/data/model/contact_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ContactsRemoteDatasource {
  final String baseUrl = "http://192.168.0.245:5000";
  final _storage = FlutterSecureStorage();

  Future<List<ContactsModel>> fetchContacts() async {
    final token = await _storage.read(key: "Token") ?? '';
    final response = await http.get(Uri.parse('$baseUrl/contacts'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => ContactsModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch Contacts");
    }
  }

  Future<void> addContact(String email) async {
    final token = await _storage.read(key: "Token") ?? '';
    final response = await http.post(Uri.parse('$baseUrl/contacts'),
        body: jsonEncode({'contactEmail': email}),
        headers: {'Authorization': 'Bearer $token'});
    
    if(response.statusCode != 201) {
      throw Exception('Failed to add contact');
    }
  }
}
