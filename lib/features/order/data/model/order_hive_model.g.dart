// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderHiveModelAdapter extends TypeAdapter<OrderHiveModel> {
  @override
  final int typeId = 30;

  @override
  OrderHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      items: (fields[2] as List).cast<OrderItemHiveModel>(),
      subtotal: fields[3] as double,
      shippingFee: fields[4] as double,
      total: fields[5] as double,
      status: fields[6] as String,
      paymentStatus: fields[7] as String,
      shippingAddress: fields[8] as ShippingAddressHiveModel?,
      notes: fields[9] as String?,
      driverId: fields[10] as String?,
      driverName: fields[11] as String?,
      createdAt: fields[12] as DateTime?,
      updatedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderHiveModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.subtotal)
      ..writeByte(4)
      ..write(obj.shippingFee)
      ..writeByte(5)
      ..write(obj.total)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.paymentStatus)
      ..writeByte(8)
      ..write(obj.shippingAddress)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.driverId)
      ..writeByte(11)
      ..write(obj.driverName)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
