import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:for_dev/domain/entities/account_entity.dart';
import 'package:for_dev/domain/usecases/usecases.dart';
import 'package:for_dev/presentation/presenters/presenters.dart';

class LoadCurrentAccountSpy extends Mock implements LoadCurrentAccount {}

void main() {
  LoadCurrentAccountSpy loadCurrentAccount;
  GetxSplashPresenter sut;

  PostExpectation mockLoadCurrentAccountCall() =>
      when(loadCurrentAccount.load());

  void mockLoadCurrentAccount({AccountEntity account}) {
    mockLoadCurrentAccountCall().thenAnswer((_) async => account);
  }

  void mockLoadCurrentAccountError() {
    mockLoadCurrentAccountCall().thenReturn(Exception());
  }

  setUp(() {
    loadCurrentAccount = LoadCurrentAccountSpy();
    sut = GetxSplashPresenter(loadCurrentAccount: loadCurrentAccount);
    mockLoadCurrentAccount(account: AccountEntity(faker.guid.guid()));
  });

  test('Should call LoadCurrentAccount', () async {
    await sut.checkAccount(durationInSecunds: 0);

    verify(loadCurrentAccount.load()).called(1);
  });

  test('Should go to surveys page on success', () async {
    sut.navigateToStream
        .listen(expectAsync1((page) => expect(page, '/surveys')));

    await sut.checkAccount(durationInSecunds: 0);
  });

  test('Should go to surveys page on success', () async {
    mockLoadCurrentAccount(account: null);

    sut.navigateToStream.listen(expectAsync1((page) => expect(page, '/login')));

    await sut.checkAccount(durationInSecunds: 0);
  });

  test('Should go to surveys page on error', () async {
    mockLoadCurrentAccountError();

    sut.navigateToStream.listen(expectAsync1((page) => expect(page, '/login')));

    await sut.checkAccount(durationInSecunds: 0);
  });
}
