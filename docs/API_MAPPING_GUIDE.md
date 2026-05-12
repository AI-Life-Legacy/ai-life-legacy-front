# API_MAPPING_GUIDE.md
(AI 자서전 Life Legacy - Flutter/GetX 프론트엔드 API 연동 명세서)

이 문서는 `ai-life-legacy-front` 프로젝트의 Feature-first 아키텍처에 맞추어, 현재 설계된 백엔드(NestJS, FastAPI) API를 프론트엔드의 각 기능(Feature) 모듈에 매핑한 테이블과 향후 추가가 필요한 API를 정리한 문서입니다.

---

## 1. 현재 연동 가능한 API 매핑 (Feature 모듈별)

### 🔐 인증 모듈 (`lib/features/auth/`)
| 파일 경로 (data/) | HTTP | 엔드포인트 | 역할 및 설명 |
| :--- | :--- | :--- | :--- |
| `auth_api.dart` | `POST` | `/auth/signup` | 신규 사용자 등록 및 토큰 발급 |
| `auth_api.dart` | `POST` | `/auth/login` | 이메일/비밀번호 로그인 및 토큰 발급 |
| `auth_api.dart` | `POST` | `/auth/refresh-token` | 만료된 액세스 토큰 갱신 (인터셉터 등에서 공통 사용) |

### 👋 온보딩 모듈 (`lib/features/onboarding/`)
| 파일 경로 (data/) | HTTP | 엔드포인트 | 역할 및 설명 |
| :--- | :--- | :--- | :--- |
| `onboarding_api.dart` | `POST` | `/users/me/intro` | 유저의 기본 자기소개 텍스트 저장 |
| `onboarding_api.dart` | `POST` | `/api/case` | 입력된 자기소개를 바탕으로 유저의 라이프 스타일 케이스 분류 |

### 🏠 홈 및 검색 모듈 (`lib/features/home/`, `lib/features/search/`)
| 파일 경로 (data/) | HTTP | 엔드포인트 | 역할 및 설명 |
| :--- | :--- | :--- | :--- |
| `home_api.dart` | `GET` | `/users/me/toc` | 유저 맞춤형 목차와 각 항목별 진행률 조회 |
| `search_api.dart` | `POST` | `/api/search` | 유저의 과거 기록 중 특정 키워드와 관련된 원문 검색 |

### ✍️ 자서전 집필 모듈 (`lib/features/autobiography/`)
| 파일 경로 (data/) | HTTP | 엔드포인트 | 역할 및 설명 |
| :--- | :--- | :--- | :--- |
| `autobiography_api.dart`| `GET` | `/users/me/toc-questions` | 해당 목차에 포함된 질문 리스트 조회 |
| `autobiography_api.dart`| `GET` | `/life-legacy/toc/:tocId/questions`| 특정 목차에 해당하는 모든 질문 리스트 조회 |
| `autobiography_api.dart`| `POST` | `/api/question` | 유저의 1차 답변을 분석하여 심화(꼬리) 질문 생성 |
| `autobiography_api.dart`| `POST` | `/api/combine` | 1차 답변과 2차(꼬리 질문) 답변을 자연스러운 문장으로 병합 |
| `autobiography_api.dart`| `POST` | `/life-legacy/toc/:tocId/questions/:questionId/answers`| 각 질문에 대한 최종 완성된 자서전 문구 저장 |
| `autobiography_api.dart`| `GET` | `/users/me/answers` | 특정 목차/질문에 대해 유저가 작성한 전체 답변 조회 |
| `autobiography_api.dart`| `PATCH`| `/users/me/answers/:answerId` | 이미 작성된 자서전 답변 내용 직접 수정 |
| `autobiography_api.dart`| `POST` | `/api/autobiography` | 모든 답변을 종합하여 자서전 제작 및 PDF 발행 |

