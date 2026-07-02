# Frontend State & Storage 명세

프론트엔드 프로젝트(`d:\DEV\projects\ai-life-legacy-front`)의 GetX 기반 상태관리 및 로컬 저장소(`TokenStorage`, `SharedPreferences`) 구조에 대한 분석 내용입니다.

## 1. GetX Controller 목록

| Controller 이름 | 담당 기능 | 주요 상태값 (Rx) | 주요 메서드 | 호출하는 API | 라우팅 역할 |
|---|---|---|---|---|---|
| `AuthController` | 로그인, 회원가입, 로그아웃 | `emailController`, `passwordController`, `isLoading` | `login()`, `signUp()`, `logout()` | `AuthApi.login`, `AuthApi.signUp` | 완료 후 `home` 또는 `selfIntro` 리다이렉트 |
| `ViewerController` | 뷰어 로그인 검증 | `viewerCode`, `writerName`, `isLoading` | `verifyCode(code)` | `ViewerApi.viewerLogin` | 뷰어 세션 저장 후 `viewerChat` 이동 |
| `HomeController` | 메인 대시보드 진행률 관리 | `chapters`, `totalProgress`, `totalChapters` | `fetchToc()`, `onChapterTap()`, `_calculateProgress()` | `HomeApi.getToc` | 챕터 터치 시 `chapterChat` 이동 지원 |
| `AutobiographyController` | 자서전 채팅 문답 및 PDF 생성 상태 관리 | `questions`, `messages`, `chatStep`, `pdfUrl`, `isUnlocked` | `fetchQuestions()`, `sendMessage()`, `generateFollowUpQuestion()`, `generateFullBook()`, `syncStatusWithServer()` | `AutobiographyApi` (조회, 저장, 생성, 상태확인 API 다수) | 챕터 완료 시 `chapterComplete` 라우팅 |
| `AutobiographyListController`| 자서전 전체 목차 및 하위 질문 목록 관리 | `chapters`, `tocQuestions`, `totalProgress`, `expandedTocId` | `fetchToc()`, `fetchTocQuestions()`, `toggleChapter()` | `AutobiographyApi.getToc`, `.getTocQuestions` | `write` 이동 결과에 따른 데이터 갱신 |
| `AutobiographyWriteController`| 단일 답변 조회 및 텍스트 수정 | `answerText`, `answerId`, `isLoading`, `isSaving` | `fetchAnswer()`, `save()` | `AutobiographyApi.getAnswer`, `.updateAnswer` | 저장 완료 후 `Get.back(true)` |
| `OnboardingController` | 초기 4문항 자기소개 입력 및 케이스 생성 폼 | `q1Controller` ~ `q4Controller`, `currentStep` | `submitIntro()` | `OnboardingApi.saveIntro`, `.generateCase` | 완료 후 `chapterGenerating` 이동 |
| `SelfIntroController` | 초기 질문을 챗봇 형태로 입력받는 로직 | `messages`, `answerPhase`, `canThinkDeeper` | `submitAnswer()`, `generateFollowUpQuestion()`, `_finalizeSelfIntro()` | `AiApi.sync`, `.getQuestion`, `.getCase`, `AutobiographyApi` | 케이스 분석 후 `home` 리다이렉트 |
| `AvatarChatController` | 아바타 채팅 (뷰어/작성자 공통) 및 역할 선택 | `step`, `selectedRoleId`, `sessionId`, `messages` | `selectRole()`, `startChat()`, `sendMessage()`, `_checkPermissions()` | `AvatarChatApi.chat`, `.getToc`, `.getViewerCode` | 권한 불일치 시 `home`/`locked` 강제 이동 |
| `MyPageController` | 프로필 정보 표시, 로그아웃, 회원탈퇴 | `userName`, `chapterCount`, `isLoading` | `withdrawAccount()`, `logout()` | `UserRepository.getUserToc`, `.deleteUser` | 탈퇴/로그아웃 후 `login` 강제 이동 |

---

## 2. TokenStorage 저장값

앱의 `TokenStorage` 클래스 내부에서 `SharedPreferences`를 활용하여 관리하는 주요 키값들입니다.

