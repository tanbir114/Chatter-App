import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  late IO.Socket _socket;
  final _storage = FlutterSecureStorage();

  SocketService._internal() {
    initSocket();
  }

  Future<void> initSocket() async {
    String token = await _storage.read(key: 'Token') ?? '';
    print(token);
    _socket = IO.io(
      'http://192.168.0.245:5000',
      IO.OptionBuilder()
          .setTransports(
              ['websocket']) // Ensure the transport is set to 'websocket'
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'}) // Pass the token
          .build(),
    );

    print("Socket connecting.......................");
    _socket.connect();
    print("Socket maybe connectedddddddd");

    _socket.onConnect((_) {
      print('Socket connected: ${_socket.id}');
    });

    _socket.onDisconnect((_) {
      print('Socket disconnected: ${_socket.id}');
    });
  }

  IO.Socket get socket => _socket;
}
