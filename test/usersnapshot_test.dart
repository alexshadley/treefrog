import 'package:test/test.dart';

import 'package:leapfrog/models/models.dart';

void main() {
  final testEmail = 'the@examiner.com';
  final testTransferId = 'thisisfakenews';
  final testLeapfrogId = 'thisismorefakenews';

  group('operator==', () {
    var snapshot1;

    setUp(() {
      snapshot1 = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);
    });

    test('Objects with all fields equal should be considered equal', () {
      var snapshot2 = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);

      expect(snapshot1, equals(snapshot2));
    });

    test('Objects with differing emails should be considered not equal', () {
      var snapshot2 = new UserSnapshot('not@the.same', testTransferId, testLeapfrogId);

      expect(snapshot1, isNot(equals(snapshot2)));
    });

    test('Objects with differing last transfer IDs should be considered not equal', () {
      var snapshot2 = new UserSnapshot(testEmail, 'different', testLeapfrogId);

      expect(snapshot1, isNot(equals(snapshot2)));
    });

    test('Objects with differing leapfrog IDs should be considered not equal', () {
      var snapshot2 = new UserSnapshot(testEmail, testTransferId, 'different');

      expect(snapshot1, isNot(equals(snapshot2)));
    });

    test('Objects with differing types should be considered not equal', () {
      expect(snapshot1, isNot(equals(5)));
    });
  });
  
  group('hashCode', () {
    test('Hash code should be equal for equal objects', () {
      var snapshot1 = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);
      var snapshot2 = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);

      expect(snapshot1.hashCode, equals(snapshot2.hashCode));
    });

    test('Hash code should be different for objects with different emails', () {
      var snapshot1 = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);
      var snapshot2 = new UserSnapshot('not@the.same', testTransferId, testLeapfrogId);

      expect(snapshot1.hashCode, isNot(equals(snapshot2.hashCode)));
    });

    test('Hash code should be different for objects with different transfer IDs', () {
      var snapshot1 = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);
      var snapshot2 = new UserSnapshot(testEmail, 'different', testLeapfrogId);

      expect(snapshot1.hashCode, isNot(equals(snapshot2.hashCode)));
    });

    test('Hash code should be different for objects with different leapfrog IDs', () {
      var snapshot1 = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);
      var snapshot2 = new UserSnapshot(testEmail, testTransferId, 'different');

      expect(snapshot1.hashCode, isNot(equals(snapshot2.hashCode)));
    });
  });

  group('serialization', () {
    var snapshot;
    var json;

    setUp(() {
      snapshot = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);
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