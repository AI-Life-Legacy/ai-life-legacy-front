# Frontend API Connection 명세

프론트엔드 프로젝트(`d:\DEV\projects\ai-life-legacy-front`)에서 실제로 호출하는 백엔드/AI 서버 API의 연결 현황입니다. 실제 프론트엔드 코드(Controller 및 API 클래스)를 기준으로 분석되었습니다.

## 1. API 호출 클래스 목록

`lib/features/*/data/` 및 `lib/app/core/ai/` 경로에 존재하는 실제 API 클래스들입니다.

- `ViewerApi`: 뷰어 코드 검증 및 뷰어 전용 API (`lib/features/viewer/data/viewer_api.dart`)
- `UserApi`: 사용자 자기소개, 답변 조회/수정, 회원 탈퇴 (`lib/features/user/data/user_api.dart`)
- `OnboardingApi`: 초기 온보딩 질문/답변 저장 및 케이스 분석 (`lib/features/onboarding/data/onboarding_api.dart`)
- `AvatarChatApi`: 아바타 AI 채팅, 원문 검색, 뷰어 코드 조회 (`lib/features/avatar_chat/data/avatar_chat_api.dart`)
- `HomeApi`: 목차 및 진행률 통계 조회 (`lib/features/home/data/home_api.dart`)
- `AutobiographyApi`: 자서전 질문 목록, 답변 저장, 꼬리 질문 생성, 자서전 PDF 생성 및 상태 조회 (`lib/features/autobiography/data/autobiography_api.dart`)
- `AuthApi`: 회원가입, 로그인, 세션/토큰 관리 (`lib/features/auth/data/auth_api.dart`)
- `AiApi`: AI 전용 공통 API (케이스 분석, 동기화, 질문 생성, 자서전 생성, 채팅) (`lib/app/core/ai/ai_api.dart`)

---

## 2. API 연결 표

| 기능 | Method | Endpoint | 호출 파일 (Controller) | Request Body / Query | Response 활용 필드 | 성공 처리 | 실패 처리 |
|---|---|---|---|---|---|---|---|
| **회원가입** | POST | `/auth/signup` | `auth_controller.dart` | `email`, `password` | `accessToken`, `refreshToken` | `200/201` 성공시 토큰 저장 및 온보딩 이동 | 에러 스낵바 표출 (409시 중복 이메일 알림) |
| **로그인** | POST | `/auth/login` | `auth_controller.dart` | `email`, `password` | `accessToken`, `refreshToken` | `200/201` 성공시 토큰 저장 및 홈 이동 | "이메일 또는 비밀번호 확인" 알림 |
| **뷰어 로그인** | POST | `/auth/viewer-login` | `viewer_controller.dart` | `viewerCode` | `accessToken`, `authorInfo` | `viewerAccessToken` 및 작성자 정보 저장 후 뷰어 채팅 이동 | "유효하지 않은 코드입니다" 표출 |
| **자기소개 저장** | POST | `/users/me/intro` | `self_intro_controller.dart`, `onboarding_controller.dart` | `userIntroText` | - | 온보딩 진행 및 유저 케이스 생성 API 호출 | 저장 실패 알림 |
| **케이스 생성 (분석)**| POST | `/api/case` | `self_intro_controller.dart`, `onboarding_controller.dart` | `data` | `caseName` | 생성된 케이스를 활용해 다음 라우트 인자로 전달 | 무시 또는 에러 알림 |
| **기억 동기화** | POST | `/api/sync` | `self_intro_controller.dart` | `content` | - | 별도 동작 없음 (백그라운드 동기화) | 무시 (조용히 진행) |
| **목차/진행도 조회** | GET | `/users/me/toc` | `home_controller.dart`, `my_page_controller.dart` | - | `totalChapters`, `completedChapters`, `progressPercent`, `chapters` | 각 장별 질문수/완료수 파싱하여 UI 프로그래스바 갱신 | "목차를 불러오는 데 실패했습니다" |
| **목차 질문 조회** | GET | `/life-legacy/toc/:tocId/questions` | `autobiography_controller.dart`, `self_intro_controller.dart` | (Path Parameter) | - | 질문 목록(`questions`) 리스트 상태 업데이트 | "질문을 불러오지 못했습니다" 말풍선 |
| **답변 저장** | POST | `/life-legacy/toc/:tocId/questions/:questionId/answers`| `autobiography_controller.dart`, `self_intro_controller.dart` | `answer` | - | "저장했어요. 다음 질문으로 넘어갈게요" 말풍선 | "저장 중 문제가 발생했어요." 알림 |
| **꼬리 질문 생성** | POST | `/api/question` | `autobiography_controller.dart`, `self_intro_controller.dart` | `question`, `data` | `question`, `message` | AI 응답 파싱하여 추가 질문 말풍선으로 표시 | 스킵 후 다음 고정 질문으로 강제 이동 |
| **단일 답변 조회** | GET | `/users/me/answers` | `autobiography_write_controller.dart` | `?questionId=...&tocId=...` | `answerId`, `answer` (또는 `answerText`) | `answerText` 컨트롤러에 반영해 수정 UI 표시 | "답변을 불러오지 못했어요." 알림 |
| **단일 답변 수정** | PATCH | `/users/me/answers/:answerId` | `autobiography_write_controller.dart` | `updateAnswer`, `tocId`, `questionId`| - | 수정 성공 처리 및 이전 화면 복귀 (`Get.back(true)`) | "답변 저장에 실패했어요." 알림 |
| **자서전 PDF 생성** | POST | `/api/autobiography` | `autobiography_controller.dart` | `?force=true` (강제시) | `status`, `pdfUrl`, `pageCount`, `cached`| 생성 완료시 로컬 상태 갱신 및 아바타 잠금 해제 | 시간 초과/실패 알림 처리 |
| **자서전 상태 조회** | GET | `/api/autobiography/status` | `autobiography_controller.dart` | - | `status`, `pdfUrl`, `pageCount`, `generatedAt` | `COMPLETED` 혹은 `pdfUrl` 존재 시 아바타 잠금 해제 | `generated=false`로 로컬 상태 초기화 |
| **아바타 채팅 전송**| POST | `/api/chat` | `avatar_chat_controller.dart` | `message`, `role`, `role_id`, `session_id` | `answer`, `sessionId`, `contextUsed` | `result['answer']`를 파싱하여 AI 말풍선 추가 및 `sessionId` 갱신 | "아바타 응답을 불러오지 못했습니다" 말풍선 |
| **공유 코드 발급** | GET | `/users/me/viewer-code` | `avatar_chat_controller.dart` | - | `code` | UI에 6자리 공유 코드 렌더링 | "공유 코드를 생성하지 못했습니다." 에러 |
| **회원 탈퇴** | DELETE | `/users/me` | `my_page_controller.dart` | `withdrawalReason`, `withdrawalText` | - | 로컬 토큰 완전 삭제 및 로그인 화면 이동 | "회원 탈퇴에 실패했습니다" 알림 |

