/// 환경 변수 관리 클래스. 빌드 타임 혹은 런타임 환경에 따라 값을 주입받습니다.
class Env {
  static const apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://3.38.182.196:80',
  );

  /// 환경 설정 값을 로드합니다. (String.fromEnvironment는 컴파일 타임 상수이므로 별도 로드 로직이 불필요합니다.)
  static void load() {
    print("현재 서버: $apiBase");
  }
}
