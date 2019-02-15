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

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
  Map<String, dynamic> toJson() => _$LatLngToJson(this);
}