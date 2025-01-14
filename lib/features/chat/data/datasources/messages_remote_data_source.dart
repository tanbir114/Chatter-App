import 'dart:convert';

import 'package:chatter/features/chat/data/model/message_model.dart';
import 'package:chatter/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MessagesRemoteDataSource {
  final String baseUrl = "http://192.168.0.245:5000";
  final _storage = FlutterSecureStorage();

  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    String token = await _storage.read(key: 'Token') ?? '';
    final response = await http.get(
        Uri.parse('$baseUrl/messages/$conversationId'),
        headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      print(data);
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch messages');
    }
  }
}
