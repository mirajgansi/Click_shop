import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/usecases/delete_me_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
import 'package:click_shop/features/auth/domain/usecases/login_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/logout_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/register_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/requeset_password_reset_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/reset_password.dart';
import 'package:click_shop/features/auth/domain/usecases/save_fcm_token_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/updateProfile_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/verify_coode_usecase.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

/// ------------------ Mocks ------------------
class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

class MockUpdateUserUsecase extends Mock implements UpdateUserUsecase {}

class MockDeleteMeUsecase extends Mock implements DeleteMeUsecase {}

class MockRequestPasswordResetUsecase extends Mock
    implements RequestPasswordResetUsecase {}

class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

class MockVerifyResetCodeUsecase extends Mock
    implements VerifyResetCodeUsecase {}

class MockSaveFcmTokenUsecase extends Mock implements SaveFcmTokenUsecase {}

/// ------------------ Fakes (for mocktail any()) ------------------
class FakeLoginParams extends Fake implements LoginUsecaseParams {}

class FakeRegisterParams extends Fake implements RegisterUsecaseParams {}

class FakeUpdateProfileParams extends Fake
    implements UpdateProfileUsecaseParams {}

class FakeUpdateUserParams extends Fake implements UpdateUserParams {}

class FakeDeleteMeParams extends Fake implements DeleteMeParams {}

class FakeRequestResetParams extends Fake
    implements RequestPasswordResetParams {}

class FakeResetPasswordParams extends Fake implements ResetPasswordParams {}

class FakeVerifyCodeParams extends Fake implements VerifyResetCodeParams {}

class FakeSaveFcmParams extends Fake implements SaveFcmTokenParams {}

