// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recognition_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecognitionHistoryAdapter extends TypeAdapter<RecognitionHistory> {
  @override
  final int typeId = 0;

  @override
  RecognitionHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecognitionHistory(
      text: fields[0] as String,
      timestamp: fields[1] as DateTime,
      languageCode: fields[2] as String,
      languageName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecognitionHistory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.languageCode)
      ..writeByte(3)
      ..write(obj.languageName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecognitionHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
