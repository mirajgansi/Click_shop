enum OrderStatus { pending, paid, shipped, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  static OrderStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'paid':
        return OrderStatus.paid;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending; // safe fallback
    }
  }
}

enum PaymentStatus { unpaid, paid }

extension PaymentStatusX on PaymentStatus {
  static PaymentStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'unpaid':
        return PaymentStatus.unpaid;
      default:
        return PaymentStatus.unpaid; // safe fallback
    }
  }
}
