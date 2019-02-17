import 'package:test/test.dart';

import 'package:leapfrog/models/models.dart';

void main() {
  final testEmail = 'the@examiner.com';
  final testTransferId = 'thisisfakenews';
  final testLeapfrogId = 'thisismorefakenews';

  var snapshot;

  setUp(() {
    snapshot = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);
  });

  group('operator==', () {
    test('Objects with all fields equal should be considered equal', () {
      var equalSnapshot = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);

      expect(snapshot, equals(equalSnapshot));
    });

    test('Objects with differing emails should be considered not equal', () {
      var differentSnapshot = new UserSnapshot('not@the.same', testTransferId, testLeapfrogId);

      expect(snapshot, isNot(equals(differentSnapshot)));
    });

    test('Objects with differing last transfer IDs should be considered not equal', () {
      var differentSnapshot = new UserSnapshot(testEmail, 'different', testLeapfrogId);

      expect(snapshot, isNot(equals(differentSnapshot)));
    });

    test('Objects with differing leapfrog IDs should be considered not equal', () {
      var differentSnapshot = new UserSnapshot(testEmail, testTransferId, 'different');

      expect(snapshot, isNot(equals(differentSnapshot)));
    });

    test('Objects with differing types should be considered not equal', () {
      expect(snapshot, isNot(equals(5)));
    });
  });
  
  group('hashCode', () {
    test('Hash code should be equal for equal objects', () {
      var equalSnapshot = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);

      expect(snapshot.hashCode, equals(equalSnapshot.hashCode));
    });

    test('Hash code should be different for objects with different emails', () {
      var differentSnapshot = new UserSnapshot('not@the.same', testTransferId, testLeapfrogId);

      expect(snapshot.hashCode, isNot(equals(differentSnapshot.hashCode)));
    });

    test('Hash code should be different for objects with different transfer IDs', () {
      var differentSnapshot = new UserSnapshot(testEmail, 'different', testLeapfrogId);

      expect(snapshot.hashCode, isNot(equals(differentSnapshot.hashCode)));
    });

    test('Hash code should be different for objects with different leapfrog IDs', () {
      var differentSnapshot = new UserSnapshot(testEmail, testTransferId, 'different');

      expect(snapshot.hashCode, isNot(equals(differentSnapshot.hashCode)));
    });
  });

  group('serialization', () {
    var json;

    setUp(() {
      json = {
        'email': testEmail,
        'last_transfer': testTransferId,
        'leapfrog': testLeapfrogId
      };
    });

    test('Should serialize to JSON', () {
      expect(snapshot.toJson(), equals(json));
    });

    test('Should deserialize from JSON', () {
      expect(UserSnapshot.fromJson(json), equals(snapshot));
    });
  });
}