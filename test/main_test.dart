import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/main.dart';
import 'package:ai_life_legacy/app/core/config/env.dart';
import 'package:ai_life_legacy/app/core/network/dio_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LegacyApp', () {
    setUp(() {
      Env.load();
      DioClient.init();
    });

    testWidgets('should create LegacyApp widget', (WidgetTester tester) async {
      await tester.pumpWidget(const LegacyApp());

      expect(find.byType(LegacyApp), findsOneWidget);
    });

    testWidgets('should use GetMaterialApp', (WidgetTester tester) async {
      await tester.pumpWidget(const LegacyApp());

      expect(find.byType(GetMaterialApp), findsOneWidget);
    });

    test('LegacyApp should be a StatelessWidget', () {
      const app = LegacyApp();
      expect(app, isA<StatelessWidget>());
    });

    testWidgets('should have proper app title', (WidgetTester tester) async {
      await tester.pumpWidget(const LegacyApp());

      final getMaterialApp = tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));
      expect(getMaterialApp.title, equals('AI Life Legacy'));
    });

    testWidgets('should hide debug banner', (WidgetTester tester) async {
      await tester.pumpWidget(const LegacyApp());

      final getMaterialApp = tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));
      expect(getMaterialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('should have theme configured', (WidgetTester tester) async {
      await tester.pumpWidget(const LegacyApp());

      final getMaterialApp = tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));
      expect(getMaterialApp.theme, isNotNull);
      expect(getMaterialApp.theme!.useMaterial3, isTrue);
    });

    testWidgets('should have color scheme', (WidgetTester tester) async {
      await tester.pumpWidget(const LegacyApp());

      final getMaterialApp = tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));
      expect(getMaterialApp.theme!.colorScheme, isNotNull);
    });

    testWidgets('should have initialRoute set', (WidgetTester tester) async {
      await tester.pumpWidget(const LegacyApp());

      final getMaterialApp = tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));
      expect(getMaterialApp.initialRoute, isNotNull);
      expect(getMaterialApp.initialRoute, equals('/'));
    });

    testWidgets('should have getPages defined', (WidgetTester tester) async {
      await tester.pumpWidget(const LegacyApp());

      final getMaterialApp = tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));
      expect(getMaterialApp.getPages, isNotNull);
      expect(getMaterialApp.getPages, isNotEmpty);
    });
  });

  group('main function', () {
    test('should be defined', () {
      expect(main, isA<Function>());
    });
  });
}