### 🗣️ 아바타 채팅 및 뷰어 모듈 (`lib/features/avatar_chat/`, `lib/features/viewer/`)
| 파일 경로 (data/) | HTTP | 엔드포인트 | 역할 및 설명 |
| :--- | :--- | :--- | :--- |
| `avatar_chat_api.dart` | `POST` | `/api/chat` | 본인 계정에서 AI 아바타와 대화 진행 |
| `viewer_api.dart` | `POST` | `/api/chat` | 공유받은 관람자(가족/지인)가 아바타와 대화 진행 |

### ⚙️ 마이페이지 모듈 (`lib/features/mypage/`)
| 파일 매핑 | HTTP | 엔드포인트 | 역할 및 설명 |
| :--- | :--- | :--- | :--- |
| `mypage_api.dart` | `DELETE`| `/users/me` | 회원 탈퇴 처리 및 유저 데이터 폐기 |
| `mypage_api.dart` | `POST` | `/api/sync` | (옵션) 유저의 데이터를 AI 모델의 벡터 DB와 동기화 |

---

## 2. 아직 없거나 개발 대기 중인 API (To-Do List)

현재 UI 설계와 기획(발표 자료 및 아키텍처)에는 존재하지만, 제공된 **API 명세서에는 누락되어 있거나 추가 개발이 필요한 API** 목록입니다. 백엔드 팀에 요청하여 추가 연동이 필요합니다.

### 📌 1. 관람자(가족/지인) 공유를 위한 뷰어 코드 기능
UI 흐름상 자서전 완성 후 "가족에게 공유 — 뷰어 코드 받기" 버튼이 존재하며(ex. 코드 `A3F7K2`), 뷰어는 이 코드를 입력해 접근해야 합니다. (발표 자료 지적 사항/To-Do에 명시됨)
* **[필요 API 1] 뷰어 코드 발급 (공유자용):**
    * `POST /life-legacy/share` (또는 유사 엔드포인트)
    * 역할: 특정 유저의 자서전에 접근할 수 있는 6자리 고유 코드 발급.
* **[필요 API 2] 뷰어 코드 검증 및 입장 (관람자용):**
    * `POST /auth/viewer-login` 또는 `POST /life-legacy/verify-code`
    * 역할: 관람자가 입력한 코드가 유효한지 검증하고, 관람자용 임시 토큰이나 자서전 열람 권한 데이터를 반환.

### 📌 2. PDF 다운로드/출력 기능
`POST /api/autobiography`로 PDF를 '생성(발행)'한다고 되어있으나, 생성된 PDF 파일을 프론트엔드(모바일 기기)로 다운로드하거나 URL을 받아오기 위한 구체적인 명세가 필요합니다.
* **[필요 API 1] 생성된 PDF 조회/다운로드:**
    * `GET /life-legacy/pdf` 또는 `GET /life-legacy/export`
    * 역할: 생성된 자서전 PDF 파일의 다운로드 링크(S3 Presigned URL 등) 또는 바이너리 데이터를 반환.

### 📌 3. Spring 인증 서버 분리에 따른 Endpoint 변경 대비
발표 자료의 시스템 구성도에 따르면 현재 NestJS에 통합된 `/auth` 라우트를 향후 **Spring 기반의 공동 인증 서버**로 분리할 예정입니다.
* **프론트엔드 대비 사항:** `lib/app/core/network/dio_client.dart` 등에서 Auth용 Base URL을 별도로 분리할 수 있도록 Config 환경 변수(env) 설정을 유연하게 구성해야 합니다.

### 📌 4. 아바타 대화 세션 관리 및 문맥 분기 파라미터
아바타 대화 시 '관련 문맥 양에 따른 응답 분기 알고리즘'이 적용될 예정입니다. 대화를 이어가기 위해선 단순 채팅 내용뿐만 아니라 세션(Session ID) 관리 기능이 필요할 수 있습니다.
* **프론트엔드 대비 사항:** `POST /api/chat` 호출 시, `sessionId`나 `role` (큐레이터, 아빠, 엄마 등)을 함께 Body에 담아 보내도록 API 스펙 확장이 필요할 가능성이 높습니다. 백엔드 팀과 Request Body 구조 협의가 필요합니다.
