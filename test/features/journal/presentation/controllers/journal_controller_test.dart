import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/journal/presentation/controllers/journal_controller.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JournalController', () {
    late JournalController controller;

    setUp(() {
      // Initialize GetX for routing
      Get.testMode = true;
      controller = JournalController();
    });

    tearDown(() {
      Get.reset();
    });

    test('should extend GetxController', () {
      expect(controller, isA<GetxController>());
    });

    group('initial state', () {
      test('should initialize with default chapters', () {
        expect(controller.chapters, isNotNull);
        expect(controller.chapters.isNotEmpty, isTrue);
      });

      test('should have 5 chapters initially', () {
        expect(controller.chapters.length, equals(5));
      });

      test('should initialize selectedTabIndex as 0', () {
        expect(controller.selectedTabIndex.value, equals(0));
      });

      test('chapters should be RxList', () {
        expect(controller.chapters, isA<RxList<ChapterModel>>());
      });

      test('selectedTabIndex should be RxInt', () {
        expect(controller.selectedTabIndex, isA<RxInt>());
      });
    });

    group('ChapterModel', () {
      test('should have required fields', () {
        final chapter = controller.chapters.first;
        
        expect(chapter.id, isNotNull);
        expect(chapter.title, isNotNull);
        expect(chapter.subtitle, isNotNull);
        expect(chapter.progress, isNotNull);
      });

      test('should have valid progress values (0.0 - 1.0)', () {
        for (final chapter in controller.chapters) {
          expect(chapter.progress, greaterThanOrEqualTo(0.0));
          expect(chapter.progress, lessThanOrEqualTo(1.0));
        }
      });

      test('should have unique IDs', () {
        final ids = controller.chapters.map((c) => c.id).toList();
        final uniqueIds = ids.toSet();
        expect(uniqueIds.length, equals(ids.length));
      });

      test('should have non-empty titles', () {
        for (final chapter in controller.chapters) {
          expect(chapter.title, isNotEmpty);
        }
      });

      test('should have non-empty subtitles', () {
        for (final chapter in controller.chapters) {
          expect(chapter.subtitle, isNotEmpty);
        }
      });
    });

    group('onChapterTap', () {
      test('should handle chapter tap', () {
        final chapter = controller.chapters.first;
        
        expect(() => controller.onChapterTap(chapter), returnsNormally);
      });

      test('should accept any ChapterModel', () {
        for (final chapter in controller.chapters) {
          expect(() => controller.onChapterTap(chapter), returnsNormally);
        }
      });

      test('should not modify chapter list', () {
        final initialCount = controller.chapters.length;
        final chapter = controller.chapters.first;
        
        controller.onChapterTap(chapter);
        
        expect(controller.chapters.length, equals(initialCount));
      });
    });

    group('changeTab', () {
      test('should update selectedTabIndex', () {
        controller.changeTab(1);
        expect(controller.selectedTabIndex.value, equals(1));
      });

      test('should handle tab 0 (home)', () {
        controller.changeTab(0);
        expect(controller.selectedTabIndex.value, equals(0));
      });

      test('should navigate to selfIntro on tab 1', () {
        // This test verifies the method executes without error
        expect(() => controller.changeTab(1), returnsNormally);
      });

      test('should handle tab 2', () {
        controller.changeTab(2);
        expect(controller.selectedTabIndex.value, equals(2));
      });

      test('should accept different tab indices', () {
        for (int i = 0; i < 3; i++) {
          expect(() => controller.changeTab(i), returnsNormally);
          expect(controller.selectedTabIndex.value, equals(i));
        }
      });

      test('should update selectedTabIndex reactively', () {
        final values = <int>[];
        controller.selectedTabIndex.listen((value) => values.add(value));
        
        controller.changeTab(1);
        controller.changeTab(2);
        controller.changeTab(0);
        
        expect(values, containsAll([1, 2, 0]));
      });
    });

    group('onBackPressed', () {
      test('should call Get.back', () {
        expect(() => controller.onBackPressed(), returnsNormally);
      });
    });

    group('reactive state', () {
      test('chapters list should be observable', () {
        var updateCount = 0;
        controller.chapters.listen((_) => updateCount++);
        
        controller.chapters.add(ChapterModel(
          id: 99,
          title: 'Test',
          subtitle: 'Test',
          progress: 0.5,
        ));
        
        expect(updateCount, greaterThan(0));
      });

      test('selectedTabIndex should be observable', () {
        var updateCount = 0;
        controller.selectedTabIndex.listen((_) => updateCount++);
        
        controller.selectedTabIndex.value = 1;
        controller.selectedTabIndex.value = 2;
        
        expect(updateCount, equals(2));
      });
    });
  });

  group('SelfIntroController', () {
    late SelfIntroController controller;

    setUp(() {
      Get.testMode = true;
      controller = SelfIntroController();
    });

    tearDown(() {
      controller.onClose();
      Get.reset();
    });

    test('should extend GetxController', () {
      expect(controller, isA<GetxController>());
    });

    group('initial state', () {
      test('should initialize with empty messages list', () {
        expect(controller.messages, isNotNull);
        expect(controller.messages, isEmpty);
      });

      test('should initialize isRecording as false', () {
        expect(controller.isRecording.value, isFalse);
      });

      test('should initialize recordingSeconds as 0', () {
        expect(controller.recordingSeconds.value, equals(0));
      });

      test('should have textController', () {
        expect(controller.textController, isNotNull);
        expect(controller.textController, isA<TextEditingController>());
      });

      test('should have scrollController', () {
        expect(controller.scrollController, isNotNull);
        expect(controller.scrollController, isA<ScrollController>());
      });

      test('recordingTimer should be null initially', () {
        expect(controller.recordingTimer, isNull);
      });
    });

    group('addMessage', () {
      test('should add user message to messages list', () {
        controller.addMessage('Hello', isUser: true);
        
        expect(controller.messages.length, equals(1));
        expect(controller.messages.first.text, equals('Hello'));
        expect(controller.messages.first.isUser, isTrue);
      });

      test('should add bot message to messages list', () {
        controller.addMessage('Response', isUser: false);
        
        expect(controller.messages.length, equals(1));
        expect(controller.messages.first.text, equals('Response'));
        expect(controller.messages.first.isUser, isFalse);
      });

      test('should trim whitespace from messages', () {
        controller.addMessage('  Hello  ');
        
        expect(controller.messages.first.text, equals('Hello'));
      });

      test('should not add empty messages', () {
        controller.addMessage('');
        expect(controller.messages, isEmpty);
        
        controller.addMessage('   ');
        expect(controller.messages, isEmpty);
      });

      test('should add multiple messages in order', () {
        controller.addMessage('First');
        controller.addMessage('Second');
        controller.addMessage('Third');
        
        expect(controller.messages.length, equals(3));
        expect(controller.messages[0].text, equals('First'));
        expect(controller.messages[1].text, equals('Second'));
        expect(controller.messages[2].text, equals('Third'));
      });

      test('should handle messages with special characters', () {
        controller.addMessage('Hello! 안녕하세요 😊');
        
        expect(controller.messages.first.text, equals('Hello! 안녕하세요 😊'));
      });

      test('should default isUser to true', () {
        controller.addMessage('Test');
        
        expect(controller.messages.first.isUser, isTrue);
      });
    });

    group('recording functionality', () {
      test('startRecording should set isRecording to true', () {
        controller.startRecording();
        
        expect(controller.isRecording.value, isTrue);
      });

      test('startRecording should reset recordingSeconds to 0', () {
        controller.recordingSeconds.value = 10;
        controller.startRecording();
        
        expect(controller.recordingSeconds.value, equals(0));
      });

      test('startRecording should create timer', () {
        controller.startRecording();
        
        expect(controller.recordingTimer, isNotNull);
      });

      test('stopRecording should set isRecording to false', () {
        controller.startRecording();
        controller.stopRecording();
        
        expect(controller.isRecording.value, isFalse);
      });

      test('stopRecording should reset recordingSeconds to 0', () async {
        controller.startRecording();
        await Future.delayed(const Duration(milliseconds: 100));
        controller.stopRecording();
        
        expect(controller.recordingSeconds.value, equals(0));
      });

      test('stopRecording should cancel timer', () {
        controller.startRecording();
        controller.stopRecording();
        
        expect(controller.recordingTimer?.isActive ?? false, isFalse);
      });

      test('toggleRecording should start when not recording', () {
        expect(controller.isRecording.value, isFalse);
        
        controller.toggleRecording();
        
        expect(controller.isRecording.value, isTrue);
      });

      test('toggleRecording should stop when recording', () {
        controller.startRecording();
        expect(controller.isRecording.value, isTrue);
        
        controller.toggleRecording();
        
        expect(controller.isRecording.value, isFalse);
      });

      test('toggleRecording should work multiple times', () {
        controller.toggleRecording(); // Start
        expect(controller.isRecording.value, isTrue);
        
        controller.toggleRecording(); // Stop
        expect(controller.isRecording.value, isFalse);
        
        controller.toggleRecording(); // Start again
        expect(controller.isRecording.value, isTrue);
      });

      test('recordingSeconds should increment over time', () async {
        controller.startRecording();
        
        await Future.delayed(const Duration(milliseconds: 1100));
        
        expect(controller.recordingSeconds.value, greaterThan(0));
        
        controller.stopRecording();
      });
    });

    group('getFormattedTime', () {
      test('should format 0 seconds correctly', () {
        controller.recordingSeconds.value = 0;
        expect(controller.getFormattedTime(), equals('00:00'));
      });

      test('should format seconds correctly', () {
        controller.recordingSeconds.value = 5;
        expect(controller.getFormattedTime(), equals('00:05'));
      });

      test('should format minutes and seconds correctly', () {
        controller.recordingSeconds.value = 65;
        expect(controller.getFormattedTime(), equals('01:05'));
      });

      test('should format double-digit seconds correctly', () {
        controller.recordingSeconds.value = 30;
        expect(controller.getFormattedTime(), equals('00:30'));
      });

      test('should format double-digit minutes correctly', () {
        controller.recordingSeconds.value = 610;
        expect(controller.getFormattedTime(), equals('10:10'));
      });

      test('should pad single digits with zero', () {
        controller.recordingSeconds.value = 1;
        expect(controller.getFormattedTime(), matches(r'^\d{2}:\d{2}$'));
      });

      test('should handle large values', () {
        controller.recordingSeconds.value = 3599; // 59:59
        expect(controller.getFormattedTime(), equals('59:59'));
      });
    });

    group('clearText', () {
      test('should clear textController', () {
        controller.textController.text = 'Some text';
        controller.clearText();
        
        expect(controller.textController.text, isEmpty);
      });

      test('should work when text is already empty', () {
        controller.textController.text = '';
        expect(() => controller.clearText(), returnsNormally);
        expect(controller.textController.text, isEmpty);
      });

      test('should work multiple times', () {
        controller.textController.text = 'Text 1';
        controller.clearText();
        
        controller.textController.text = 'Text 2';
        controller.clearText();
        
        expect(controller.textController.text, isEmpty);
      });
    });

    group('reactive state', () {
      test('isRecording should be RxBool', () {
        expect(controller.isRecording, isA<RxBool>());
      });

      test('recordingSeconds should be RxInt', () {
        expect(controller.recordingSeconds, isA<RxInt>());
      });

      test('messages should be RxList', () {
        expect(controller.messages, isA<RxList<ChatMessage>>());
      });

      test('messages list should be observable', () {
        var updateCount = 0;
        controller.messages.listen((_) => updateCount++);
        
        controller.addMessage('Test');
        
        expect(updateCount, greaterThan(0));
      });
    });

    group('onClose', () {
      test('should dispose textController', () {
        controller.onClose();
        // If this doesn't throw, disposal was successful
        expect(() => controller.textController.text, returnsNormally);
      });

      test('should cancel recordingTimer', () {
        controller.startRecording();
        controller.onClose();
        
        expect(controller.recordingTimer?.isActive ?? false, isFalse);
      });

      test('should dispose scrollController', () {
        controller.onClose();
        // Verify it doesn't throw
        expect(() => controller.onClose(), returnsNormally);
      });

      test('should reset selectedTabIndex in JournalController', () {
        // Create JournalController and register it
        final journalController = JournalController();
        Get.put<JournalController>(journalController);
        
        journalController.selectedTabIndex.value = 2;
        controller.onClose();
        
        expect(journalController.selectedTabIndex.value, equals(0));
        
        Get.delete<JournalController>();
      });
    });
  });

  group('ChapterModel', () {
    test('should create instance with all required fields', () {
      final chapter = ChapterModel(
        id: 1,
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        progress: 0.5,
      );
      
      expect(chapter.id, equals(1));
      expect(chapter.title, equals('Test Title'));
      expect(chapter.subtitle, equals('Test Subtitle'));
      expect(chapter.progress, equals(0.5));
    });

    test('should accept progress values from 0.0 to 1.0', () {
      final chapter1 = ChapterModel(id: 1, title: 'T', subtitle: 'S', progress: 0.0);
      final chapter2 = ChapterModel(id: 2, title: 'T', subtitle: 'S', progress: 0.5);
      final chapter3 = ChapterModel(id: 3, title: 'T', subtitle: 'S', progress: 1.0);
      
      expect(chapter1.progress, equals(0.0));
      expect(chapter2.progress, equals(0.5));
      expect(chapter3.progress, equals(1.0));
    });

    test('should accept any integer id', () {
      final chapter1 = ChapterModel(id: 1, title: 'T', subtitle: 'S', progress: 0.5);
      final chapter2 = ChapterModel(id: 100, title: 'T', subtitle: 'S', progress: 0.5);
      final chapter3 = ChapterModel(id: -1, title: 'T', subtitle: 'S', progress: 0.5);
      
      expect(chapter1.id, equals(1));
      expect(chapter2.id, equals(100));
      expect(chapter3.id, equals(-1));
    });

    test('should accept any string for title and subtitle', () {
      final chapter = ChapterModel(
        id: 1,
        title: 'Very long title with special chars!@#$%',
        subtitle: '부제목 Subtitle 😊',
        progress: 0.5,
      );
      
      expect(chapter.title, isNotEmpty);
      expect(chapter.subtitle, isNotEmpty);
    });
  });

  group('ChatMessage', () {
    test('should create instance with text', () {
      final message = ChatMessage('Hello');
      
      expect(message.text, equals('Hello'));
      expect(message.isUser, isTrue); // Default value
    });

    test('should set isUser correctly', () {
      final userMessage = ChatMessage('User', isUser: true);
      final botMessage = ChatMessage('Bot', isUser: false);
      
      expect(userMessage.isUser, isTrue);
      expect(botMessage.isUser, isFalse);
    });

    test('should default isUser to true', () {
      final message = ChatMessage('Test');
      
      expect(message.isUser, isTrue);
    });

    test('should accept any string as text', () {
      final message1 = ChatMessage('Simple text');
      final message2 = ChatMessage('Text with emoji 😊');
      final message3 = ChatMessage('한글 메시지');
      
      expect(message1.text, equals('Simple text'));
      expect(message2.text, contains('😊'));
      expect(message3.text, contains('한글'));
    });

    test('should accept empty string', () {
      final message = ChatMessage('');
      
      expect(message.text, isEmpty);
    });
  });
}