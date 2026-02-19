import 'dart:io';

/// 환경 변수 관리 클래스. 빌드 타임 혹은 런타임 환경에 따라 값을 주입받습니다.
class Env {
  /// API 베이스 URL을 반환합니다.
  /// - 환경 변수로 API_BASE_URL이 설정된 경우 해당 값을 사용
  /// - Android 에뮬레이터: 10.0.2.2:3000 (localhost 대신)
  /// - iOS 시뮬레이터 및 기타: localhost:3000
  static String get apiBase {
    final envUrl = const String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Android 에뮬레이터는 localhost 대신 10.0.2.2를 사용해야 함
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }

    // iOS 시뮬레이터, 웹, 데스크톱 등은 localhost 사용 가능
    return 'http://localhost:3000';
  }

  /// 환경 설정 값을 로드합니다.
  static void load() {
    print("현재 서버: $apiBase");
  }
}
