import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/usecases/updateProfile_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late UpdateProfileUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = UpdateProfileUsecase(repository: mockAuthRepository);
  });

  const testImage = "profile.png";

  final params = UpdateProfileUsecaseParams(image: testImage);

  test('should return success message when profile image is updated', () async {
    when(
      () => mockAuthRepository.updateProfileImage(testImage),
    ).thenAnswer((_) async => const Right("Profile updated successfully"));

    final result = await usecase(params);

    expect(result, const Right("Profile updated successfully"));
    verify(() => mockAuthRepository.updateProfileImage(testImage)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when profile image update fails', () async {
    final failure = ApiFailure(message: "Update failed");

    when(
      () => mockAuthRepository.updateProfileImage(testImage),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase(params);

    expect(result, Left(failure));
    verify(() => mockAuthRepository.updateProfileImage(testImage)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should pass null image to repository', () async {
    // arrange
    final nullParams = UpdateProfileUsecaseParams(image: null);

    when(
      () => mockAuthRepository.updateProfileImage(null),
    ).thenAnswer((_) async => const Right("Profile updated successfully"));

    // act
    final result = await usecase(nullParams);

    // assert
    expect(result, const Right("Profile updated successfully"));
    verify(() => mockAuthRepository.updateProfileImage(null)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
