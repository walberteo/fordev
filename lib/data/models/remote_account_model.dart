import 'package:for_dev/domain/entities/account_entity.dart';

class RemoteAccountModel {
  final String accesstoken;

  RemoteAccountModel(this.accesstoken);

  factory RemoteAccountModel.fromJson(Map json) =>
      RemoteAccountModel(json['accessToken']);

  AccountEntity toEntity() => AccountEntity(accesstoken);
}
