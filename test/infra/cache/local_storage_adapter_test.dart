import 'package:faker/faker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:for_dev/infra/cache/cache.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class FuttterSecureStorageMock extends Mock implements FlutterSecureStorage {}

void main() {
  LocalStorageAdapter sut;
  FuttterSecureStorageMock secureStorage;
  String key;
  String value;

  setUp(() {
    secureStorage = FuttterSecureStorageMock();
    sut = LocalStorageAdapter(secureStorage: secureStorage);
    key = faker.lorem.word();
    value = faker.guid.guid();
  });

  void mockSaveSecureError() {
    when(secureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
        .thenThrow(Exception());
  }

  test('Shoud call save secure with correct values', () async {
    await sut.saveSecure(key: key, value: value);

    verify(secureStorage.write(key: key, value: value));
  });

  test('Shoud throw save secure throws', () async {
    mockSaveSecureError();

    final future = sut.saveSecure(key: key, value: value);

    expect(future, throwsA(TypeMatcher<Exception>()));
  });
}
