# React(Prototype) to Flutter(GetX) Architecture Mapping Guide

이 문서는 기존 React `.jsx` 기반의 UI 프로토타입 소스 코드(`life-legacy-source-bundle.md`)를 **Flutter + GetX (Feature-first)** 아키텍처로 마이그레이션하기 위한 구조 매핑 가이드입니다. Antigravity 등의 개발 도구에서 코드를 변환하거나 참조할 때 이 가이드를 따르세요.

---

## 1. 공통 코어 및 설정 (Core Layer) 매핑

기존 화면을 구성하던 전역 디자인 토큰, 공통 위젯, 라우팅, 전역 모델 등은 모두 `lib/app/core/` 디렉터리 하위로 이동하여 관리합니다.

| 기존 React 코드 (UI 번들) | 기능 및 역할 | Flutter 디렉터리 경로 (`lib/app/core/`) |
| :--- | :--- | :--- |
| `api.js` (신규 추가) | 백엔드 API 통신 베이스 모듈 (인터셉터, 토큰 관리) | `/network/dio_client.dart` 또는 `api_provider.dart` |
| `primitives.jsx` (Colors) | 색상표 (`bg`, `cta`, `text` 등) | `/theme/app_colors.dart` |
| `primitives.jsx` (Typography)| 폰트 스타일 (`T.h1`, `T.body` 등) | `/theme/app_text_styles.dart` |
| `primitives.jsx` (Components)| 버튼(`BtnPrimary`), 입력창, 아이콘 등 공통 UI | `/theme/widgets/` (예: `primary_button.dart`) |
| `Life Legacy.html` | 앱 라우팅 목록 (`SCREEN_MAP`) | `/routes/app_pages.dart`, `app_routes.dart` |
| `avatar-roles.jsx` | 아바타 역할(가족/지인) 정적 데이터 모델 | `/models/avatar_role_model.dart` |

---

## 2. 기능별 모듈 (Feature Layer) 매핑

기존 `screens-*.jsx` 파일에 묶여있던 21개의 세부 화면들을 도메인(Feature) 역할에 맞게 `lib/features/` 하위로 분리합니다.

### 🔐 Auth & Onboarding (인증 및 온보딩)
| 기존 파일명 | 기존 화면 (React) | Flutter 기능 폴더 | Flutter 상세 경로 (`presentation/pages/`) |
| :--- | :--- | :--- | :--- |
| `screens-onboarding` | `S01_Main` (메인 진입) | `auth/` | `main_page.dart` |
| | `S02_Login` (로그인) | `auth/` | `login_page.dart` |
| | `S03_SignUp` (회원가입) | `auth/` | `sign_up_page.dart` |
| | `S04_SelfIntro` (자기소개 작성) | `onboarding/` | `self_intro_page.dart` |

### 🏠 Home & Search (홈 및 검색)
| 기존 파일명 | 기존 화면 (React) | Flutter 기능 폴더 | Flutter 상세 경로 (`presentation/pages/`) |
| :--- | :--- | :--- | :--- |
| `screens-onboarding` | `S06_Home` (홈 화면) | `home/` | `home_page.dart` |
| `screens-utility` | `S15_Search` (기억 검색) | `search/` | `search_page.dart` |

### ✍️ Autobiography (자서전 집필 및 생성)
| 기존 파일명 | 기존 화면 (React) | Flutter 기능 폴더 | Flutter 상세 경로 (`presentation/pages/`) |
| :--- | :--- | :--- | :--- |
| `screens-onboarding` | `S05_ChapterGen` (초기 챕터 생성) | `autobiography/` | `chapter_gen_loading_page.dart` |
| `screens-writing` | `S07_Chat` (챕터 질문 답변) | `autobiography/` | `chapter_chat_page.dart` |
| | `S08_Complete` (챕터 완료 시트) | `autobiography/` | `chapter_complete_bottom_sheet.dart` |
| | `S09_BookList` (자서전 목차) | `autobiography/` | `book_list_page.dart` |
| | `S10_Write` (답변 직접 수정) | `autobiography/` | `write_page.dart` |
| `screens-generation` | `S11_GenConfirm` (자서전 생성 확인) | `autobiography/` | `gen_confirm_page.dart` |
| | `S12_GenLoading` (생성 로딩) | `autobiography/` | `gen_loading_page.dart` |
| | `S13_BookComplete` (완성 및 공유)| `autobiography/` | `book_complete_page.dart` |

### 🗣️ Avatar Chat & Viewer (아바타 채팅 및 관람자 뷰어)
| 기존 파일명 | 기존 화면 (React) | Flutter 기능 폴더 | Flutter 상세 경로 (`presentation/pages/`) |
| :--- | :--- | :--- | :--- |
| `screens-generation` | `S14_Avatar` (아바타 채팅 해제) | `avatar_chat/` | `avatar_chat_page.dart` |
| | `S14b_AvatarLocked` (잠금 상태) | `avatar_chat/` | `avatar_locked_page.dart` |
| `screens-viewer` | `S17_ViewerEntry` (관람자 코드 입력) | `viewer/` | `viewer_entry_page.dart` |
| | `S18a_RoleSelect` (역할 선택)| `viewer/` | `role_select_page.dart` |
| | `S18_ViewerIntro` (관람자 인트로) | `viewer/` | `viewer_intro_page.dart` |
| | `S19_ViewerChat` (관람자 채팅) | `viewer/` | `viewer_chat_page.dart` |

### ⚙️ My Page (마이페이지)
| 기존 파일명 | 기존 화면 (React) | Flutter 기능 폴더 | Flutter 상세 경로 (`presentation/pages/`) |
| :--- | :--- | :--- | :--- |
| `screens-utility` | `S16_MyPage` (마이페이지) | `mypage/` | `my_page.dart` |

---

## 3. GetX 아키텍처 변환 원칙 (React -> Flutter/GetX)

기존 React 코드에 작성된 상태 관리(`useState`)와 더미 데이터는 기능 모듈 내에서 3개의 레이어로 완벽하게 분리되어야 합니다.

1. **Presentation Layer (`/presentation/pages/`, `/presentation/controllers/`)**
   * **UI (Pages)**: `S02_Login`과 같은 React 컴포넌트는 `StatelessWidget` 또는 `GetView<AuthController>`로 변환됩니다. UI 코드 내에 직접적인 로직이나 상태 선언을 피합니다.
   * **상태 관리 (Controllers)**: React의 `useState`, `useEffect`는 모두 `GetxController` 내부의 `Rx` 변수 및 라이프사이클 메서드(`onInit`, `onReady`)로 이동합니다.
2. **Domain/Data Layer (`/data/`)**
   * 하드코딩된 더미 데이터(예: `const CHAPTERS = [...]`)는 제거하고, `xxx_api.dart` 파일을 생성하여 `Dio`를 이용한 백엔드 API 연동 로직으로 대체합니다.
   * API 응답은 `xxx_repository.dart`를 통해 앱 내에서 사용할 모델(`models/`)로 직렬화(Serialization)합니다.
3. **Dependency Injection (`/presentation/bindings.dart`)**
   * 각 화면에 접근할 때 필요한 Controller와 Repository는 `Bindings` 클래스의 `Get.lazyPut()`을 통해 의존성을 주입합니다.
