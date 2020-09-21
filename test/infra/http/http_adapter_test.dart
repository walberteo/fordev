import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:meta/meta.dart';

class ClientSpy extends Mock implements Client {}

class HttpAdapter {
  final Client client;

  HttpAdapter(this.client);

  Future<void> request({
    @required String url,
    @required String method,
    Map body,
  }) async {
    client.post(url);
  }
}

void main() {
  group('post', () {
    test('Should call post whit correct values', () async {
      // arrange
      final client = ClientSpy();
      final sut = HttpAdapter(client);
      final url = faker.internet.httpUrl();
      // act
      await sut.request(url: url, method: 'post');
      // assert
      verify(client.post(url));
    });
  });
}
