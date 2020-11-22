// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DishAdapter extends TypeAdapter<Dish> {
  @override
  final int typeId = 0;

  @override
  Dish read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dish(
      name: fields[0] as String,
      note: fields[1] as String,
    )
      ..categories = (fields[2] as HiveList)?.castHiveList()
      ..tags = (fields[3] as HiveList)?.castHiveList()
      ..deleted = fields[4] as bool;
  }

  @override
  void write(BinaryWriter writer, Dish obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.note)
      ..writeByte(2)
      ..write(obj.categories)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.deleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DishAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
