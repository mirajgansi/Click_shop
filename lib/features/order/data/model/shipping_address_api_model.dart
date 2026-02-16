import 'package:click_shop/features/driver/domain/entities/shipping_address.dart';

class ShippingAddressApiModel {
  final String? userName;
  final String? phone;
  final String? address1;
  final String? address2;
  final String? city;
  final String? zip;

  const ShippingAddressApiModel({
    this.userName,
    this.phone,
    this.address1,
    this.address2,
    this.city,
    this.zip,
  });

  /// ---------- FROM JSON ----------
  /// ---------- FROM JSON (SAFE) ----------
  factory ShippingAddressApiModel.fromJson(dynamic raw) {
    if (raw == null) return const ShippingAddressApiModel();

    // supports Map<dynamic, dynamic> and Map<String, dynamic>
    final Map json = raw as Map;

    return ShippingAddressApiModel(
      userName: json['userName']?.toString(),
      phone: json['phone']?.toString(),
      address1: json['address1']?.toString(),
      address2: json['address2']?.toString(),
      city: json['city']?.toString(),
      zip: json['zip']?.toString(),
    );
  }

  /// ---------- TO JSON ----------
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'phone': phone,
      'address1': address1,
      'address2': address2,
      'city': city,
      'zip': zip,
    };
  }

  /// ---------- ENTITY MAPPING ----------
  ShippingAddressEntity toEntity() {
    return ShippingAddressEntity(
      userName: userName,
      phone: phone,
      address1: address1,
      address2: address2,
      city: city,
      zip: zip,
    );
  }

  factory ShippingAddressApiModel.fromEntity(ShippingAddressEntity entity) {
    return ShippingAddressApiModel(
      userName: entity.userName,
      phone: entity.phone,
      address1: entity.address1,
      address2: entity.address2,
      city: entity.city,
      zip: entity.zip,
    );
  }
}
