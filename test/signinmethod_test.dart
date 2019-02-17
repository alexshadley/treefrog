import 'package:test/test.dart';

import 'package:leapfrog/models/models.dart';

void main() {
  group('name', () {
    test('Should work for all enum values', () {
      SignInMethod.values.forEach((v) {
        var expected = v.toString().split('.')[1];
        expect(name(v), equals(expected));
      });
    });
  });
}