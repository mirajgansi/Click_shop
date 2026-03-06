import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/usecases/logout_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUsecase usecase;
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    usecase = LogoutUsecase(authRepository: repository);
  });

  test('returns true when logout succeeds', () async {
    when(() => repository.logout()).thenAnswer((_) async => const Right(true));

    final result = await usecase();

    expect(result, const Right(true));
    verify(() => repository.logout()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns failure when logout fails', () async {
    final failure = ApiFailure(message: 'logout failed');

    when(() => repository.logout()).thenAnswer((_) async => Left(failure));

    final result = await usecase();

    expect(result, Left(failure));
    verify(() => repository.logout()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
