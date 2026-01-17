import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.authtypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String? username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? confirmPassword;

  @HiveField(5)
  final String? profileImage;

  AuthHiveModel({
    String? userId,
    required this.email,
    this.profileImage,
    required this.username,
    this.password,
    this.confirmPassword,
  }) : userId = userId ?? Uuid().v4();

  //from entity to hive model
  factory AuthHiveModel.fromEntity(AuthEntity authEntity) {
    return AuthHiveModel(
      userId: authEntity.userId,
      email: authEntity.email,
      profileImage: authEntity.profileImage,
      username: authEntity.username,
      password: authEntity.password,
      confirmPassword: authEntity.confirmPassword,
    );
  }

  //to entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      email: email,
      profileImage: profileImage,
      username: username,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  //To entity list
  static List<AuthEntity> toEntityList(List<AuthHiveModel> hiveModels) {
    return hiveModels.map((model) => model.toEntity()).toList();
  }
}
