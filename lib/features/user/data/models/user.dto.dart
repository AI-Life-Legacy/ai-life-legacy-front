import 'package:flutter/foundation.dart';
// 사용자 관련 DTO 모델

/// 사용자 목차(TOC) 정보를 담는 DTO
/// - API 응답의 'percent' 필드는 'percentage'로도 매핑될 수 있습니다.
class UserTocDto {
  final int id;
  final String title;
  final double percent;

  UserTocDto({
    required this.id,
    required this.title,
    required this.percent,
  });

  factory UserTocDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['tocId'];
    final rawTitle = json['title'] ?? json['tocTitle'];
    // percent 또는 percentage 필드 지원
    final rawPercent = json['percent'] ?? json['percentage'] ?? 0.0;

    if (rawId == null) {
      throw ArgumentError('UserTocDto: id/tocId is required.');
    }
    if (rawTitle == null) {
      throw ArgumentError('UserTocDto: title/tocTitle is required.');
    }

    return UserTocDto(
      id: rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0,
      title: rawTitle.toString(),
      percent: (rawPercent is num) ? rawPercent.toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'percent': percent,
    };
  }
}

/// 목차 및 하위 질문 목록을 포함하는 복합 DTO
class UserTocQuestionDto {
  final int tocId;
  final String tocTitle;
  final int orderIndex;
  final List<QuestionDto> questions;

  UserTocQuestionDto({
    required this.tocId,
    required this.tocTitle,
    required this.orderIndex,
    required this.questions,
  });

  factory UserTocQuestionDto.fromJson(Map<String, dynamic> json) {
    return UserTocQuestionDto(
      tocId: json['tocId'] as int,
      tocTitle: json['tocTitle'] as String,
      orderIndex: json['orderIndex'] as int,
      questions: (json['questions'] as List<dynamic>)
          .map((item) => QuestionDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tocId': tocId,
      'tocTitle': tocTitle,
      'orderIndex': orderIndex,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

/// 질문 DTO
class QuestionDto {
  final int id;
  final String questionText;

  QuestionDto({
    required this.id,
    required this.questionText,
  });

  factory QuestionDto.fromJson(Map<String, dynamic> json) {
    return QuestionDto(
      id: json['id'] as int? ?? 0,
      questionText: (json['questionText'] ?? json['question']) as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
    };
  }
}

/// 목차별 질문 조회 응답 DTO (Life Legacy API)
class TocQuestionDto {
  final int id;
  final String question;

  TocQuestionDto({
    required this.id,
    required this.question,
  });

  factory TocQuestionDto.fromJson(Map<String, dynamic> json) {
    final q = json['question'] ?? json['questionText'];
    if (q == null) {
      debugPrint('[TocQuestionDto] Warning: Missing question text in json: $json');
    }
    return TocQuestionDto(
      id: json['id'] as int? ?? 0,
      question: q?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
    };
  }
}

/// 답변 조회 응답 DTO
class UserAnswerDto {
  final int questionId;
  final String answerText;
  final int? answerId;

  UserAnswerDto({
    required this.questionId,
    required this.answerText,
    this.answerId,
  });

  factory UserAnswerDto.fromJson(Map<String, dynamic> json) {
    return UserAnswerDto(
      questionId: json['questionId'] as int? ?? 0,
      answerText: json['answerText'] as String? ?? '',
      answerId: json['answerId'] as int? ?? json['id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answerText': answerText,
      if (answerId != null) 'answerId': answerId,
    };
  }
}

/// 자기소개 저장 요청 DTO
class UserIntroDto {
  final String userIntroText;

  UserIntroDto({
    required this.userIntroText,
  });

  factory UserIntroDto.fromJson(Map<String, dynamic> json) {
    return UserIntroDto(
      userIntroText: json['userIntroText'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userIntroText': userIntroText,
    };
  }
}

/// 답변 저장 요청 DTO
class AnswerSaveDto {
  final String answer;

  AnswerSaveDto({
    required this.answer,
  });

  factory AnswerSaveDto.fromJson(Map<String, dynamic> json) {
    return AnswerSaveDto(
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
    };
  }
}

/// 답변 수정 요청 DTO
class AnswerUpdateDto {
  final int tocId;
  final int questionId;
  final String updateAnswer;

  AnswerUpdateDto({
    required this.tocId,
    required this.questionId,
    required this.updateAnswer,
  });

  factory AnswerUpdateDto.fromJson(Map<String, dynamic> json) {
    return AnswerUpdateDto(
      tocId: json['tocId'] as int,
      questionId: json['questionId'] as int,
      updateAnswer: json['updateAnswer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tocId': tocId,
      'questionId': questionId,
      'updateAnswer': updateAnswer,
    };
  }
}

/// 회원 탈퇴 요청 DTO
class UserWithdrawalDto {
  final String withdrawalReason;
  final String withdrawalText;

  UserWithdrawalDto({
    required this.withdrawalReason,
    required this.withdrawalText,
  });

  Map<String, dynamic> toJson() {
    return {
      'withdrawalReason': withdrawalReason,
      'withdrawalText': withdrawalText,
    };
  }
}

/// 유저 케이스 저장 요청 DTO
class UserCaseSaveDto {
  final String data;

  UserCaseSaveDto({
    required this.data,
  });

  factory UserCaseSaveDto.fromJson(Map<String, dynamic> json) {
    return UserCaseSaveDto(
      data: json['data'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
    };
  }
}
