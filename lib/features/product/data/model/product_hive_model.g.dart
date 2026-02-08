// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductHiveModelAdapter extends TypeAdapter<ProductHiveModel> {
  @override
  final int typeId = 1;

  @override
  ProductHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductHiveModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      nutritionalInfo: fields[2] as String,
      category: fields[3] as String,
      description: fields[4] as String,
      price: fields[5] as double,
      image: fields[6] as String,
      inStock: fields[7] as int,
      images: (fields[8] as List).cast<String>(),
      manufacturer: fields[9] as String?,
      manufactureDateIso: fields[10] as String?,
      expireDateIso: fields[11] as String?,
      quantity: fields[12] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.nutritionalInfo)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.image)
      ..writeByte(7)
      ..write(obj.inStock)
      ..writeByte(8)
      ..write(obj.images)
      ..writeByte(9)
      ..write(obj.manufacturer)
      ..writeByte(10)
      ..write(obj.manufactureDateIso)
      ..writeByte(11)
      ..write(obj.expireDateIso)
      ..writeByte(12)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
