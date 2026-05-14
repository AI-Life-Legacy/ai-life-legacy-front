import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 로컬 스토리지 기반 토큰 관리 클래스 (SharedPreferences 사용)
class TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _uuidKey = 'uuid';
  
  static const _viewerAccessKey = 'viewerAccessToken';
  static const _viewerAuthorNameKey = 'viewerAuthorName';
  static const _viewerAuthorIntroKey = 'viewerAuthorIntro';
  static const _isViewerModeKey = 'isViewerMode';

  static SharedPreferences? _prefs;
  static String? _accessToken;
  static String? _refreshToken;
  static String? _uuid;
  
  static String? _viewerAccessToken;
  static String? _viewerAuthorName;
  static String? _viewerAuthorIntro;
  static bool? _isViewerMode;

  /// SharedPreferences 인스턴스를 초기화하고 캐시된 토큰을 로드합니다.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _accessToken = _prefs!.getString(_accessKey);
    _refreshToken = _prefs!.getString(_refreshKey);
    _uuid = _prefs!.getString(_uuidKey);
    
    _viewerAccessToken = _prefs!.getString(_viewerAccessKey);
    _viewerAuthorName = _prefs!.getString(_viewerAuthorNameKey);
    _viewerAuthorIntro = _prefs!.getString(_viewerAuthorIntroKey);
    _isViewerMode = _prefs!.getBool(_isViewerModeKey) ?? false;
  }

  static Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// AccessToken 저장
  static Future<void> saveAccessToken(String token) async {
    _accessToken = token;
    final prefs = await _ensurePrefs();
    await prefs.setString(_accessKey, token);
  }

  /// RefreshToken 저장
  static Future<void> saveRefreshToken(String token) async {
    _refreshToken = token;
    final prefs = await _ensurePrefs();
    await prefs.setString(_refreshKey, token);
  }

  /// AccessToken 조회
  static String? getAccessToken() {
    if (_accessToken != null) return _accessToken;
    return _prefs?.getString(_accessKey);
  }

  /// UUID 조회
  static String? getUuid() {
    if (_uuid != null) return _uuid;
    return _prefs?.getString(_uuidKey);
  }

  /// RefreshToken 조회
  static String? getRefreshToken() {
    if (_refreshToken != null) return _refreshToken;
    return _prefs?.getString(_refreshKey);
  }

  /// ViewerAccessToken 저장
  static Future<void> saveViewerAccessToken(String token) async {
    _viewerAccessToken = token;
    final prefs = await _ensurePrefs();
    await prefs.setString(_viewerAccessKey, token);
  }

  /// ViewerAccessToken 조회
  static String? getViewerAccessToken() {
    if (_viewerAccessToken != null) return _viewerAccessToken;
    return _prefs?.getString(_viewerAccessKey);
  }

  /// ViewerAuthorName 저장
  static Future<void> saveViewerAuthorName(String name) async {
    _viewerAuthorName = name;
    final prefs = await _ensurePrefs();
    await prefs.setString(_viewerAuthorNameKey, name);
  }

  /// ViewerAuthorName 조회
  static String? getViewerAuthorName() {
    if (_viewerAuthorName != null) return _viewerAuthorName;
    return _prefs?.getString(_viewerAuthorNameKey);
  }

  /// ViewerAuthorIntro 저장
  static Future<void> saveViewerAuthorIntro(String intro) async {
    _viewerAuthorIntro = intro;
    final prefs = await _ensurePrefs();
    await prefs.setString(_viewerAuthorIntroKey, intro);
  }

  /// ViewerAuthorIntro 조회
  static String? getViewerAuthorIntro() {
    if (_viewerAuthorIntro != null) return _viewerAuthorIntro;
    return _prefs?.getString(_viewerAuthorIntroKey);
  }

  /// Viewer Mode 여부 저장
  static Future<void> saveIsViewerMode(bool isViewer) async {
    _isViewerMode = isViewer;
    final prefs = await _ensurePrefs();
    await prefs.setBool(_isViewerModeKey, isViewer);
  }

  /// Viewer Mode 여부 조회
  static bool isViewerMode() {
    if (_isViewerMode != null) return _isViewerMode!;
    return _prefs?.getBool(_isViewerModeKey) ?? false;
  }

  /// 뷰어 세션 클리어 (뷰어 로그아웃 시 호출)
  static Future<void> clearViewerSession() async {
    _viewerAccessToken = null;
    _viewerAuthorName = null;
    _viewerAuthorIntro = null;
    _isViewerMode = false;
    final prefs = await _ensurePrefs();
    await prefs.remove(_viewerAccessKey);
    await prefs.remove(_viewerAuthorNameKey);
    await prefs.remove(_viewerAuthorIntroKey);
    await prefs.remove(_isViewerModeKey);
  }

  /// 저장된 모든 토큰 정보를 삭제합니다 (로그아웃 시 호출).
  static Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _uuid = null;
    final prefs = await _ensurePrefs();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_uuidKey);
    await clearViewerSession();
  }

  /// Access Token과 Refresh Token을 동시에 저장합니다.
  /// 토큰에서 UUID를 추출하여 별도 저장하는 로직이 포함되어 있습니다.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // 일반 작성자 로그인 시 기존 뷰어 세션 강제 종료
    await clearViewerSession();

    // JWT 디코딩 후 UUID 추출
    try {
      final parts = accessToken.split('.');
      if (parts.length == 3) {
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final resp = utf8.decode(base64Url.decode(normalized));
        final payloadMap = jsonDecode(resp);
        debugPrint('Decoded Token Payload: $payloadMap'); // Debug log

        if (payloadMap is Map<String, dynamic>) {
          // 'uuid' 필드 확인, 없으면 'sub' 등 대체 시도
          final uuid =
              payloadMap['uuid'] ?? payloadMap['sub'] ?? payloadMap['id'];
          debugPrint('Extracted UUID: $uuid'); // Debug log

          if (uuid != null) {
            _uuid = uuid.toString();
            final prefs = await _ensurePrefs();
            await prefs.setString(_uuidKey, _uuid!);
          }
        }
      }
    } catch (e) {
      // 토큰 디코딩 실패 시, 로그만 출력하고 흐름은 유지.
      debugPrint('Token decoding failed: $e');
    }

    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }
}
