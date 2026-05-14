import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/auth/data/auth_api.dart';
import 'package:ai_life_legacy/features/auth/data/models/auth.dto.dart';
import 'package:ai_life_legacy/app/core/utils/token_storage.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthApi _authApi;

  AuthController(this._authApi);

  final emailController = Rx<String>('');
  final passwordController = Rx<String>('');
  
  final isLoading = false.obs;
  final showPassword = false.obs;
  final errorMessage = ''.obs;

  void toggleShowPassword() => showPassword.toggle();

  void clearFields() {
    emailController.value = '';
    passwordController.value = '';
  }

  Future<void> login() async {
    if (isLoading.value) return;

    final email = emailController.value.trim();
    final password = passwordController.value.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = '이메일과 비밀번호를 입력해주세요.';
      return;
    }

    try {
      errorMessage.value = '';
      isLoading.value = true;
      final response = await _authApi.login(
        AuthCredentialsDto(
          email: email,
          password: password,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        debugPrint('[AuthController] login response data: $data');

        // 백엔드 응답 구조: { status, message, result: { accessToken, refreshToken } }
        final tokenData = data['result'] ?? data['data'] ?? data;
        debugPrint('[AuthController] tokenData: $tokenData');

        final accessToken = tokenData['accessToken'];
        final refreshToken = tokenData['refreshToken'];

        if (accessToken != null && refreshToken != null) {
          await TokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
          clearFields();
          Get.offAllNamed(Routes.home);
        } else {
          errorMessage.value = '서버 응답에서 토큰을 추출할 수 없습니다.';
        }
      }
    } catch (e) {
      errorMessage.value = '이메일 또는 비밀번호를 확인해주세요.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (isLoading.value) return;

    final email = emailController.value.trim();
    final password = passwordController.value.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = '이메일과 비밀번호를 모두 입력해주세요.';
      return;
    }

    try {
      errorMessage.value = '';
      isLoading.value = true;
      final response = await _authApi.signUp(
        AuthCredentialsDto(
          email: email,
          password: password,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        debugPrint('[AuthController] signUp response data: $data');

        final tokenData = data['result'] ?? data['data'] ?? data;

        final accessToken = tokenData['accessToken'];
        final refreshToken = tokenData['refreshToken'];

        if (accessToken != null && refreshToken != null) {
          await TokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
          clearFields();
          Get.offAllNamed(Routes.selfIntro);
        } else {
          errorMessage.value = '서버 응답에서 토큰을 추출할 수 없습니다.';
        }
      }
    } catch (e) {
      // 409 Conflict 등의 에러 처리
      errorMessage.value = '회원가입에 실패했습니다. 다시 시도해주세요.';
      if (e.toString().contains('409')) {
        errorMessage.value = '이미 가입된 이메일입니다.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearTokens();
    Get.offAllNamed(Routes.login);
  }
}
