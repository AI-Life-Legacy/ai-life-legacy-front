import 'package:flutter_test/flutter_test.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

void main() {
  group('Routes', () {
    test('main route should be root path', () {
      expect(Routes.main, equals('/'));
    });

    test('login route should be /login', () {
      expect(Routes.login, equals('/login'));
    });

    test('home route should be /home', () {
      expect(Routes.home, equals('/home'));
    });

    test('selfIntro route should be /self_intro', () {
      expect(Routes.selfIntro, equals('/self_intro'));
    });

    test('all routes should start with forward slash', () {
      expect(Routes.main, startsWith('/'));
      expect(Routes.login, startsWith('/'));
      expect(Routes.home, startsWith('/'));
      expect(Routes.selfIntro, startsWith('/'));
    });

    test('all routes should be non-empty strings', () {
      expect(Routes.main, isNotEmpty);
      expect(Routes.login, isNotEmpty);
      expect(Routes.home, isNotEmpty);
      expect(Routes.selfIntro, isNotEmpty);
    });

    test('routes should be unique', () {
      final routes = [
        Routes.main,
        Routes.login,
        Routes.home,
        Routes.selfIntro,
      ];
      
      final uniqueRoutes = routes.toSet();
      expect(uniqueRoutes.length, equals(routes.length));
    });

    test('routes should not contain spaces', () {
      expect(Routes.main.contains(' '), isFalse);
      expect(Routes.login.contains(' '), isFalse);
      expect(Routes.home.contains(' '), isFalse);
      expect(Routes.selfIntro.contains(' '), isFalse);
    });

    test('routes should use lowercase or snake_case', () {
      expect(Routes.login, equals(Routes.login.toLowerCase()));
      expect(Routes.home, equals(Routes.home.toLowerCase()));
      expect(Routes.selfIntro, equals(Routes.selfIntro.toLowerCase()));
    });

    test('routes should be const values', () {
      // This test ensures routes are compile-time constants
      const testMain = Routes.main;
      const testLogin = Routes.login;
      const testHome = Routes.home;
      const testSelfIntro = Routes.selfIntro;
      
      expect(testMain, equals('/'));
      expect(testLogin, equals('/login'));
      expect(testHome, equals('/home'));
      expect(testSelfIntro, equals('/self_intro'));
    });
  });
}