// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transfer _$TransferFromJson(Map<String, dynamic> json) {
  return Transfer(
      UserSnapshot.fromJson(json['completing'] as Map<String, dynamic>),
      json['id'] as String,
      UserSnapshot.fromJson(json['initiating'] as Map<String, dynamic>),
      LatLng.fromJson(json['location'] as Map<String, dynamic>));
}

Map<String, dynamic> _$TransferToJson(Transfer instance) => <String, dynamic>{
      'completing': instance.completingUser.toJson(),
      'id': instance.id,
      'initiating': instance.initiatingUser.toJson(),
      'location': instance.location.toJson()
    };
