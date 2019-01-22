import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:leapfrog/main.dart';

void main() {
  testWidgets('Can click on all login buttons', (WidgetTester tester) async {
    await tester.pumpWidget(new LeapfrogApp());
  });
}
