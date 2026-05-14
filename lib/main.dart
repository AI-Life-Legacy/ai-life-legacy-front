/// 앱의 진입점(Entry Point)
/// Flutter 엔진을 초기화하고 최상위 위젯(LegacyApp)을 실행합니다.
library;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/bootstrap.dart';
import 'package:ai_life_legacy/app/core/routes/app_pages.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/initial_binding.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';

/// Main 함수: 비동기 초기화 수행 후 앱 실행
/// - WidgetsFlutterBinding 초기화
/// - Bootstrap: 환경 설정, 토큰 로드, 네트워크 클라이언트 초기화
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(const LegacyApp());
}

/// 앱 루트 위젯. 반환 타입: Widget.
/// GetMaterialApp: GetX의 라우팅/로케일/테마 등을 제공하는 MaterialApp 확장.
class LegacyApp extends StatelessWidget {
  const LegacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
      title: 'AI Life Legacy', // 앱 타이틀(안드로이드 최근앱 등)
      initialRoute: Routes.main, // 첫 진입 라우트 경로
      initialBinding: InitialBinding(), // 전역 바인딩 등록 (Auth 등)
      getPages: AppPages.pages, // 라우트 정의 목록
      theme: AppTheme.themeData,
    );
  }
}
