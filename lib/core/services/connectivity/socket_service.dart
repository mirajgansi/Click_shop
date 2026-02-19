import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;

  final StreamController<dynamic> _notificationCtrl =
      StreamController<dynamic>.broadcast();

  Stream<dynamic> get notificationStream => _notificationCtrl.stream;

  void connect(String userId) {
    _socket = IO.io(
      "http://192.168.1.105:5050",
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling']) // safer
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print("✅ SOCKET CONNECTED: ${_socket!.id}");
      _socket!.emit("join", userId);
    });

    _socket!.onConnectError((err) {
      print("❌ CONNECT ERROR: $err");
    });

    _socket!.onDisconnect((_) {
      print("⚠️ SOCKET DISCONNECTED");
    });

    _socket!.on("notification", (data) {
      print("🔔 NOTIFICATION: $data");
      _notificationCtrl.add(data); // ✅ stream event
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose(); // socket_io_client supports dispose
    _socket = null;
  }

  void dispose() {
    disconnect();
    _notificationCtrl.close(); // ✅ important
  }
}