ProviderContainer makeContainer({
  required MockLoginUsecase login,
  required MockRegisterUsecase register,
  required MockGetCurrentUserUsecase getCurrent,
  required MockLogoutUsecase logout,
  required MockUpdateProfileUsecase updateProfile,
  required MockUpdateUserUsecase updateUser,
  required MockDeleteMeUsecase deleteMe,
  required MockRequestPasswordResetUsecase requestReset,
  required MockResetPasswordUsecase resetPassword,
  required MockVerifyResetCodeUsecase verifyCode,
  required MockSaveFcmTokenUsecase saveFcm,
}) {
  return ProviderContainer(
    overrides: [
      loginUsecaseProvider.overrideWithValue(login),
      registerUsecaseProvider.overrideWithValue(register),
      getCurrentUserUsecaseProvider.overrideWithValue(getCurrent),
      logoutUsecaseProvider.overrideWithValue(logout),
      updateProfileUsecaseProvider.overrideWithValue(updateProfile),
      updateUserUsecaseProvider.overrideWithValue(updateUser),
      deleteMeUsecaseProvider.overrideWithValue(deleteMe),
      requestPasswordResetUsecaseProvider.overrideWithValue(requestReset),
      resetPasswordUsecaseProvider.overrideWithValue(resetPassword),
      verifyResetCodeUsecaseProvider.overrideWithValue(verifyCode),
      saveFcmTokenUsecaseProvider.overrideWithValue(saveFcm),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Firebase messaging channel
  const MethodChannel fcmChannel = MethodChannel(
    'plugins.flutter.io/firebase_messaging',
  );

  setUpAll(() async {
    // Firebase core init for tests
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();

    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
    registerFallbackValue(FakeUpdateProfileParams());
    registerFallbackValue(FakeUpdateUserParams());
    registerFallbackValue(FakeDeleteMeParams());
    registerFallbackValue(FakeRequestResetParams());
    registerFallbackValue(FakeResetPasswordParams());
    registerFallbackValue(FakeVerifyCodeParams());
    registerFallbackValue(FakeSaveFcmParams());
  });

  setUp(() {
    // Mock Firebase Messaging so AuthViewModel login won't crash
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(fcmChannel, (MethodCall call) async {
          switch (call.method) {
            case 'Messaging#requestPermission':
              return <String, int>{
                'alert': 1,
                'announcement': 0,
                'badge': 1,
                'carPlay': 0,
                'criticalAlert': 0,
                'provisional': 0,
                'sound': 1,
                'authorizationStatus': 1,
              };
            case 'Messaging#getToken':
              return <String, dynamic>{'token': 'TEST_FCM_TOKEN'};
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(fcmChannel, null);
  });

  group('AuthViewModel - Password reset flow', () {
    test('requestPasswordReset success -> status loaded', () async {
      final mockLogin = MockLoginUsecase();
      final mockRegister = MockRegisterUsecase();
      final mockGetCurrent = MockGetCurrentUserUsecase();
      final mockLogout = MockLogoutUsecase();
      final mockUpdateProfile = MockUpdateProfileUsecase();
      final mockUpdateUser = MockUpdateUserUsecase();
      final mockDeleteMe = MockDeleteMeUsecase();
      final mockRequestReset = MockRequestPasswordResetUsecase();
      final mockResetPassword = MockResetPasswordUsecase();
      final mockVerifyCode = MockVerifyResetCodeUsecase();
      final mockSaveFcm = MockSaveFcmTokenUsecase();

      when(
        () => mockRequestReset(any()),
      ).thenAnswer((_) async => const Right(true));

      final container = makeContainer(
        login: mockLogin,
        register: mockRegister,
        getCurrent: mockGetCurrent,
        logout: mockLogout,
        updateProfile: mockUpdateProfile,
        updateUser: mockUpdateUser,
        deleteMe: mockDeleteMe,
        requestReset: mockRequestReset,
        resetPassword: mockResetPassword,
        verifyCode: mockVerifyCode,
        saveFcm: mockSaveFcm,
      );
      addTearDown(container.dispose);

      final notifier = container.read(AuthViewModelProvider.notifier);

      await notifier.requestPasswordReset('a@b.com');

      final state = container.read(AuthViewModelProvider);
      expect(state.status, AuthStatus.loaded);

      verify(() => mockRequestReset(any())).called(1);
    });

    test('requestPasswordReset failure -> status error + message', () async {
      final mockLogin = MockLoginUsecase();
      final mockRegister = MockRegisterUsecase();
      final mockGetCurrent = MockGetCurrentUserUsecase();
      final mockLogout = MockLogoutUsecase();
      final mockUpdateProfile = MockUpdateProfileUsecase();
      final mockUpdateUser = MockUpdateUserUsecase();
      final mockDeleteMe = MockDeleteMeUsecase();
      final mockRequestReset = MockRequestPasswordResetUsecase();
      final mockResetPassword = MockResetPasswordUsecase();
      final mockVerifyCode = MockVerifyResetCodeUsecase();
      final mockSaveFcm = MockSaveFcmTokenUsecase();

      final failure = ApiFailure(message: 'Email not found', statusCode: 404);

      when(
        () => mockRequestReset(any()),
      ).thenAnswer((_) async => Left(failure));

      final container = makeContainer(
        login: mockLogin,
        register: mockRegister,
        getCurrent: mockGetCurrent,
        logout: mockLogout,
        updateProfile: mockUpdateProfile,
        updateUser: mockUpdateUser,
        deleteMe: mockDeleteMe,
        requestReset: mockRequestReset,
        resetPassword: mockResetPassword,
        verifyCode: mockVerifyCode,
        saveFcm: mockSaveFcm,
      );
      addTearDown(container.dispose);

      final notifier = container.read(AuthViewModelProvider.notifier);

      await notifier.requestPasswordReset('a@b.com');

      final state = container.read(AuthViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Email not found');

      verify(() => mockRequestReset(any())).called(1);
    });

    test('verifyResetCode success -> returns true + status loaded', () async {
      final mockLogin = MockLoginUsecase();
      final mockRegister = MockRegisterUsecase();
      final mockGetCurrent = MockGetCurrentUserUsecase();
      final mockLogout = MockLogoutUsecase();
      final mockUpdateProfile = MockUpdateProfileUsecase();
      final mockUpdateUser = MockUpdateUserUsecase();
      final mockDeleteMe = MockDeleteMeUsecase();
      final mockRequestReset = MockRequestPasswordResetUsecase();
      final mockResetPassword = MockResetPasswordUsecase();
      final mockVerifyCode = MockVerifyResetCodeUsecase();
      final mockSaveFcm = MockSaveFcmTokenUsecase();

      when(
        () => mockVerifyCode(any()),
      ).thenAnswer((_) async => const Right(true));

      final container = makeContainer(
        login: mockLogin,
        register: mockRegister,
        getCurrent: mockGetCurrent,
        logout: mockLogout,
        updateProfile: mockUpdateProfile,
        updateUser: mockUpdateUser,
        deleteMe: mockDeleteMe,
        requestReset: mockRequestReset,
        resetPassword: mockResetPassword,
        verifyCode: mockVerifyCode,
        saveFcm: mockSaveFcm,
      );
      addTearDown(container.dispose);

      final notifier = container.read(AuthViewModelProvider.notifier);

      final ok = await notifier.verifyResetCode(
        email: 'a@b.com',
        code: '123456',
      );

      expect(ok, isTrue);

      final state = container.read(AuthViewModelProvider);
      expect(state.status, AuthStatus.loaded);

      verify(() => mockVerifyCode(any())).called(1);
    });

    test(
      'verifyResetCode failure -> returns false + status error + message',
      () async {
        final mockLogin = MockLoginUsecase();
        final mockRegister = MockRegisterUsecase();
        final mockGetCurrent = MockGetCurrentUserUsecase();
        final mockLogout = MockLogoutUsecase();
        final mockUpdateProfile = MockUpdateProfileUsecase();
        final mockUpdateUser = MockUpdateUserUsecase();
        final mockDeleteMe = MockDeleteMeUsecase();
        final mockRequestReset = MockRequestPasswordResetUsecase();
        final mockResetPassword = MockResetPasswordUsecase();
        final mockVerifyCode = MockVerifyResetCodeUsecase();
        final mockSaveFcm = MockSaveFcmTokenUsecase();

        final failure = ApiFailure(message: 'Invalid code', statusCode: 400);

        when(
          () => mockVerifyCode(any()),
        ).thenAnswer((_) async => Left(failure));

        final container = makeContainer(
          login: mockLogin,
          register: mockRegister,
          getCurrent: mockGetCurrent,
          logout: mockLogout,
          updateProfile: mockUpdateProfile,
          updateUser: mockUpdateUser,
          deleteMe: mockDeleteMe,
          requestReset: mockRequestReset,
          resetPassword: mockResetPassword,
          verifyCode: mockVerifyCode,
          saveFcm: mockSaveFcm,
        );
        addTearDown(container.dispose);

        final notifier = container.read(AuthViewModelProvider.notifier);

        final ok = await notifier.verifyResetCode(
          email: 'a@b.com',
          code: '000000',
        );

        expect(ok, isFalse);

        final state = container.read(AuthViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Invalid code');

        verify(() => mockVerifyCode(any())).called(1);
      },
    );

    test('resetPassword success -> status loaded', () async {
      final mockLogin = MockLoginUsecase();
      final mockRegister = MockRegisterUsecase();
      final mockGetCurrent = MockGetCurrentUserUsecase();
      final mockLogout = MockLogoutUsecase();
      final mockUpdateProfile = MockUpdateProfileUsecase();
      final mockUpdateUser = MockUpdateUserUsecase();
      final mockDeleteMe = MockDeleteMeUsecase();
      final mockRequestReset = MockRequestPasswordResetUsecase();
      final mockResetPassword = MockResetPasswordUsecase();
      final mockVerifyCode = MockVerifyResetCodeUsecase();
      final mockSaveFcm = MockSaveFcmTokenUsecase();

      when(
        () => mockResetPassword(any()),
      ).thenAnswer((_) async => const Right(true));

      final container = makeContainer(
        login: mockLogin,
        register: mockRegister,
        getCurrent: mockGetCurrent,
        logout: mockLogout,
        updateProfile: mockUpdateProfile,
        updateUser: mockUpdateUser,
        deleteMe: mockDeleteMe,
        requestReset: mockRequestReset,
        resetPassword: mockResetPassword,
        verifyCode: mockVerifyCode,
        saveFcm: mockSaveFcm,
      );
      addTearDown(container.dispose);

      final notifier = container.read(AuthViewModelProvider.notifier);

      await notifier.resetPassword(
        email: 'a@b.com',
        code: '123456',
        newPassword: 'newPass123',
      );

      final state = container.read(AuthViewModelProvider);
      expect(state.status, AuthStatus.loaded);

      verify(() => mockResetPassword(any())).called(1);
    });

    test('resetPassword failure -> status error + message', () async {
      final mockLogin = MockLoginUsecase();
      final mockRegister = MockRegisterUsecase();
      final mockGetCurrent = MockGetCurrentUserUsecase();
      final mockLogout = MockLogoutUsecase();
      final mockUpdateProfile = MockUpdateProfileUsecase();
      final mockUpdateUser = MockUpdateUserUsecase();
      final mockDeleteMe = MockDeleteMeUsecase();
      final mockRequestReset = MockRequestPasswordResetUsecase();
      final mockResetPassword = MockResetPasswordUsecase();
      final mockVerifyCode = MockVerifyResetCodeUsecase();
      final mockSaveFcm = MockSaveFcmTokenUsecase();

      final failure = ApiFailure(message: 'Reset failed', statusCode: 400);

      when(
        () => mockResetPassword(any()),
      ).thenAnswer((_) async => Left(failure));

      final container = makeContainer(
        login: mockLogin,
        register: mockRegister,
        getCurrent: mockGetCurrent,
        logout: mockLogout,
        updateProfile: mockUpdateProfile,
        updateUser: mockUpdateUser,
        deleteMe: mockDeleteMe,
        requestReset: mockRequestReset,
        resetPassword: mockResetPassword,
        verifyCode: mockVerifyCode,
        saveFcm: mockSaveFcm,
      );
      addTearDown(container.dispose);

      final notifier = container.read(AuthViewModelProvider.notifier);

      await notifier.resetPassword(
        email: 'a@b.com',
        code: '123456',
        newPassword: 'newPass123',
      );

      final state = container.read(AuthViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Reset failed');

      verify(() => mockResetPassword(any())).called(1);
    });
  });

  group('AuthViewModel - deleteMeWithPassword()', () {
    test('deleteMe success -> unauthenticated + user null', () async {
      final mockLogin = MockLoginUsecase();
      final mockRegister = MockRegisterUsecase();
      final mockGetCurrent = MockGetCurrentUserUsecase();
      final mockLogout = MockLogoutUsecase();
      final mockUpdateProfile = MockUpdateProfileUsecase();
      final mockUpdateUser = MockUpdateUserUsecase();
      final mockDeleteMe = MockDeleteMeUsecase();
      final mockRequestReset = MockRequestPasswordResetUsecase();
      final mockResetPassword = MockResetPasswordUsecase();
      final mockVerifyCode = MockVerifyResetCodeUsecase();
      final mockSaveFcm = MockSaveFcmTokenUsecase();

      when(
        () => mockDeleteMe(any()),
      ).thenAnswer((_) async => const Right(true));

      final container = makeContainer(
        login: mockLogin,
        register: mockRegister,
        getCurrent: mockGetCurrent,
        logout: mockLogout,
        updateProfile: mockUpdateProfile,
        updateUser: mockUpdateUser,
        deleteMe: mockDeleteMe,
        requestReset: mockRequestReset,
        resetPassword: mockResetPassword,
        verifyCode: mockVerifyCode,
        saveFcm: mockSaveFcm,
      );
      addTearDown(container.dispose);

      // Pretend user already logged in
      container.read(AuthViewModelProvider.notifier).state = AuthState(
        status: AuthStatus.authenticated,
        user: const AuthEntity(email: 'a@b.com', password: 'x'),
      );

      final notifier = container.read(AuthViewModelProvider.notifier);

      await notifier.deleteMeWithPassword('myPass');

      final state = container.read(AuthViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);

      verify(() => mockDeleteMe(any())).called(1);
    });

    test('deleteMe failure -> error + message', () async {
      final mockLogin = MockLoginUsecase();
      final mockRegister = MockRegisterUsecase();
      final mockGetCurrent = MockGetCurrentUserUsecase();
      final mockLogout = MockLogoutUsecase();
      final mockUpdateProfile = MockUpdateProfileUsecase();
      final mockUpdateUser = MockUpdateUserUsecase();
      final mockDeleteMe = MockDeleteMeUsecase();
      final mockRequestReset = MockRequestPasswordResetUsecase();
      final mockResetPassword = MockResetPasswordUsecase();
      final mockVerifyCode = MockVerifyResetCodeUsecase();
      final mockSaveFcm = MockSaveFcmTokenUsecase();

      final failure = ApiFailure(message: 'Wrong password', statusCode: 401);

      when(() => mockDeleteMe(any())).thenAnswer((_) async => Left(failure));

      final container = makeContainer(
        login: mockLogin,
        register: mockRegister,
        getCurrent: mockGetCurrent,
        logout: mockLogout,
        updateProfile: mockUpdateProfile,
        updateUser: mockUpdateUser,
        deleteMe: mockDeleteMe,
        requestReset: mockRequestReset,
        resetPassword: mockResetPassword,
        verifyCode: mockVerifyCode,
        saveFcm: mockSaveFcm,
      );
      addTearDown(container.dispose);

      final notifier = container.read(AuthViewModelProvider.notifier);

      await notifier.deleteMeWithPassword('wrong');

      final state = container.read(AuthViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Wrong password');

      verify(() => mockDeleteMe(any())).called(1);
    });
  });
}
