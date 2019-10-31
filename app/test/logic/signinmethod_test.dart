import 'package:test/test.dart';

import 'package:leapfrog/models.dart';

void main() {
  group('name', () {
    test('should work for all enum values', () {
      SignInMethod.values.forEach((v) {
        var expected = v.toString().split('.')[1];
        expect(name(v), equals(expected));
      });
    });
  });
}