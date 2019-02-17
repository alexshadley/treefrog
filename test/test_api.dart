import 'dart:convert' as convert;
import 'dart:core';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:leapfrog/api.dart';
import 'package:leapfrog/config.dart';
import 'package:leapfrog/models/confirmation_result.dart';
import 'package:leapfrog/models/sign_in_method.dart';
import 'package:leapfrog/models/sign_in_result.dart';
import 'package:leapfrog/util.dart' as util;

part 'models/mock_config.dart';

var testEmail = 'the@examiner.com';
var testDisplayName = 'The Examiner';
var testLeapfrogId = 'fakenews';
var testMethod = 'GOOGLE';
var testPasswordHash = 'a very secure password';
var testTransferId = 'thisIDwastotallyrandom';
var testPosition = {
  'latitude': 39.0725,
  'longitude': -93.7172
};

var postData;
var testTransfers;
var testLeapfrogs;

void main() {
  var _api;
  var _badRequestApi;
  var _notFoundApi;
  var _config;

  setUp(() {
    _config = new MockConfig();
    when(_config.getValue('api_url')).thenReturn('http://fake.url');
    when(_config.ready).thenReturn(false);

    _api = new Api(new MockClient(requestHandler), _config);
    _badRequestApi = new Api(new MockClient(badRequest), _config);
    _notFoundApi = new Api(new MockClient(notFound), _config);
    postData = null;

    testTransfers = [
      {
        'completing': {
          'email': testEmail,
          'last_transfer': testTransferId,
          'leapfrog': testLeapfrogId
        },
        'id': testTransferId,
        'initiating': {
          'email': testEmail,
          'last_transfer': testTransferId,
          'leapfrog': testLeapfrogId
        },
        'location': testPosition
      },
      {
        'completing': {
          'email': testEmail,
          'last_transfer': testTransferId,
          'leapfrog': testLeapfrogId
        },
        'id': testTransferId,
        'initiating': {
          'email': testEmail,
          'last_transfer': testTransferId,
          'leapfrog': testLeapfrogId
        },
        'location': testPosition
      }
    ];

    testLeapfrogs = [
      'yougetafrog',
      'yougetafrogtoo',
      'everybodygetsafrog'
    ];
  });
  group('getUser', () {
    test('Should initialize config if not ready', () async {
      await _api.getUser('asdf@email.com');
      verify(_config.ready).called(1);
    });

    test('Should return null if email is invalid', () async {
      var result = await _badRequestApi.getUser('asdf@gmail.com');
      expect(result, equals(null));
    });

    test('Should return correct user data if email is valid', () async {
      var user = await _api.getUser(testEmail);

      expect(user.displayName, equals(testDisplayName));
      expect(user.email, equals(testEmail));
      expect(user.leapfrogId, equals(testLeapfrogId));
      expect(name(user.method), equals(testMethod));
      expect(user.passwordHash, equals(testPasswordHash));
    });
  });

  group('registerUser', () {
    test('Should initialize config if not ready', () async {
      await _api.getUser('asdf@email.com');
      verify(_config.ready).called(1);
    });

    test('Should post correct data with no password specified', () async {
      await _api.registerUser(testEmail, testDisplayName, testMethod);

      var expected = {
        'email': testEmail,
        'display_name': testDisplayName,
        'method': testMethod
      };

      expect(postData, equals(expected));
    });

    test('Should post correct data with password specified', () async {
      await _api.registerUser(testEmail, testDisplayName, testMethod, testPasswordHash);

      var expected = {
        'email': testEmail,
        'display_name': testDisplayName,
        'method': testMethod,
        'password_hash': util.hash(testPasswordHash)
      };

      expect(postData, equals(expected));
    });

    test('Should return CREATED for successful creation', () async {
      var result = await _api.registerUser(testEmail, testDisplayName, testMethod, testPasswordHash);
      expect(result, equals(SignInResultType.CREATED));
    });

    test('Should return DUPLICATE_EMAIL for Bad Request API response', () async {
      var result = await _badRequestApi.registerUser(testEmail, testDisplayName, testMethod, testPasswordHash);
      expect(result, equals(SignInResultType.DUPLICATE_EMAIL));
    });

    test('Should return FAILURE for other response codes', () async {
      var result = await _notFoundApi.registerUser(testEmail, testDisplayName, testMethod, testPasswordHash);
      expect(result, equals(SignInResultType.FAILURE));
    });
  });

  group('initiateTransfer', () {
    test('Should initialize config if not ready', () async {
      await _api.initiateTransfer(testEmail, testPosition);
      verify(_config.ready).called(1);
    });

    test('Should post correct email and location', () async {
      await _api.initiateTransfer(testEmail, testPosition);

      var expected = {
        'email': testEmail,
        'latitude': testPosition['latitude'].toString(),
        'longitude': testPosition['longitude'].toString()
      };

      expect(postData, equals(expected));
    });

    test('Should return PendingTransfer with correct location and ID if successful', () async {
      var pendingTransfer = await _api.initiateTransfer(testEmail, testPosition);

      expect(pendingTransfer.id, equals(testTransferId));
      expect(pendingTransfer.position, equals(testPosition));
    });

    test('Should return null if PendingTransfer creation is unsuccessful', () async {
      var result = await _badRequestApi.initiateTransfer(testEmail, testPosition);

      expect(result, equals(null));
    });
  });

  group('confirmTransfer', () {
    test('Should initialize config if not ready', () async {
      await _api.confirmTransfer(testTransferId, testEmail, testPosition);
      verify(_config.ready).called(1);
    });

    test('Should post correct data', () async {
      await _api.confirmTransfer(testTransferId, testEmail, testPosition);

      var expected = {
        'email': testEmail,
        'latitude': testPosition['latitude'].toString(),
        'longitude': testPosition['longitude'].toString()
      };

      expect(postData, equals(expected));
    });

    test('Should return SUCCESS if confirmation is successful', () async {
      var result = await _api.confirmTransfer(testTransferId, testEmail, testPosition);;
      expect(result, ConfirmationResult.SUCCESS);
    });

    test('Should return FAILURE if confirmation isn\'t successful', () async {
      var result = await _badRequestApi.confirmTransfer(testTransferId, testEmail, testPosition);
      expect(result, ConfirmationResult.FAILURE);
    });
  });

  group('getTransfersForFrog', () {
    test('Should initialize config if not ready', () async {
      await _api.getTransfersForFrog(testLeapfrogId);
      verify(_config.ready).called(1);
    });

    test('Should return correct transfer data if request is successful', () async {
      var result = await _api.getTransfersForFrog(testLeapfrogId);
      var jsonResult = [];
      
      result.forEach((t) {
        jsonResult.add(t.toJson());
      });

      expect(jsonResult, equals(testTransfers));
    });

    test('Should return empty list if frog has no transfers', () async {
      testTransfers = [];
      var result = await _api.getTransfersForFrog(testLeapfrogId);

      expect(result, equals([]));
    });

    test('Should return null if request is unsuccessful', () async {
      var result = await _badRequestApi.getTransfersForFrog(testLeapfrogId);

      expect(result, equals(null));
    });
  });

  group('getLeapfrogsForUser', () {
    test('Should initialize config if not ready', () async {
      await _api.getLeapfrogsForUser(testEmail);
      verify(_config.ready).called(1);
    });

    test('Should return correct leapfrog data if request is successful', () async {
      var result = await _api.getLeapfrogsForUser(testEmail);

      expect(result, equals(testLeapfrogs));
    });

    test('Should return empty list if user has no frogs', () async {
      testLeapfrogs = [];
      var result = await _api.getLeapfrogsForUser(testEmail);

      expect(result, equals([]));
    });

    test('Should return null if request is unsuccessful', () async {
      var result = await _badRequestApi.getLeapfrogsForUser(testEmail);

      expect(result, equals(null));
    });
  });
}

