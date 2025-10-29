import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/main/presentation/pages/main_page.dart';
import 'package:ai_life_legacy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ai_life_legacy/features/auth/data/auth_repository.dart';

@GenerateMocks([AuthRepository])
import '../../../auth/data/auth_repository_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MainPage Widget Tests', () {
    late MockAuthRepository mockRepository;
    late AuthController authController;

    setUp(() {
      Get.testMode = true;
      mockRepository = MockAuthRepository();
      when(mockRepository.checkSession()).thenAnswer((_) async => false);
      authController = AuthController(mockRepository);
      Get.put<AuthController>(authController);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('should render main page', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: MainPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MainPage), findsOneWidget);
    });

    testWidgets('should display LIFE LEGACY title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: MainPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LIFE LEGACY'), findsOneWidget);
    });

    testWidgets('should have Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: MainPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: MainPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should have FadeTransition for animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: MainPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FadeTransition), findsOneWidget);
    });

    testWidgets('should display buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: MainPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should have proper background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: MainPage(),
        ),
      );
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.grey[100]));
    });

    testWidgets('should be a StatefulWidget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: MainPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MainPage), findsOneWidget);
      // MainPage should be StatefulWidget
      final mainPageWidget = tester.widget<MainPage>(find.byType(MainPage));
      expect(mainPageWidget, isA<StatefulWidget>());
    });

    testWidgets('should animate on init', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: MainPage(),
        ),
      );

      // Initially, animation should be starting
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MainPage), findsOneWidget);

      // After animation completes
      await tester.pumpAndSettle();
      expect(find.byType(MainPage), findsOneWidget);
    });
  });
}