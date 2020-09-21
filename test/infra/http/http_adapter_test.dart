import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:for_dev/data/http/http.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class ClientSpy extends Mock implements Client {}

class HttpAdapter implements HttpClient {
  final Client client;

  HttpAdapter(this.client);

  Future<Map> request({
    @required String url,
    @required String method,
    Map body,
  }) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json'
    };
    final jsonBody = body != null ? jsonEncode(body) : null;
    final response = await client.post(url, headers: headers, body: jsonBody);
    return response.body.isEmpty ? null : jsonDecode(response.body);
  }
}

void main() {
  HttpAdapter sut;
  ClientSpy client;
  String url;

  setUp(() {
    client = ClientSpy();
    sut = HttpAdapter(client);
    url = faker.internet.httpUrl();
  });

  group('post', () {
    test('Should call post whit correct values', () async {
      // arrange
      when(client.post(any,
              body: anyNamed('body'), headers: anyNamed('headers')))
          .thenAnswer((_) async => Response('{"any_key":"any_value"}', 200));
      // act
      await sut
          .request(url: url, method: 'post', body: {'any_key': 'any_value'});

      // assert
      verify(
        client.post(
          url,
          headers: {
            'content-type': 'application/json',
            'accept': 'application/json'
          },
          body: '{"any_key":"any_value"}',
        ),
      );
    });

    test('Should call post whitout body', () async {
      // arrange
      when(client.post(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => Response('{"any_key":"any_value"}', 200));
      // act
      await sut.request(url: url, method: 'post');

      // assert
      verify(
        client.post(
          any,
          headers: anyNamed('headers'),
        ),
      );
    });

    test('Should return data if post return 200', () async {
      // arrange
      when(client.post(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => Response('{"any_key":"any_value"}', 200));
      // act
      final response = await sut.request(url: url, method: 'post');

      // assert
      expect(response, {'any_key': 'any_value'});
    });

    test('Should return data if post return 200', () async {
      // arrange
      when(client.post(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => Response('', 200));
      // act
      final response = await sut.request(url: url, method: 'post');

      // assert
      expect(response, null);
    });
  });
}
