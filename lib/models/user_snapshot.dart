import 'dart:convert';
import 'dart:math' as math;

import 'package:json_annotation/json_annotation.dart';

part 'user_snapshot.g.dart';

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

  /// Compares two [UserSnapshot]s for equality. Two [UserSnapshot]s are considered equal
  /// if and only if their email, last transfer ID, and leapfrog ID are equal.
  bool operator==(dynamic other) {
    if (!(other is UserSnapshot))
      return false;

    return email == other.email && lastTransfer == other.lastTransfer && leapfrogId == other.leapfrogId;
  }

  /// Computes a hash of this [UserSnapshot]. This is done by converting the email, last transfer ID,
  /// and leapfrog ID to bytes and summing all values.
  int get hashCode {
    var emailBytes = utf8.encode(email);
    var lastTransferBytes = utf8.encode(lastTransfer);
    var leapfrogIdBytes = utf8.encode(leapfrogId);

    var hash = 0;

    for (var i = 0; i < leapfrogIdBytes.length; i++) {
      hash += leapfrogIdBytes[i] * math.pow(2, i);

      if (i < emailBytes.length)
        hash += emailBytes[i] * math.pow(2, i);
      if (i < lastTransferBytes.length)
        hash += lastTransferBytes[i] * math.pow(2, i);
    }

    return hash;
  }

  factory UserSnapshot.fromJson(Map<String, dynamic> json) => _$UserSnapshotFromJson(json);
  Map<String, dynamic> toJson() => _$UserSnapshotToJson(this);
}