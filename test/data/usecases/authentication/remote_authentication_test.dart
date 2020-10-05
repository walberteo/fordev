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

  PostExpectation mockRequest() => when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      bodyValue: anyNamed('bodyValue')));

  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  Map mockValidData() =>
      {'accessToken': faker.guid.guid(), 'name': faker.person.name()};

  // arrange
  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
        email: faker.internet.email(), password: faker.internet.password());
    mockHttpData(mockValidData());
  });

  test('shuld call httpClient with correct values', () async {
    // act
    await sut.auth(params);
    // assert
    verify(httpClient.request(
      url: url,
      method: 'post',
      bodyValue: {'email': params.email, 'password': params.password},
    ));
  });

  test('Should throw UnexpectedError if HttpClient returns 400', () async {
    //arrange
    mockHttpError(HttpError.badRequest);

    // act
    final future = sut.auth(params);
    // assert
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    //arrange
    mockHttpError(HttpError.notFound);

    // act
    final future = sut.auth(params);
    // assert
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    //arrange
    mockHttpError(HttpError.serverError);

    // act
    final future = sut.auth(params);
    // assert
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw InvalidCredentialsError if HttpClient returns 401',
      () async {
    //arrange
    mockHttpError(HttpError.unauthorized);

    // act
    final future = sut.auth(params);
    // assert
    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('Should return an Account if HttpClient returns 200', () async {
    //arrange
    final validData = mockValidData();
    mockHttpData(validData);

    // act
    final account = await sut.auth(params);
    // assert
    expect(account.token, validData['accessToken']);
  });

  test(
      'Should throw UnexpetecError if HttpClient returns 200 with invalid data',
      () async {
    //arrange
    mockHttpData({'invalid_key': 'invalid_key'});

    // act
    final futere = sut.auth(params);
    // assert
    expect(futere, throwsA(DomainError.unexpected));
  });
}
