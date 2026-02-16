// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_address_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShippingAddressHiveModelAdapter
    extends TypeAdapter<ShippingAddressHiveModel> {
  @override
  final int typeId = 32;

  @override
  ShippingAddressHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShippingAddressHiveModel(
      userName: fields[0] as String?,
      phone: fields[1] as String?,
      address1: fields[2] as String?,
      address2: fields[3] as String?,
      city: fields[4] as String?,
      zip: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ShippingAddressHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.userName)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.address1)
      ..writeByte(3)
      ..write(obj.address2)
      ..writeByte(4)
      ..write(obj.city)
      ..writeByte(5)
      ..write(obj.zip);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShippingAddressHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
