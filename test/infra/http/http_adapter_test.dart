import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:for_dev/data/http/http_error.dart';
import 'package:for_dev/infra/http/http.dart';

class ClientSpy extends Mock implements Client {}

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
    PostExpectation mockResquest() => when(
        client.post(any, body: anyNamed('body'), headers: anyNamed('headers')));

    void mockResponse(int statusCode, {body: '{"any_key":"any_value"}'}) {
      mockResquest().thenAnswer((_) async => Response(body, statusCode));
    }

    setUp(() {
      mockResponse(200);
    });

    test('Should call post whit correct values', () async {
      // arrange

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

      // act
      final response = await sut.request(url: url, method: 'post');

      // assert
      expect(response, {'any_key': 'any_value'});
    });

    test('Should return data if post return 200 without data', () async {
      // arrange
      mockResponse(200, body: '');
      // act
      final response = await sut.request(url: url, method: 'post');

      // assert
      expect(response, null);
    });

    test('Should return data if post return 204', () async {
      // arrange
      mockResponse(204, body: '');
      // act
      final response = await sut.request(url: url, method: 'post');

      // assert
      expect(response, null);
    });

    test('Should return data if post return 204', () async {
      // arrange
      mockResponse(204);
      // act
      final response = await sut.request(url: url, method: 'post');

      // assert
      expect(response, null);
    });

    test('Should return BadResquesError if post returns 400', () async {
      // arrange
      mockResponse(400, body: '');
      // act
      final future = sut.request(url: url, method: 'post');

      // assert
      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return BadResquesError if post returns 400', () async {
      // arrange
      mockResponse(400);
      // act
      final future = sut.request(url: url, method: 'post');

      // assert
      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return UnauthorizedError if post returns 401', () async {
      // arrange
      mockResponse(401);
      // act
      final future = sut.request(url: url, method: 'post');

      // assert
      expect(future, throwsA(HttpError.unauthorized));
    });
    test('Should return ServerError if post returns 500', () async {
      // arrange
      mockResponse(500);
      // act
      final future = sut.request(url: url, method: 'post');

      // assert
      expect(future, throwsA(HttpError.serverError));
    });
  });
}
