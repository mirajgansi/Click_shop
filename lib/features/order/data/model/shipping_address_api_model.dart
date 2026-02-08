import 'package:click_shop/features/order/domain/entities/shipping_address.dart';

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
  factory ShippingAddressApiModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressApiModel(
      userName: json['userName'] as String?,
      phone: json['phone'] as String?,
      address1: json['address1'] as String?,
      address2: json['address2'] as String?,
      city: json['city'] as String?,
      zip: json['zip'] as String?,
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