| 변수 / Key | 설명 | 비고 |
|---|---|---|
| `accessToken` (`access_token`) | 작성자 메인 세션용 JWT | 저장 시 JWT payload에서 `uuid`를 파싱하여 별도 추출 시도함 |
| `refreshToken` (`refresh_token`) | 토큰 갱신용 Refresh Token | |
| `uuid` (`uuid`) | 작성자의 식별 고유 ID | `accessToken` payload(`uuid`, `sub`, `id`)에서 디코딩하여 추출 |
| `viewerAccessToken` | 뷰어 모드 전용 세션 토큰 | 뷰어 로그인(`verifyCode`) 성공 시 저장 |
| `viewerAuthorName` | 초대한 작성자(대상자)의 이름 | 뷰어 모드 UI 렌더링에 활용 |
| `viewerAuthorIntro` | 작성자의 간단 소개 문구 | |
| `isViewerMode` | 현재 앱의 구동 모드 (Boolean) | `true`일 경우 작성자용 탭/기능 접근 제한됨 |

---

## 3. 작성자 세션과 뷰어 세션 분리 방식

앱은 한 디바이스에서 작성자와 뷰어 세션을 명확하게 분리하고 교차 오염을 막기 위한 로직을 포함합니다.

- **일반(작성자) 로그인 시 뷰어 세션 정리 여부**: 
  - 작성자로 로그인 시 `TokenStorage.saveTokens()` 함수가 호출되며, 내부에서 `clearViewerSession()`이 가장 먼저 실행됩니다. 즉, **일반 로그인 시 기존 뷰어 모드의 흔적이 모두 삭제(정리)** 됩니다.
- **뷰어 로그인 시 작성자 토큰 분리 여부**: 
  - 반면, 뷰어 로그인 시 `saveViewerAccessToken()`이 호출되는데, 이 때 기존의 작성자 토큰(`accessToken`, `refreshToken`)을 삭제하는 코드는 없습니다. 다만 `isViewerMode`가 `true`가 되면서 UI단에서 작성자 정보가 우선적으로 숨겨지는 방식으로 뷰어 격리가 이뤄집니다.
- **Logout 시 삭제되는 값**: 
  - `TokenStorage.clearTokens()`가 호출되며, `accessToken`, `refreshToken`, `uuid`, 그리고 `viewerAccessToken` 등 **작성자와 뷰어의 모든 세션 정보가 한 번에 완전 삭제** 됩니다.

---

## 4. 자서전 생성 상태 관리

자서전(PDF) 발간 상태 및 그에 따른 로컬 UI 상태는 `AutobiographyController`를 중심으로 동기화됩니다.

- **서버 상태 우선 여부**: 
  - 앱 초기화(`onInit`) 시 `syncStatusWithServer()`를 호출하여 서버의 최신 정보(`/api/autobiography/status`)를 가장 우선적으로 조회합니다.
- **SharedPreferences Fallback 여부**: 
  - 서버 조회에 실패할 경우, `catch` 블록 내에서 `loadAutobiographyState()`를 호출하여 기존에 `SharedPreferences`에 저장해 둔 로컬 캐시 상태를 Fallback(대안)으로 활용합니다.
- **pdfUrl / pageCount 저장 여부**: 
  - 서버 응답에서 `pdfUrl`(또는 `pdf_url`) 및 `pageCount`(또는 `page_count`)를 파싱하여 `SharedPreferences`에 캐싱 (`autobiographyPdfUrl`, `autobiographyPageCount`) 합니다.
- **force=true 재생성 흐름**: 
  - 강제로 PDF를 재생성할 경우 `AutobiographyController.generateFullBook(force: true)`가 호출되며, API 엔드포인트에 `?force=true` 쿼리 파라미터를 담아 서버에 요청합니다.

---

## 5. 아바타 잠금 상태 관리

작성자가 자기 자신이나 가족 아바타와 채팅을 하기 위해서는 자서전이 우선 완성되어야 하며, 이는 엄격하게 잠금 관리됩니다.

- **어떤 상태를 기준으로 잠금/해제하는가?**: 
  - `AutobiographyController` 내의 `isUnlocked` 및 `SharedPreferences`의 `avatarUnlocked` Boolean 값을 기준으로 접근을 제어합니다.
- **서버 Status `COMPLETED` 기준 여부**: 
  - `syncStatusWithServer()` 응답 로직을 확인한 결과, 서버의 `status` 문자열이 `"COMPLETED"`이거나, **상태와 무관하게 `pdfUrl` 파라미터가 비어있지 않은 문자열로 존재할 경우(hasPdfUrl == true)** 모두 자서전 완성이 끝난 것으로 간주하여 아바타 잠금을 해제(`isUnlocked = true`)합니다.
  - 반대로 NOT_STARTED, FAILED, PROCESSING 등 완료가 아닌 상태이고 PDF 주소도 없으면 즉시 상태를 리셋하고 다시 잠급니다.
