import 'package:test/test.dart';

import 'package:leapfrog/models/models.dart';

void main() {
  final testEmail = 'the@examiner.com';
  final testTransferId = 'thisisfake';
  final testLeapfrogId = 'thisisalsofake';

  final testUser = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);
  final testUser2 = new UserSnapshot(testEmail, testTransferId, testLeapfrogId);

  final testLatLng = new LatLng(39.0725, -93.7172);
  final testLatLng2 = new LatLng(39.0725, -93.7172);

  var testTransfer;
  var transferJson;

  setUp(() {
    testTransfer = new Transfer(testUser, testTransferId, testUser, testLatLng);

    transferJson = {
      'id': testTransferId,
      'initiating': {
        'email': testEmail,
        'last_transfer': testTransferId,
        'leapfrog': testLeapfrogId
      },
      'completing': {
        'email': testEmail,
        'last_transfer': testTransferId,
        'leapfrog': testLeapfrogId
      },
      'location': {
        'latitude': testLatLng.latitude,
        'longitude': testLatLng.longitude
      }
    };
  });

  group('operator==', () {
    test('Objects with all fields equal should be considered equal', () {
      var equalTransfer = new Transfer(testUser2, testTransferId, testUser2, testLatLng2);

      expect(testTransfer, equals(equalTransfer));
    });

    test('Objects with differing completing users should be considered not equal', () {
      var differentUser = new UserSnapshot('fake@email.com', 'notthesame', 'notthesame');
      var differentTransfer = new Transfer(differentUser, testTransferId, testUser, testLatLng2);

      expect(testTransfer, isNot(equals(differentTransfer)));
    });

    test('Objects with differing IDs should be considered not equal', () {
      var differentTransfer = new Transfer(testUser2, 'notthesame', testUser2, testLatLng2);

      expect(testTransfer, isNot(equals(differentTransfer)));
    });

    test('Objects with differing initiating users should be considered not equal', () {
      var differentUser = new UserSnapshot('fake@email.com', 'notthesame', 'notthesame');
      var differentTransfer = new Transfer(differentUser, testTransferId, differentUser, testLatLng2);

      expect(testTransfer, isNot(equals(differentTransfer)));
    });

    test('Objects with differing locations should be considered not equal', () {
      var differentLatLng = new LatLng(5.0, 4.0);
      var differentTransfer = new Transfer(testUser, testTransferId, testUser, differentLatLng);

      expect(testTransfer, isNot(equals(differentTransfer)));
    });
  });

  group('hashCode', () {
    test('Hash code should be equal for equal objects', () {
      var equalTransfer = new Transfer(testUser2, testTransferId, testUser2, testLatLng2);

      expect(equalTransfer.hashCode, equals(testTransfer.hashCode));
    });

    test('Hash code should be different for objects with different completing users', () {
      var differentUser = new UserSnapshot('fake@email.com', 'notthesame', 'notthesame');
      var differentTransfer = new Transfer(differentUser, testTransferId, testUser, testLatLng2);

      expect(differentTransfer.hashCode, isNot(equals(testTransfer.hashCode)));
    });
  });
}