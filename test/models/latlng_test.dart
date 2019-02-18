import 'package:test/test.dart';

import 'package:leapfrog/models.dart';

void main() {
  var testLatLng;
  final testLatitude = 39.0725;
  final testLongitude = -93.7172;

  setUp(() {
    testLatLng = new LatLng(testLatitude, testLongitude);
  });

  group('operator==', () {
    test('Objecs with all fields equal should be considered equal', () {
      var equalLatLng = new LatLng(testLatitude, testLongitude);

      expect(testLatLng, equals(equalLatLng));
    });

    test('Objects with differing latitude should be considered not equal', () {
      var differentLatLng = new LatLng(5.0, testLongitude);

      expect(testLatLng, isNot(equals(differentLatLng)));
    });

    test('Objects with differing longitude should be considered not equal', () {
      var differentLatLng = new LatLng(testLatitude, 4.0);

      expect(testLatLng, isNot(equals(differentLatLng)));
    });
  });

  group('hashCode', () {
    test('Hash code should be equal for equal objects', () {
      var equalLatLng = new LatLng(testLatitude, testLongitude);

      expect(testLatLng.hashCode, equals(equalLatLng.hashCode));
    });

    test('Hash code should be different for objects with different latitude', () {
      var differentLatLng = new LatLng(5.0, testLongitude);

      expect(testLatLng.hashCode, isNot(equals(differentLatLng.hashCode)));
    });

    test('Hash code should be different for objects with different longitude', () {
      var differentLatLng = new LatLng(testLatitude, 4.0);

      expect(testLatLng.hashCode, isNot(equals(differentLatLng.hashCode)));
    });
  });

  group('serialization', () {
    var json;

    setUp(() {
      json = {
        'latitude': testLatitude,
        'longitude': testLongitude
      };
    });

    test('Should serialize to JSON', () {
      expect(testLatLng.toJson(), equals(json));
    });

    test('Should deserialize from JSON', () {
      expect(LatLng.fromJson(json), equals(testLatLng));
    });
  });
}