---

## 3. 토큰 처리

- **`accessToken`이 붙는 API (작성자)**: 
  일반적인 `DioClient.instance` 및 `ApiProvider`를 사용하는 `/users/me/*`, `/life-legacy/*`, `/api/*` 경로의 API들. (`TokenStorage.isViewerMode()`가 `false`일 때 동작)
- **`viewerAccessToken`이 붙는 API (뷰어)**: 
  뷰어 로그인(`POST /auth/viewer-login`) 성공 후 발급받은 토큰. 뷰어 모드 진입 시 인터셉터에서 자동으로 헤더에 `viewerAccessToken`을 주입하며, 뷰어는 주로 `/api/chat` 등의 API에 접근 가능.
- **Authorization을 생략하는 퍼블릭 API**:
  `/auth/login`, `/auth/signup`, `/auth/viewer-login`, `/auth/refresh-token` 등 인증이 필요한 API는 프론트엔드 네트워크 계층에서 인증 헤더를 생략함.
- **뷰어 모드(viewerMode)일 때 호출 제한되는 로직**:
  - `HomeController.fetchToc`: 뷰어 모드일 때는 목차 동기화를 시도하지 않고 즉시 반환(return).
  - `AvatarChatController`: 라우팅(URL) 및 `TokenStorage.isViewerMode()` 상태에 따라 작성자 전용 채팅화면(`/avatar_chat`)과 뷰어 전용 채팅화면(`/viewer_chat`)의 상호 무단 접근을 차단함.

---

## 4. 특이사항

- **`statusCode` 201 성공 처리**: 프론트엔드의 대부분 컨트롤러는 POST/PATCH 요청 후 `response.statusCode == 200 || response.statusCode == 201`을 모두 성공으로 간주하여 처리함.
- **`force=true` 사용**: 자서전 생성 도중 에러가 나거나 강제 재생성이 필요한 경우 `generateAutobiography(force: true)`를 호출해 쿼리 파라미터로 백엔드에 전달함.
- **`pdfUrl` 및 `pageCount` 데이터 파싱**: 자서전 생성 및 상태 조회 API 응답에서 `pdfUrl`(혹은 `pdf_url`)과 `pageCount`(혹은 `page_count`)를 우선적으로 파싱하여 `SharedPreferences`에 캐싱하고, 아바타 잠금 해제(Unlock) 조건으로 활용.
- **채팅 API 응답의 `result.answer` 구조**: `AvatarChatController`는 `/api/chat` 응답 파싱 시, 다양한 백엔드 응답 형태(Shape A, B, C)를 지원하기 위해 `response.data['result']['answer']` 뿐만 아니라 `data['answer']`, `data['aiReply']`, `data['result']['message']` 등을 순차적으로 검사하여 AI 응답 텍스트를 추출함.
- **실패 시 모의(Mock) 응답 미사용**: 아바타 채팅(`/api/chat`) 호출 실패 또는 비정상 응답 시, 임의의 Mock 텍스트를 보여주지 않고 무조건 **"아바타 응답을 불러오지 못했습니다. 다시 시도해주세요."** 라는 명시적 실패 메시지만 출력함.
