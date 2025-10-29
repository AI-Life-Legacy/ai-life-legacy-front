import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/auth/presentation/pages/login_page.dart';
import 'package:ai_life_legacy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ai_life_legacy/features/auth/data/auth_repository.dart';

@GenerateMocks([AuthRepository])
import '../../data/auth_repository_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginPage Widget Tests', () {
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

    testWidgets('should render login page', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginPage(),
        ),
      );

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should display login title', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginPage(),
        ),
      );

      expect(find.text('로그인'), findsOneWidget);
    });

    testWidgets('should display email label', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginPage(),
        ),
      );

      expect(find.text('이메일'), findsWidgets);
    });

    testWidgets('should have email text field', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginPage(),
        ),
      );

      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);
    });

    testWidgets('should have email text field with placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginPage(),
        ),
      );

      expect(find.text('이메일을 입력해주세요.'), findsOneWidget);
    });

    testWidgets('should be wrapped in Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginPage(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginPage(),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should have SingleChildScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginPage(),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should accept text input in email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginPage(),
        ),
      );

      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('should have white background', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginPage(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.white));
    });
  });
}