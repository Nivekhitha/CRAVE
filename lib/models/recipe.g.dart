// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 1;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as String,
      title: fields[1] as String,
      source: fields[2] as String,
      sourceUrl: fields[3] as String?,
      ingredients: (fields[4] as List).cast<String>(),
      imageUrl: fields[5] as String?,
      prepTime: fields[6] as int?,
      cookTime: fields[7] as int?,
      servings: fields[8] as int?,
      instructions: fields[9] as String?,
      isPremium: fields[10] as bool,
      createdAt: fields[11] as DateTime?,
      lastCookedAt: fields[12] as DateTime?,
      cookCount: fields[13] as int,
      tags: (fields[14] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.source)
      ..writeByte(3)
      ..write(obj.sourceUrl)
      ..writeByte(4)
      ..write(obj.ingredients)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.prepTime)
      ..writeByte(7)
      ..write(obj.cookTime)
      ..writeByte(8)
      ..write(obj.servings)
      ..writeByte(9)
      ..write(obj.instructions)
      ..writeByte(10)
      ..write(obj.isPremium)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.lastCookedAt)
      ..writeByte(13)
      ..write(obj.cookCount)
      ..writeByte(14)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
