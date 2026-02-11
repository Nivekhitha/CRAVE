// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_snapshot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionSnapshotAdapter extends TypeAdapter<NutritionSnapshot> {
  @override
  final int typeId = 3;

  @override
  NutritionSnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionSnapshot(
      date: fields[0] as DateTime,
      macros: (fields[1] as Map).cast<String, double>(),
      vitamins: (fields[2] as Map).cast<String, double>(),
      minerals: (fields[3] as Map).cast<String, double>(),
      goals: (fields[4] as Map).cast<String, double>(),
      progress: (fields[5] as Map).cast<String, double>(),
      nutritionScore: fields[6] as int,
      insights: (fields[7] as List).cast<String>(),
      waterGlasses: fields[8] as int,
      averageGlycemicIndex: fields[9] as double,
      lastUpdated: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionSnapshot obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.macros)
      ..writeByte(2)
      ..write(obj.vitamins)
      ..writeByte(3)
      ..write(obj.minerals)
      ..writeByte(4)
      ..write(obj.goals)
      ..writeByte(5)
      ..write(obj.progress)
      ..writeByte(6)
      ..write(obj.nutritionScore)
      ..writeByte(7)
      ..write(obj.insights)
      ..writeByte(8)
      ..write(obj.waterGlasses)
      ..writeByte(9)
      ..write(obj.averageGlycemicIndex)
      ..writeByte(10)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionSnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
