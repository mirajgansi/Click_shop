// import 'package:dartz/dartz.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';

// import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
// import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
// import 'package:click_shop/features/auth/domain/usecases/register_usecase.dart';

// // Mock Repository
// class MockAuthRepository extends Mock implements IAuthRepository {}

// void main() {
//   late RegisterUsecase usecase;
//   late MockAuthRepository mockRepository;

//   setUp(() {
//     mockRepository = MockAuthRepository();
//     usecase = RegisterUsecase(authRepository: mockRepository);
//   });

//   setUpAll(() {
//     registerFallbackValue(
//       const AuthEntity(
//         username: 'fallback',
//         email: 'fallback@mail.com',
//         password: '123456',
//         confirmPassword: '123456',
//       ),
//     );
//   });

//   const username = 'john';
//   const email = 'john@mail.com';
//   const password = 'password123';
//   const confirmPassword = 'password123';

//   test('should return true when registration is successful', () async {
//     // Arrange
//     when(
//       () => mockRepository.register(any()),
//     ).thenAnswer((_) async => const Right(true));

//     // Act
//     final result = await usecase(
//       RegisterUsecaseParams(
//         username: username,
//         email: email,
//         password: password,
//         confirmPassword: confirmPassword,
//       ),
//     );

//     // Assert
//     expect(result, const Right(true));
//     verify(() => mockRepository.register(any())).called(1);
//     verifyNoMoreInteractions(mockRepository);
//   });

//   test('should pass correct AuthEntity to repository', () async {
//     // Arrange
//     AuthEntity? captured;

//     when(() => mockRepository.register(any())).thenAnswer((invocation) async {
//       captured = invocation.positionalArguments[0] as AuthEntity;
//       return const Right(true);
//     });

//     // Act
//     await usecase(
//       RegisterUsecaseParams(
//         username: username,
//         email: email,
//         password: password,
//         confirmPassword: confirmPassword,
//       ),
//     );

//     // Assert
//     expect(captured?.username, username);
//     expect(captured?.email, email);
//     expect(captured?.password, password);
//     expect(captured?.confirmPassword, confirmPassword);
//   });
// }
