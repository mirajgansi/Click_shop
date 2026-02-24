import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/usecases/login_usecase.dart'; // <-- adjust path

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginUsecase loginUsecase;

  const tEmail = "test@mail.com";
  const tPassword = "Password123";

  const tParams = LoginUsecaseParams(email: tEmail, password: tPassword);

  const tAuthEntity = AuthEntity(email: tEmail, password: tPassword);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUsecase = LoginUsecase(authRepository: mockAuthRepository);
  });

  group("LoginUsecase", () {
    test("should return AuthEntity when login is successful", () async {
      // arrange
      when(
        () => mockAuthRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // act
      final result = await loginUsecase(tParams);

      // assert
      expect(result, const Right(tAuthEntity));
      verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test("should return Failure when login fails", () async {
      // arrange
      final failure = LocalDatabaseFailure(
        message: "Login failed",
      ); // adjust to your Failure type
      when(
        () => mockAuthRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await loginUsecase(tParams);

      // assert
      expect(result, Left(failure));
      verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
