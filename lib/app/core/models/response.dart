/// 공통 API 응답 래퍼 클래스 정의
/// 공통 성공 응답 (200 OK)
class SuccessResponse<T> {
  final int status;
  final String message;
  final T data;

  SuccessResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  /// [json]은 서버 응답 원본, [fromJsonT]는 제네릭 타입 T의 생성자입니다.
  factory SuccessResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    // AI 서비스와 일반 서비스의 응답 필드 불일치 해결 ('result' vs 'data')
    // 만약 둘 다 없으면 전체 json을 데이터로 간주 (루트 레벨에 데이터가 있는 경우)
    final dataField = json['result'] ?? json['data'] ?? json;

    return SuccessResponse<T>(
      status: (json['status'] ?? json['statusCode']) as int,
      message: json['message'] as String,
      data: fromJsonT(dataField),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}

/// 201 Created 응답
class Success201Response<T> {
  final int status;
  final String message;
  final T data;

  Success201Response({
    required this.status,
    required this.message,
    required this.data,
  });

  factory Success201Response.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final dataField = json['result'] ?? json['data'];
    return Success201Response<T>(
      status: (json['status'] ?? json['statusCode']) as int,
      message: json['message'] as String,
      data: fromJsonT(dataField),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}

/// 204 No Content 응답 (데이터가 없는 성공 응답)
class Success204Response {
  final int status;
  final String message;
  final dynamic data;

  Success204Response({
    required this.status,
    required this.message,
    this.data,
  });

  factory Success204Response.fromJson(Map<String, dynamic> json) {
    return Success204Response(
      status: (json['status'] ?? json['statusCode']) as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}

/// 에러 응답
class ErrorResponse {
  final int status;
  final String message;
  final dynamic data;

  ErrorResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      status: (json['status'] ?? json['statusCode']) as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}
