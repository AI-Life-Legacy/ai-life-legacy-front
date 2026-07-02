# Frontend 기능 동작 알고리즘 명세

이 문서는 프론트엔드 프로젝트의 주요 비즈니스 기능별 "입력 → 처리 → 결과" 중심의 동작 알고리즘을 정리한 문서입니다.

---

## 1. 회원가입 후 자기소개 입력 알고리즘

- **입력**: 사용자가 `SignUpPage`에서 이메일과 비밀번호를 입력하고 가입 버튼 클릭
- **처리**:
  1. `AuthController`가 `/auth/signup` 백엔드 API를 호출하여 회원가입 시도
  2. 서버로부터 `accessToken`과 `refreshToken`을 응답받아 `TokenStorage`에 저장
  3. 로그인 처리(토큰 저장)가 완료되면 `Get.offAllNamed(Routes.selfIntro)`로 리다이렉트
- **결과**: 사용자는 회원가입 직후 강제로 자기소개 입력 화면(`SelfIntroPage`)으로 이동됨

## 2. 자기소개 4개 질문 합치기 알고리즘

- **입력**: 사용자가 온보딩 과정에서 4개의 텍스트 입력창(`q1`~`q4`)에 자신의 정보를 입력
- **처리**:
  1. `OnboardingController`의 `_combineAnswers()` 메서드가 실행됨
  2. 각 입력값에 특정 레이블("이름과 나이:", "태어난 곳과 성장 배경:" 등)을 붙이고 줄바꿈(`\n\n`)으로 구분하여 하나의 문자열로 결합 (Concatenation)
  3. 최소 1개 이상의 항목에 텍스트가 존재하는지 검증
- **결과**: 결합된 단일 텍스트(`userIntroText`)를 `/users/me/intro` 및 `/api/case` 백엔드 API에 일괄 전송

## 3. 로그인 및 토큰 저장 알고리즘

- **입력**: 사용자가 이메일과 비밀번호로 로그인 요청
- **처리**:
  1. `/auth/login` 응답으로 `accessToken`, `refreshToken`을 수신
  2. `TokenStorage.saveTokens()`를 호출하여 `clearViewerSession()`으로 기존 뷰어 모드 데이터를 우선 초기화
  3. `accessToken`의 JWT 형식을 온디바이스에서 `base64` 디코딩하여 페이로드 추출
  4. 페이로드에서 `uuid` (또는 `sub`, `id`) 값을 파싱
- **결과**: `SharedPreferences`에 추출한 `uuid`와 두 개의 토큰을 저장한 후 홈 화면으로 이동

## 4. viewerMode 세션 분리 알고리즘

- **입력**: 일반 작성자 로그인 vs 뷰어 로그인 발생
- **처리**:
  1. **작성자 로그인 시**: `saveTokens()` 내부에서 즉시 `clearViewerSession()`을 호출하여 기존 뷰어 토큰 및 `isViewerMode` 플래그를 완전히 삭제 (교차 오염 방지)
  2. **뷰어 로그인 시**: `saveViewerAccessToken()`이 실행되며, 기존 작성자의 토큰(`accessToken`)은 지우지 않고 `viewerAccessToken`과 `isViewerMode = true` 값만 추가로 기록
- **결과**: 앱 진입 및 화면 이동 시 `TokenStorage.isViewerMode()` 값을 검사하여 작성자 기능(홈 탭 등)의 노출 여부를 차단/허용함

## 5. 홈 챕터 진행률 표시 알고리즘

- **입력**: `/users/me/toc` API의 응답 데이터 (chapters 목록)
- **처리**:
  1. `HomeController`가 서버 응답에서 `totalChapters`, `completedChapters`, `progressPercent`를 파싱
  2. 만약 서버에서 전체 진행률을 주지 않았을 경우(`totalProgress == 0.0`), `_calculateProgress()` 실행
  3. 로컬 계산: 각 챕터의 `percent` 값 확인 → 없을 경우 `done` / `total` 비율 계산 → 없을 경우 `status == 'completed'` 확인하여 `1.0` 부여
- **결과**: 연산된 최종 비율 값(`totalProgress`)을 활용하여 홈 화면의 Circular Progress Bar 등 UI 렌더링

## 6. 챕터 질문/답변 작성 흐름

- **입력**: 챕터 채팅 화면에서 고정 질문에 답변 입력
- **처리**:
  1. 답변 입력 후 `ChatStep.waitingFollowUpChoice` 모드로 전환하여 사용자에게 꼬리 질문 생성 여부 확인
  2. 승인 시 `generateFollowUpQuestion()` 호출: `/api/question`에 질문과 현재 답변을 보내 AI 꼬리 질문 생성
  3. 꼬리 질문에 사용자가 추가 답변을 입력
  4. 단일 텍스트 포맷(`[1차답변]\n\n추가 질문: [꼬리질문]\n\n추가 답변: [꼬리답변]`)으로 두 답변을 결합
- **결과**: `/life-legacy/toc/:tocId/questions/:questionId/answers` 경로로 합쳐진 최종 문자열을 전송하고 다음 질문으로 이동

## 7. 자서전 생성 요청 알고리즘

