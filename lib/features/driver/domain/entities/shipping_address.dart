import 'package:equatable/equatable.dart';

class ShippingAddressEntity extends Equatable {
  final String? userName;
  final String? phone;
  final String? address1;
  final String? address2;
  final String? city;
  final String? zip;

  const ShippingAddressEntity({
    this.userName,
    this.phone,
    this.address1,
    this.address2,
    this.city,
    this.zip,
  });

  factory ShippingAddressEntity.fromJson(Map<String, dynamic> json) {
    return ShippingAddressEntity(
      userName: json['userName'] ?? json['name'],
      phone: json['phone'],
      address1: json['address1'] ?? json['address'],
      address2: json['address2'],
      city: json['city'],
      zip: json['zip'],
    );
  }

  @override
  List<Object?> get props => [userName, phone, address1, address2, city, zip];
}
