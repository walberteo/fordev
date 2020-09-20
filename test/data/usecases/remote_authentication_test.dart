import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:for_dev/domain/helpers/helpers.dart';
import 'package:for_dev/domain/usecases/usecases.dart';

import 'package:for_dev/data/usecases/usecases.dart';
import 'package:for_dev/data/http/http.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication sut;
  HttpClientSpy httpClient;
  String url;
  AuthenticationParams params;

  // arrange
  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
        email: faker.internet.email(), password: faker.internet.password());
  });

  test('shuld call httpClient with correct values', () async {
    // act
    await sut.auth(params);
    // assert
    verify(httpClient.request(
      url: url,
      method: 'post',
      body: {'email': params.email, 'password': params.password},
    ));
  });

  test('Should throw UnexpectedError if HttpClient returns 400', () async {
    //arrange
    when(httpClient.request(
            url: anyNamed('url'),
            method: anyNamed('method'),
            body: anyNamed('body')))
        .thenThrow(HttpError.badRequest);

    // act
    final future = sut.auth(params);
    // assert

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    //arrange
    when(httpClient.request(
            url: anyNamed('url'),
            method: anyNamed('method'),
            body: anyNamed('body')))
        .thenThrow(HttpError.notFound);

    // act
    final future = sut.auth(params);
    // assert

    expect(future, throwsA(DomainError.unexpected));
  });
}
