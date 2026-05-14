/// API 엔드포인트 URL 상수 관리 클래스
library;

class ApiEndpoints {
  // 루트 API
  static const healthCheck = '/';

  // Auth (인증)
  static const signUp = '/auth/signup';
  static const login = '/auth/login';
  static const refreshToken = '/auth/refresh-token';

  // User (유저)
  static const userIntro = '/users/me/intro'; // POST
  static const userToc = '/users/me/toc'; // GET
  static const userTocQuestions = '/users/me/toc-questions'; // GET
  static const userAnswers = '/users/me/answers'; // GET
  static String userAnswerUpdate(int answerId) =>
      '/users/me/answers/$answerId'; // PATCH
  static const deleteUser = '/users/me'; // DELETE
  static const profile = '/users/me'; // GET
  static const viewerCode = '/users/me/viewer-code'; // GET

  // Life Legacy (자서전)
  static String lifeLegacyQuestions(int tocId) =>
      '/life-legacy/toc/$tocId/questions'; // GET
  static String lifeLegacyAnswer(int tocId, int questionId) =>
      '/life-legacy/toc/$tocId/questions/$questionId/answers'; // POST

  // AI (인공지능)
  static const aiCase = '/api/case'; // POST
  static const aiSync = '/api/sync'; // POST
  static const aiQuestion = '/api/question'; // POST
  static const aiAutobiography = '/api/autobiography'; // POST
  static const aiChat = '/api/chat'; // POST
  static const aiSearch = '/api/search'; // POST
}
