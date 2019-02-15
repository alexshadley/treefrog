// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSnapshot _$UserSnapshotFromJson(Map<String, dynamic> json) {
  return UserSnapshot(json['email'] as String, json['last_transfer'] as String,
      json['leapfrog'] as String);
}

Map<String, dynamic> _$UserSnapshotToJson(UserSnapshot instance) =>
    <String, dynamic>{
      'email': instance.email,
      'last_transfer': instance.lastTransfer,
      'leapfrog': instance.leapfrogId
    };
