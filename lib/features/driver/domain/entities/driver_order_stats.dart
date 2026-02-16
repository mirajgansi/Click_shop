// lib/features/driver/domain/entities/driver_order_stats.dart
class DriverOrderStats {
  final int totalAssigned;
  final int totalDelivered;

  const DriverOrderStats({
    required this.totalAssigned,
    required this.totalDelivered,
  });
}
