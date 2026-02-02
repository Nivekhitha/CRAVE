// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealPlanAdapter extends TypeAdapter<MealPlan> {
  @override
  final int typeId = 4;

  @override
  MealPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealPlan(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      meals: (fields[2] as List).cast<PlannedMeal>(),
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime?,
      notes: fields[5] as String?,
      isCompleted: fields[6] as bool,
      shoppingList: (fields[7] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MealPlan obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.meals)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.shoppingList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlannedMealAdapter extends TypeAdapter<PlannedMeal> {
  @override
  final int typeId = 5;

  @override
  PlannedMeal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlannedMeal(
      id: fields[0] as String,
      mealType: fields[1] as MealType,
      recipe: fields[2] as Recipe?,
      customMealName: fields[3] as String?,
      scheduledTime: fields[4] as DateTime?,
      isCooked: fields[5] as bool,
      notes: fields[6] as String?,
      servings: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PlannedMeal obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mealType)
      ..writeByte(2)
      ..write(obj.recipe)
      ..writeByte(3)
      ..write(obj.customMealName)
      ..writeByte(4)
      ..write(obj.scheduledTime)
      ..writeByte(5)
      ..write(obj.isCooked)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.servings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedMealAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MealTypeAdapter extends TypeAdapter<MealType> {
  @override
  final int typeId = 6;

  @override
  MealType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MealType.breakfast;
      case 1:
        return MealType.lunch;
      case 2:
        return MealType.dinner;
      case 3:
        return MealType.snack;
      default:
        return MealType.breakfast;
    }
  }

  @override
  void write(BinaryWriter writer, MealType obj) {
    switch (obj) {
      case MealType.breakfast:
        writer.writeByte(0);
        break;
      case MealType.lunch:
        writer.writeByte(1);
        break;
      case MealType.dinner:
        writer.writeByte(2);
        break;
      case MealType.snack:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
