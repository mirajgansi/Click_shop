import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:click_shop/features/driver/domain/entities/shipping_address.dart';
import 'package:hive/hive.dart';

part 'shipping_address_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.shippingAddressTypeId)
class ShippingAddressHiveModel {
  @HiveField(0)
  final String? userName;

  @HiveField(1)
  final String? phone;

  @HiveField(2)
  final String? address1;

  @HiveField(3)
  final String? address2;

  @HiveField(4)
  final String? city;

  @HiveField(5)
  final String? zip;

  const ShippingAddressHiveModel({
    this.userName,
    this.phone,
    this.address1,
    this.address2,
    this.city,
    this.zip,
  });

  factory ShippingAddressHiveModel.fromEntity(ShippingAddressEntity e) {
    return ShippingAddressHiveModel(
      userName: e.userName,
      phone: e.phone,
      address1: e.address1,
      address2: e.address2,
      city: e.city,
      zip: e.zip,
    );
  }

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
}
