import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late UpdateUserUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = UpdateUserUsecase(authRepository: mockAuthRepository);
  });

  const testUser = AuthEntity(
    userId: '1',
    username: 'Miraj',
    email: 'miraj@test.com',
    password: 'password123',
  );

  const testUpdatedUser = AuthEntity(
    userId: '1',
    username: 'Miraj Updated',
    email: 'miraj@test.com',
    password: 'password123',
  );

  const params = UpdateUserParams(user: testUser);

  test('should return updated user when repository update succeeds', () async {
    // arrange
    when(
      () => mockAuthRepository.updateUser(testUser),
    ).thenAnswer((_) async => const Right(testUpdatedUser));

    // act
    final result = await usecase(params);

    // assert
    expect(result, const Right(testUpdatedUser));
    verify(() => mockAuthRepository.updateUser(testUser)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when repository update fails', () async {
    // arrange
    final failure = ApiFailure(message: 'Failed to update user');

    when(
      () => mockAuthRepository.updateUser(testUser),
    ).thenAnswer((_) async => Left(failure));

    // act
    final result = await usecase(params);

    // assert
    expect(result, Left(failure));
    verify(() => mockAuthRepository.updateUser(testUser)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
