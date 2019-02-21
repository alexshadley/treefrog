import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:leapfrog/config.dart';
import 'package:leapfrog/sign_in.dart';
import 'package:leapfrog/views/sign_in_page.dart';

class MockConfig extends Mock implements Config {}
class MockSignIn extends Mock implements SignIn {}

class _WidgetTypeFinder extends MatchFinder {
  _WidgetTypeFinder(this.widgetType, { bool skipOffstage = true }) : super(skipOffstage: skipOffstage);

  final Type widgetType;

  @override
  String get description => 'type "$widgetType"';

  @override
  bool matches(Element candidate) {
    return candidate.widget.runtimeType == widgetType;
  }
}

void main() {
  var googleClicks = 0, facebookClicks = 0, emailSignInClicks = 0, emailSignUpClicks = 0;
  var config;
  var signIn;

  void googleClickCounter() => googleClicks++;
  void facebookClickCounter() => facebookClicks++;
  void emailSignInClickCounter() => emailSignInClicks++;
  void emailSignUpClickCounter() => emailSignUpClicks++;

  setUp(() {
    config = new MockConfig();
    when(config.ready).thenReturn(false);
    when(config.init()).thenAnswer((_) async => {});
    when(config.getValue('app_name')).thenReturn('Leapfrog');
    when(config.getValue('primary_color')).thenReturn('FF55efc4');
    when(config.getValue('form_submit_margin')).thenReturn(20.0);
    when(config.getValue('form_button_background')).thenReturn('FFFFFFFF');

    signIn = new MockSignIn();
    when(signIn.checkCache()).thenAnswer((_) async => '');
  });

  Future<void> createPage(WidgetTester tester, {bool configInitialized: true}) async {
    when(config.ready).thenReturn(configInitialized);

    await tester.pumpWidget(new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home: new SignInPage(
          config,
          signIn,
          googleSignInFunc: googleClickCounter,
          facebookSignInFunc: facebookClickCounter,
          emailSignInFunc: emailSignInClickCounter,
          emailSignUpFunc: emailSignUpClickCounter
        ))
    ));
  }

  testWidgets('should initalize config if necessary', (WidgetTester tester) async {
    await createPage(tester, configInitialized: false);

    verify(config.init()).called(1);
  });

  testWidgets('Can click on Google Sign In Button', (WidgetTester tester) async {
    await createPage(tester);

    await tester.tap(_WidgetTypeFinder(MaterialButton, skipOffstage: false).first);
    expect(googleClicks, equals(1));
  });

  testWidgets('Can click on Facebook Sign In Button', (WidgetTester tester) async {
    await createPage(tester);

    await tester.tap(_WidgetTypeFinder(MaterialButton, skipOffstage: false).at(1));
    expect(facebookClicks, equals(1));
  });

  testWidgets('Can click on Email Sign In Button', (WidgetTester tester) async {
    await createPage(tester);

    await tester.tap(_WidgetTypeFinder(MaterialButton, skipOffstage: false).at(2));
    expect(emailSignInClicks, equals(1));
  });

  testWidgets('Can click on Facebook Sign Up Button', (WidgetTester tester) async {
    await createPage(tester);

    await tester.tap(_WidgetTypeFinder(RaisedButton, skipOffstage: false));
    expect(emailSignUpClicks, equals(1));
  });
}