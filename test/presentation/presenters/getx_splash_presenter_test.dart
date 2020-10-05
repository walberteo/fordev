import 'package:faker/faker.dart';
import 'package:for_dev/domain/entities/account_entity.dart';
import 'package:for_dev/domain/usecases/usecases.dart';
import 'package:for_dev/ui/pages/pages.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:meta/meta.dart';

class GetxSplashPresenter implements SplashPresenter {
  final LoadCurrentAccount loadCurrentAccount;
  final _navigateTo = RxString();

  GetxSplashPresenter({@required this.loadCurrentAccount});

  @override
  Stream<String> get navigateToStream => _navigateTo.stream;

  @override
  Future<void> checkAccount() async {
    try {
      final account = await loadCurrentAccount.load();
      _navigateTo.value = account.isNull ? '/login' : '/surverys';
    } catch (error) {
      _navigateTo.value = '/login';
    }
  }
}

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
    await sut.checkAccount();

    verify(loadCurrentAccount.load()).called(1);
  });

  test('Should go to surverys page on success', () async {
    sut.navigateToStream
        .listen(expectAsync1((page) => expect(page, '/surverys')));

    await sut.checkAccount();
  });

  test('Should go to surverys page on success', () async {
    mockLoadCurrentAccount(account: null);

    sut.navigateToStream.listen(expectAsync1((page) => expect(page, '/login')));

    await sut.checkAccount();
  });

  test('Should go to surverys page on error', () async {
    mockLoadCurrentAccountError();

    sut.navigateToStream.listen(expectAsync1((page) => expect(page, '/login')));

    await sut.checkAccount();
  });
}
