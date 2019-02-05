import 'package:json_annotation/json_annotation.dart';

import 'package:leapfrog/models/sign_in_method.dart';

part 'user.g.dart';

/// Represents a user in the backend database.
class User {
  final email;
  final displayName;
  final passwordHash;
  final leapfrogId;
  final method;

  User(String email, String leapfrogId, String displayName, String passwordHash, String method) :
    this.email = email,
    this.displayName = displayName,
    this.passwordHash = passwordHash,
    this.leapfrogId = leapfrogId,
    this.method = SignInMethod.values.firstWhere((val) => name(val) == method.toUpperCase());
}

/// A snapshot of a user at a point in time.
@JsonSerializable(nullable: false)
class UserSnapshot {
  @JsonKey(name: 'email')
  final email;

  @JsonKey(name: 'last_transfer')
  final lastTransfer;

  @JsonKey(name: 'leapfrog')
  final leapfrogId;

  UserSnapshot(String email, String lastTransfer, String leapfrogId) :
    this.email = email,
    this.lastTransfer = lastTransfer,
    this.leapfrogId = leapfrogId;

  factory UserSnapshot.fromJson(Map<String, dynamic> json) => _$UserSnapshotFromJson(json);
  Map<String, dynamic> toJson() => _$UserSnapshotToJson(this);
}