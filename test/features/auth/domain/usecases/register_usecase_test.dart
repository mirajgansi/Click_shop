import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/usecases/register_usecase.dart'; // <-- adjust path

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late RegisterUsecase registerUsecase;

  const tUsername = "miraj";
  const tEmail = "test@mail.com";
  const tPassword = "Password123";
  const tConfirmPassword = "Password123";

  const tParams = RegisterUsecaseParams(
    username: tUsername,
    email: tEmail,
    password: tPassword,
    confirmPassword: tConfirmPassword,
  );

  const tAuthEntity = AuthEntity(
    username: tUsername,
    email: tEmail,
    password: tPassword,
    confirmPassword: tConfirmPassword,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUsecase = RegisterUsecase(authRepository: mockAuthRepository);
  });

  group("RegisterUsecase", () {
    test("should return true when register is successful", () async {
      // arrange
      when(
        () => mockAuthRepository.register(tAuthEntity),
      ).thenAnswer((_) async => const Right(true));

      // act
      final result = await registerUsecase(tParams);

      // assert
      expect(result, const Right(true));
      verify(() => mockAuthRepository.register(tAuthEntity)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test("should return Failure when register fails", () async {
      final failure = LocalDatabaseFailure(message: "Register failed");
      when(
        () => mockAuthRepository.register(tAuthEntity),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await registerUsecase(tParams);

      // assert
      expect(result, Left(failure));
      verify(() => mockAuthRepository.register(tAuthEntity)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
