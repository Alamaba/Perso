// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_credit_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtCreditItemAdapter extends TypeAdapter<DebtCreditItem> {
  @override
  final int typeId = 0;

  @override
  DebtCreditItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DebtCreditItem(
      id: fields[0] as String,
      personName: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      isRepaid: fields[4] as bool,
      isDebt: fields[5] as bool,
      history: (fields[6] as List).cast<HistoryEntry>(),
      reminderDate: fields[7] as DateTime?,
      notes: fields[8] as String?,
      userId: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DebtCreditItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.isRepaid)
      ..writeByte(5)
      ..write(obj.isDebt)
      ..writeByte(6)
      ..write(obj.history)
      ..writeByte(7)
      ..write(obj.reminderDate)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtCreditItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HistoryEntryAdapter extends TypeAdapter<HistoryEntry> {
  @override
  final int typeId = 1;

  @override
  HistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryEntry(
      date: fields[0] as DateTime,
      action: fields[1] as String,
      oldValue: fields[2] as String?,
      newValue: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.oldValue)
      ..writeByte(3)
      ..write(obj.newValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
