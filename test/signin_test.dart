import 'dart:convert' as convert;
import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:leapfrog/api.dart';
import 'package:leapfrog/config.dart';
import 'package:leapfrog/models/models.dart';
import 'package:leapfrog/file_factory.dart';
import 'package:leapfrog/sign_in.dart';
import 'package:leapfrog/util.dart' as util;

class MockApi extends Mock implements Api {}
class MockConfig extends Mock implements Config {}
class MockFileFactory extends Mock implements FileFactory {
  final _file;

  MockFileFactory(File file) :
    _file = file;

  Future<File> getFile(String path) async {
    return _file;
  }
}
class MockFile extends Mock implements File {
  var count = 0;
  var writeContents;
  final _email;

  MockFile(String email) :
    _email = email;

  Future<String> readAsString({convert.Encoding encoding: convert.utf8}) async {
    var result = {
      'time': new DateTime.now().millisecondsSinceEpoch - 10000,
      'email': _email
    };

    return convert.jsonEncode(result);
  }

  Future<File> writeAsString(String s, {FileMode mode, convert.Encoding encoding: convert.utf8, bool flush: true}) async {
    count += 1;
    writeContents = s;
    return this;
  }
}

void main() {
  final testEmail = 'the@examiner.com';
  final testPassword = 'this password is very secure';

  var _signIn;
  var _config;
  var _file;
  var _fileFactory;
  var _api;

  setUp(() {
    _config = new MockConfig();
    when(_config.ready).thenReturn(false);
    when(_config.getValue('api_url')).thenReturn('http://fake.url');

    _file = new MockFile(testEmail);
    when(_file.exists()).thenAnswer((_) async => true);
    when(_file.create()).thenAnswer((_) async => _file);

    _fileFactory = new MockFileFactory(_file);

    _api = new MockApi();

    _signIn = new SignIn(_api, _config, _fileFactory);
  });

  group('checkCache', () {
    test('Should call config.init if not ready', () async {
      when(_config.getValue('login_timeout')).thenReturn('1000');

      await _signIn.checkCache();
      verify(_config.ready).called(1);
    });

    test('Should return email if login is cached', () async {
      when(_config.getValue('login_timeout')).thenReturn('20000');

      var email = await _signIn.checkCache();
      expect(email, equals(testEmail));
    });

    test('Should return empty email if login is not cached', () async {
      when(_config.getValue('login_timeout')).thenReturn('500');

      var email = await _signIn.checkCache();
      expect(email, equals(''));
    });

    test('Should return empty email if cache file does not exist', () async {
      when(_file.exists()).thenAnswer((_) async => false);

      var email = await _signIn.checkCache();
      expect(email, equals(''));
    });

    test('Should update login cache if existing cache is valid', () async {
      when(_config.getValue('login_timeout')).thenReturn('20000');

      await _signIn.checkCache();
      expect(_file.count, equals(1));

      var actual = convert.jsonDecode(_file.writeContents);

      expect(actual['email'], equals(testEmail));
      expect(new DateTime.now().millisecondsSinceEpoch - actual['time'], lessThan(20));
    });
  });

  group('emailSignIn', () {
    setUp(() {
      when(_config.getValue('login_timeout')).thenReturn('20000');
    });

    test('Should sign in if email, password, and method are correct', () async {
      when(_api.getUser(testEmail)).thenAnswer((_) async => new User(testEmail, 'id', 'display name', util.hash(testPassword), 'Email'));
      var result = await _signIn.emailSignIn(testEmail, testPassword);

      expect(result.resultType, equals(SignInResultType.SIGNED_IN));
      expect(result.email, equals(testEmail));
      expect(_file.count, equals(1));
    });

    test('Should return incorrect method if method is incorrect', () async {
      when(_api.getUser(testEmail)).thenAnswer((_) async => new User(testEmail, 'id', 'display name', util.hash(testPassword), 'Google'));

      var result = await _signIn.emailSignIn(testEmail, testPassword);

      expect(result.resultType, equals(SignInResultType.INCORRECT_METHOD));
      expect(_file.count, equals(0));
    });

    test('Should return incorrect password if password is incorrect', () async {
      when(_api.getUser(testEmail)).thenAnswer((_) async => new User(testEmail, 'id', 'display name', util.hash('a fake password'), 'Email'));

      var result = await _signIn.emailSignIn(testEmail, testPassword);

      expect(result.resultType, equals(SignInResultType.INCORRECT_PASSWORD));
      expect(_file.count, equals(0));
    });

    test('Should not try to register user if nonexistent', () async {
      when(_api.getUser(testEmail)).thenAnswer((_) async => null);

      var result = await _signIn.emailSignIn(testEmail, testPassword);

      expect(result.resultType, equals(SignInResultType.NONEXISTENT_USER));
      verifyNever(_api.registerUser(any));
      expect(_file.count, equals(0));
    });
  });

  group('emailSignUp', () {
    setUp(() {
      when(_config.getValue('login_timeout')).thenReturn('20000');
    });

    test('Should return created if creation is successful', () async {
      final displayName = 'display name';
      when(_api.registerUser(testEmail, displayName, 'Email', testPassword)).thenAnswer((_) async => SignInResultType.CREATED);
      var result = await _signIn.emailSignUp(testEmail, displayName, testPassword);

      verify(_api.registerUser(testEmail, displayName, 'Email', testPassword)).called(1);
      expect(result.resultType, equals(SignInResultType.CREATED));
      expect(result.email, equals(testEmail));
      expect(_file.count, equals(1));
    });
  });
}