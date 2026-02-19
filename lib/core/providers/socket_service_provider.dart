import 'package:click_shop/core/services/connectivity/socket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final s = SocketService();
  ref.onDispose(() => s.dispose());
  return s;
});

final socketNotificationStreamProvider = StreamProvider<dynamic>((ref) {
  return ref.watch(socketServiceProvider).notificationStream;
});