- **입력**: 사용자가 자서전 생성(Generate) 버튼 클릭 (일반 생성 또는 '강제 재생성')
- **처리**:
  1. `AutobiographyController`가 `/api/autobiography` 호출 (강제 재생성 시 `?force=true` 쿼리 추가)
  2. 통신 타임아웃을 5~6분으로 길게 잡고 LLM의 백엔드 생성이 끝날 때까지 대기
  3. 응답이 200/201이면 `pdfUrl`, `pageCount` 등의 파라미터 파싱
- **결과**: `saveAutobiographyState()`를 통해 로컬 캐시를 갱신(generated=true)하고 아바타 잠금을 해제하며, 성공 화면으로 이동

## 8. 자서전 생성 상태 동기화 알고리즘

- **입력**: 앱 초기화 단계 또는 자서전 목록 갱신 시점
- **처리**:
  1. `syncStatusWithServer()`가 실행되어 `/api/autobiography/status` 서버 API 호출
  2. 서버 응답의 `status` 필드가 `COMPLETED` 이거나, `pdfUrl`이 비어있지 않은 문자열로 존재(`hasPdfUrl == true`)하는지 확인
  3. 위 조건을 만족하면 로컬 `SharedPreferences`의 상태를 '완료(generated=true)'로 덮어씌움. 아닐 경우 '미완성(generated=false)'으로 리셋.
- **결과**: 디바이스를 변경하거나 앱을 재설치하더라도 서버의 최신 PDF/완성 상태를 동기화받아 아바타 언락 여부 복구

## 9. PDF 보기 알고리즘

- **입력**: 완성된 자서전의 "PDF 보기" 버튼 클릭
- **처리**:
  1. `pdfUrl` 변수에 저장된 URL 문자열이 `null`이거나 비어있는지 확인
  2. 올바른 URL일 경우 `Uri.parse(pdfUrl)`를 통해 URI 객체 생성
  3. 외부 브라우저(또는 시스템 기본 PDF 뷰어) 호출(Launcher 연동)
- **결과**: 성공 시 외부 앱으로 PDF 표시, 실패 시 하단에 'PDF를 열 수 없습니다' 스낵바 표출

## 10. 아바타 잠금/해제 판단 알고리즘

- **입력**: 사용자가 `/avatar_chat` 라우트로 진입 시도
- **처리**:
  1. `AvatarChatController._checkPermissions()`가 자동으로 실행
  2. 뷰어 모드가 아님을 확인 후, `AutobiographyController`의 `isUnlocked.value` 상태 조회
  3. 해당 값은 8번 알고리즘(상태 동기화)에 의해 서버 결과(`COMPLETED` 또는 `pdfUrl` 보유 여부)를 근거로 세팅됨
- **결과**: `isUnlocked == false`라면 즉시 `Get.offNamed(Routes.locked)`를 실행해 차단 안내 화면으로 우회시킴

## 11. 뷰어 코드 입장 알고리즘

- **입력**: 뷰어 전용 입장 화면에서 공유받은 6자리 영문/숫자 코드 입력
- **처리**:
  1. `ViewerController`가 입력값의 앞뒤 공백을 제거하고 길이가 6자리인지 검증
  2. `/auth/viewer-login` API에 `{ viewerCode: code }` 페이로드로 전송
  3. 응답에서 `accessToken`과 `authorInfo`(작성자 이름, 소개)를 추출
  4. 기존 토큰 저장소(`clearTokens`)를 완전히 비운 후 뷰어 정보만 `saveViewerAccessToken()`으로 저장하고 `isViewerMode = true` 설정
- **결과**: 뷰어 전용 아바타 채팅 라우트(`/viewer_chat`)로 즉시 이동

## 12. 로그아웃 알고리즘

- **입력**: 마이페이지에서 로그아웃 메뉴 클릭
- **처리**:
  1. `MyPageController`가 `TokenStorage.clearTokens()`를 호출
  2. `clearTokens()` 내부에서 작성자 관련 토큰(`accessToken`, `refreshToken`, `uuid`)과 뷰어 세션(`viewerAccessToken`, `isViewerMode` 등)을 모두 `null` 처리 및 SharedPreferences에서 삭제
- **결과**: 내비게이션 스택을 모두 비우고(`/`부터 다시 쌓지 않음) 즉시 로그인 화면(`Routes.login`)으로 강제 이동

## 13. 회원 탈퇴 알고리즘

- **입력**: 마이페이지에서 회원 탈퇴 버튼 클릭 후 동의
- **처리**:
  1. 하드코딩된 사유(`withdrawalReason: "USER_REQUEST"`, `withdrawalText: "사용자 요청으로 탈퇴"`)를 담은 DTO 객체 생성
  2. 백엔드 `/users/me` 엔드포인트로 DELETE 요청 발송
  3. 서버에서 정상(200) 응답이 반환되었는지 확인
- **결과**: API 호출이 성공했을 때만 `TokenStorage.clearTokens()`를 수행하여 로컬 정보를 완전히 지우고 로그인 화면으로 이동. (실패 시 세션 유지 및 에러 메시지 알림)
