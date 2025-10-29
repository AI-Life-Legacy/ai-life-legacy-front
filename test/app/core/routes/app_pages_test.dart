import 'package:flutter_test/flutter_test.dart';
import 'package:ai_life_legacy/app/core/routes/app_pages.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:get/get.dart';

void main() {
  group('AppPages', () {
    test('pages should not be null', () {
      expect(AppPages.pages, isNotNull);
    });

    test('pages should not be empty', () {
      expect(AppPages.pages, isNotEmpty);
    });

    test('pages should be a list of GetPage', () {
      expect(AppPages.pages, isA<List<GetPage>>());
      for (final page in AppPages.pages) {
        expect(page, isA<GetPage>());
      }
    });

    test('pages should contain main route', () {
      final mainPage = AppPages.pages.firstWhere(
        (page) => page.name == Routes.main,
        orElse: () => throw Exception('Main route not found'),
      );
      expect(mainPage.name, equals(Routes.main));
    });

    test('pages should contain login route', () {
      final loginPage = AppPages.pages.firstWhere(
        (page) => page.name == Routes.login,
        orElse: () => throw Exception('Login route not found'),
      );
      expect(loginPage.name, equals(Routes.login));
    });

    test('pages should contain home route', () {
      final homePage = AppPages.pages.firstWhere(
        (page) => page.name == Routes.home,
        orElse: () => throw Exception('Home route not found'),
      );
      expect(homePage.name, equals(Routes.home));
    });

    test('pages should contain selfIntro route', () {
      final selfIntroPage = AppPages.pages.firstWhere(
        (page) => page.name == Routes.selfIntro,
        orElse: () => throw Exception('SelfIntro route not found'),
      );
      expect(selfIntroPage.name, equals(Routes.selfIntro));
    });

    test('all pages should have unique names', () {
      final names = AppPages.pages.map((page) => page.name).toList();
      final uniqueNames = names.toSet();
      expect(uniqueNames.length, equals(names.length));
    });

    test('all pages should have bindings', () {
      for (final page in AppPages.pages) {
        expect(page.binding != null || page.bindings != null, isTrue,
            reason: 'Page ${page.name} should have bindings');
      }
    });

    test('main page should have AuthBinding', () {
      final mainPage = AppPages.pages.firstWhere((page) => page.name == Routes.main);
      expect(mainPage.binding, isNotNull);
    });

    test('login page should have AuthBinding', () {
      final loginPage = AppPages.pages.firstWhere((page) => page.name == Routes.login);
      expect(loginPage.binding, isNotNull);
    });

    test('home page should have multiple bindings', () {
      final homePage = AppPages.pages.firstWhere((page) => page.name == Routes.home);
      expect(homePage.bindings, isNotNull);
      expect(homePage.bindings!.length, greaterThan(1));
    });

    test('selfIntro page should have multiple bindings', () {
      final selfIntroPage = AppPages.pages.firstWhere((page) => page.name == Routes.selfIntro);
      expect(selfIntroPage.bindings, isNotNull);
      expect(selfIntroPage.bindings!.length, greaterThan(1));
    });

    test('page count should match expected routes', () {
      expect(AppPages.pages.length, equals(4));
    });
  });
}