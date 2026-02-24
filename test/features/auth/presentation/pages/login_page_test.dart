import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/usecases/login_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  const email = 'test@mail.com';
  const password = 'password123';

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  test('returns user when login is successful', () async {
    // Arrange
    final user = AuthEntity(userId: '123', email: email, password: password);

    when(
      () => mockRepository.login(email, password),
    ).thenAnswer((_) async => Right(user));

    // Act
    final result = await usecase(
      LoginUsecaseParams(email: email, password: password),
    );

    // Assert (don’t compare Right(user) directly unless AuthEntity has ==)
    result.fold((l) => fail('Expected Right(user), got Left($l)'), (r) {
      expect(r.userId, '123');
      expect(r.email, email);
    });

    verify(() => mockRepository.login(email, password)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Failure when login fails', () async {
    // Arrange
    final failure = ApiFailure(message: 'Invalid credentials', statusCode: 401);

    when(
      () => mockRepository.login(email, password),
    ).thenAnswer((_) async => Left(failure));

    // Act
    final result = await usecase(
      LoginUsecaseParams(email: email, password: password),
    );

    // Assert
    result.fold((l) {
      expect(l, isA<ApiFailure>());
      final f = l as ApiFailure;
      expect(f.message, 'Invalid credentials');
      expect(f.statusCode, 401);
    }, (r) => fail('Expected Left(failure), got Right($r)'));

    verify(() => mockRepository.login(email, password)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
