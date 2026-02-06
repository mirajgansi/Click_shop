// import 'package:click_shop/core/error/failures.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dartz/dartz.dart';

// import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
// import 'package:click_shop/features/auth/presentation/state/auth_state.dart';

// import 'package:click_shop/features/auth/domain/usecases/login_usecase.dart';
// import 'package:click_shop/features/auth/domain/usecases/register_usecase.dart';
// import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
// import 'package:click_shop/features/auth/domain/usecases/logout_usecase.dart';
// import 'package:click_shop/features/auth/domain/usecases/updateProfile_usecase.dart';
// import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';

// // Mocks for tesitng
// class MockAuthEntity extends Mock implements AuthEntity {}

// class MockLoginUsecase extends Mock implements LoginUsecase {}

// class MockRegisterUsecase extends Mock implements RegisterUsecase {}

// class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

// class MockLogoutUsecase extends Mock implements LogoutUsecase {}

// class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

// // Fallback for mocktail
// class FakeLoginParams extends Fake implements LoginUsecaseParams {}

// void main() {
//   setUpAll(() {
//     registerFallbackValue(FakeLoginParams());
//   });

//   group('AuthViewModel Unit Tests', () {
//     test('login success -> sets authenticated + user', () async {
//       final mockLogin = MockLoginUsecase();
//       final mockRegister = MockRegisterUsecase();
//       final mockGetCurrent = MockGetCurrentUserUsecase();
//       final mockLogout = MockLogoutUsecase();
//       final mockUpdate = MockUpdateProfileUsecase();

//       final user = MockAuthEntity();

//       when(() => mockLogin(any())).thenAnswer((_) async => Right(user));

//       final container = ProviderContainer(
//         overrides: [
//           loginUsecaseProvider.overrideWithValue(mockLogin),
//           registerUsecaseProvider.overrideWithValue(mockRegister),
//           getCurrentUserUsecaseProvider.overrideWithValue(mockGetCurrent),
//           logoutUsecaseProvider.overrideWithValue(mockLogout),
//           updateProfileUsecaseProvider.overrideWithValue(mockUpdate),
//         ],
//       );
//       addTearDown(container.dispose);

//       final notifier = container.read(AuthViewModelProvider.notifier);

//       await notifier.login(email: 'a@b.com', password: '123456');

//       final state = container.read(AuthViewModelProvider);
//       expect(state.status, AuthStatus.authenticated);
//       expect(state.user, user);
//     });

//     test('login failure -> sets error + errorMessage', () async {
//       final mockLogin = MockLoginUsecase();
//       final mockRegister = MockRegisterUsecase();
//       final mockGetCurrent = MockGetCurrentUserUsecase();
//       final mockLogout = MockLogoutUsecase();
//       final mockUpdate = MockUpdateProfileUsecase();

//       final failure = ApiFailure(
//         message: 'Invalid credentials',
//         statusCode: 401,
//       );
//       when(() => mockLogin(any())).thenAnswer((_) async => Left(failure));

//       final container = ProviderContainer(
//         overrides: [
//           loginUsecaseProvider.overrideWithValue(mockLogin),
//           registerUsecaseProvider.overrideWithValue(mockRegister),
//           getCurrentUserUsecaseProvider.overrideWithValue(mockGetCurrent),
//           logoutUsecaseProvider.overrideWithValue(mockLogout),
//           updateProfileUsecaseProvider.overrideWithValue(mockUpdate),
//         ],
//       );
//       addTearDown(container.dispose);

//       final notifier = container.read(AuthViewModelProvider.notifier);

//       await notifier.login(email: 'a@b.com', password: 'wrong');

//       final state = container.read(AuthViewModelProvider);
//       expect(state.status, AuthStatus.error);
//       expect(state.errorMessage, 'Invalid credentials');
//     });
//   });
// }

// class _TestFailure {
//   final String message;
//   _TestFailure(this.message);
// }
