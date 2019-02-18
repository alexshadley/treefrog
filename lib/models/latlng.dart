import 'package:json_annotation/json_annotation.dart';

part 'latlng.g.dart';

/// A latitude, longitude point.
@JsonSerializable(nullable: false)
class LatLng {
  @JsonKey(name: 'latitude')
  final latitude;

  @JsonKey(name: 'longitude')
  final longitude;

  LatLng(double latitude, double longitude) :
    this.latitude = latitude,
    this.longitude = longitude;

  bool operator==(dynamic other) {
    if (!(other is LatLng))
      return false;

    return latitude == other.latitude && longitude == other.longitude;
  }

  int get hashCode {
    return (latitude * 10000).floor() + (longitude * 10000).floor();
  }

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
  Map<String, dynamic> toJson() => _$LatLngToJson(this);
}