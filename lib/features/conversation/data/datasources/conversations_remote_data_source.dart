import 'dart:convert';

import 'package:chatter/features/conversation/data/models/conversation_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ConversationsRemoteDataSource {
  final String baseUrl = 'http://192.168.0.245:5000';
  final _storage = FlutterSecureStorage();

  Future<List<ConversationModel>> fetchConversations() async {
    String token = await _storage.read(key: 'Token') ?? '';
    print("Token: " + token);
    final response =
        await http.get(Uri.parse('$baseUrl/conversations'), headers: {
      'Authorization': 'Bearer $token',
    });
    print(response.statusCode);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      print("Coversations: ");
      print(data);
      return data.map((json) => ConversationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch conversations');
    }
  }
}
