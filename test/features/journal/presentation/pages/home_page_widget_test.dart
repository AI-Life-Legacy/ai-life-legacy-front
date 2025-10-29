import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/journal/presentation/pages/home_page.dart';
import 'package:ai_life_legacy/features/journal/presentation/controllers/journal_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomePage Widget Tests', () {
    late JournalController journalController;

    setUp(() {
      Get.testMode = true;
      journalController = JournalController();
      Get.put<JournalController>(journalController);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('should render home page', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('나의 자서전'), findsOneWidget);
    });

    testWidgets('should have Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display chapter cards in ListView', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display all chapters', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      // Should display chapter cards
      expect(find.textContaining('Chapter'), findsWidgets);
    });

    testWidgets('should have bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should handle chapter tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      final chapterCard = find.byType(InkWell).first;
      await tester.tap(chapterCard);
      await tester.pumpAndSettle();

      // Should not throw error
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display chapter titles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      for (final chapter in journalController.chapters) {
        expect(find.text(chapter.title), findsOneWidget);
      }
    });

    testWidgets('should have proper background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomePage(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(const Color(0xFFF5F5F5)));
    });
  });
}