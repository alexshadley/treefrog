part of 'models.dart';

/// A transfer stored in the database.
@JsonSerializable(nullable: false)
class Transfer {
  @JsonKey(name: 'completing')
  final completingUser;

  @JsonKey(name: 'id')
  final id;

  @JsonKey(name: 'initiating')
  final initiatingUser;

  @JsonKey(name: 'location')
  final location;

  Transfer(UserSnapshot completingUser, String id, UserSnapshot initiatingUser, LatLng location) :
    this.completingUser = completingUser,
    this.id = id,
    this.initiatingUser = initiatingUser,
    this.location = location;

  factory Transfer.fromJson(Map<String, dynamic> json) => _$TransferFromJson(json);
  Map<String, dynamic> toJson() => _$TransferToJson(this);

  bool operator==(dynamic other){
    if (!(other is Transfer))
      return false;

    return completingUser == other.completingUser && id == other.id &&
        initiatingUser == other.initiatingUser && location == other.location;
  }

  int get hashCode {
    
  }
}