Future<Response> requestHandler(Request request) async {
  if (request.method.toUpperCase() == 'GET' &&
      request.url.path == '/users/$testEmail') {
    var body = {
      'display_name': testDisplayName,
      'email': testEmail,
      'leapfrog_id': testLeapfrogId,
      'method': testMethod,
      'password_hash': testPasswordHash
    };

    return new Response(convert.jsonEncode(body), 200);
  }

  else if (request.method.toUpperCase() == 'POST' &&
      request.url.path == '/users/') {
    postData = Uri.splitQueryString(request.body);

    return new Response('', 201);
  }

  else if (request.method.toUpperCase() == 'POST' &&
      request.url.path == '/pendingtransfers/') {
    postData = Uri.splitQueryString(request.body);

    var response = {
      'id': testTransferId,
      'latitude': double.parse(postData['latitude']),
      'longitude': double.parse(postData['longitude']),
    };

    return new Response(convert.jsonEncode(response), 201);
  }

  else if (request.method.toUpperCase() == 'POST' &&
      request.url.path == '/pendingtransfers/$testTransferId/confirm') {
    postData = Uri.splitQueryString(request.body);

    return new Response('', 201);
  }

  else if (request.method.toUpperCase() == 'GET' &&
      request.url.path == '/leapfrogs/$testLeapfrogId/transfers/') {
    return new Response(convert.jsonEncode(testTransfers), 200);
  }

  else if (request.method.toUpperCase() == 'GET' &&
      request.url.path == '/users/${Uri.encodeFull(testEmail)}/leapfrogs/') {
    return new Response(convert.jsonEncode(testLeapfrogs), 200);
  }

  return new Response('', 404);
}

Future<Response> badRequest(Request request) async {
  return new Response('', 400);
}

Future<Response> notFound(Request request) async {
  return new Response('', 404);
}