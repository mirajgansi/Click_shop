import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/usecases/login_usecase.dart';
import 'package:click_shop/core/error/failures.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(email: 'fallback@mail.com', password: '123456'),
    );
  });

  const email = 'test@mail.com';
  const password = 'password123';

  test('returns user with id when login is successful', () async {
    final user = AuthEntity(userId: '123', email: email, password: password);

    when(
      () => mockRepository.login(email, password),
    ).thenAnswer((_) async => Right(user));

    final result = await usecase(
      LoginUsecaseParams(email: email, password: password),
    );

    expect(result, Right(user));
    expect(result.getOrElse(() => user).userId, '123');
  });

  test('should return Failure when login fails', () async {
    // Arrange
    final failure = ApiFailure(message: 'Invalid credentials', statusCode: 401);

    when(
      () => mockRepository.login(any(), any()),
    ).thenAnswer((_) async => Left(failure));

    // Act
    final result = await usecase(
      LoginUsecaseParams(email: email, password: password),
    );

    // Assert
    expect(result, Left(failure));
    verify(() => mockRepository.login(any(), any())).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
