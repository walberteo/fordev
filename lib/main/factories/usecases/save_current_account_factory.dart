import '../../../data/usecases/usecases.dart';
import '../../../domain/usecases/usecases.dart';
import '../cache/cache.dart';

SaveCurrentAccount makeLocalSaveCurrentAccount() {
  return LocalSaveCurrentAccount(
      saveSecureCacheStorage: makeLocalStorageAdapter());
}
