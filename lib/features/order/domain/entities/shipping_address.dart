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

  @override
  List<Object?> get props => [userName, phone, address1, address2, city, zip];
}
