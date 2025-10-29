# AI Life Legacy - Test Suite

This directory contains comprehensive unit and widget tests for the AI Life Legacy application.

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/features/auth/data/auth_api_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Generate mocks (required before running tests)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Test Categories

### Unit Tests
- Core Config: Tests for environment configuration
- Core Network: Tests for Dio client and API endpoints
- Core Routes: Tests for route definitions and page mappings
- Auth Data Layer: Tests for auth API and repository
- Auth Presentation: Tests for auth controller and bindings
- Journal Presentation: Tests for journal controllers and bindings

### Widget Tests
- Login Page: UI tests for login screen
- Home Page: UI tests for home screen with chapter list
- Main Page: UI tests for landing page

## Testing Dependencies

- flutter_test: Flutter's testing framework
- mockito: Mocking library for creating test doubles
- build_runner: Code generation for mocks
- get: GetX includes testing utilities

## Next Steps

1. Run: flutter pub get
2. Run: flutter pub run build_runner build --delete-conflicting-outputs
3. Run: flutter test