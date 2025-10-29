import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/journal/presentation/bindings.dart';
import 'package:ai_life_legacy/features/journal/presentation/controllers/journal_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JournalBinding', () {
    late JournalBinding binding;

    setUp(() {
      Get.testMode = true;
      binding = JournalBinding();
    });

    tearDown(() {
      Get.reset();
    });

    test('should extend Bindings', () {
      expect(binding, isA<Bindings>());
    });

    test('should register JournalController', () {
      binding.dependencies();
      
      expect(Get.isRegistered<JournalController>(), isTrue);
    });

    test('should register SelfIntroController', () {
      binding.dependencies();
      
      expect(Get.isRegistered<SelfIntroController>(), isTrue);
    });

    test('should register all dependencies', () {
      binding.dependencies();
      
      final journalController = Get.find<JournalController>();
      final selfIntroController = Get.find<SelfIntroController>();
      
      expect(journalController, isA<JournalController>());
      expect(selfIntroController, isA<SelfIntroController>());
    });

    test('should use lazyPut for dependencies', () {
      // Dependencies should not be instantiated yet
      expect(Get.isRegistered<JournalController>(), isFalse);
      
      binding.dependencies();
      
      // After binding, they should be registered
      expect(Get.isRegistered<JournalController>(), isTrue);
    });

    test('dependencies should be singletons within scope', () {
      binding.dependencies();
      
      final controller1 = Get.find<JournalController>();
      final controller2 = Get.find<JournalController>();
      
      expect(identical(controller1, controller2), isTrue);
    });

    test('should handle multiple dependencies() calls', () {
      binding.dependencies();
      binding.dependencies();
      
      expect(Get.isRegistered<JournalController>(), isTrue);
      expect(Get.isRegistered<SelfIntroController>(), isTrue);
    });

    test('should properly instantiate both controllers', () {
      binding.dependencies();
      
      final journalController = Get.find<JournalController>();
      final selfIntroController = Get.find<SelfIntroController>();
      
      // Verify controllers are properly initialized
      expect(journalController.chapters, isNotEmpty);
      expect(journalController.selectedTabIndex.value, equals(0));
      
      expect(selfIntroController.messages, isEmpty);
      expect(selfIntroController.isRecording.value, isFalse);
    });

    test('JournalController should have reactive state', () {
      binding.dependencies();
      
      final controller = Get.find<JournalController>();
      
      expect(controller.chapters, isA<RxList<ChapterModel>>());
      expect(controller.selectedTabIndex, isA<RxInt>());
    });

    test('SelfIntroController should have reactive state', () {
      binding.dependencies();
      
      final controller = Get.find<SelfIntroController>();
      
      expect(controller.messages, isA<RxList<ChatMessage>>());
      expect(controller.isRecording, isA<RxBool>());
      expect(controller.recordingSeconds, isA<RxInt>());
    });
  });
}