# 프로젝트 디렉터리 구조 (Directory Structure)

`ai-life-legacy-front` 프로젝트의 주요 디렉터리 및 파일 구조입니다. 이 프로젝트는 **GetX** 패턴을 기반으로 한 **Feature-first** 아키텍처를 따르고 있습니다.

## 전체 구조

```text
ai-life-legacy-front/
├── android/                # Android 플랫폼 관련 설정 및 코드
├── ios/                    # iOS 플랫폼 관련 설정 및 코드
├── windows/                # Windows 플랫폼 관련 설정 및 코드
├── web/                    # Web 플랫폼 관련 설정 및 코드
├── docs/                   # 프로젝트 문서 (API 가이드, 설계서 등)
│   ├── API_MAPPING_GUIDE.md
│   ├── COMMIT_MESSAGES.md
│   └── ...
├── design_specs/           # 디자인 명세서 및 관련 파일
├── lib/                    # Flutter 핵심 소스 코드
│   ├── app/                # 애플리케이션 전역 설정 및 코어 로직
│   │   ├── core/           # 공통 기능 (AI, Network, Theme 등)
│   │   └── initial_binding.dart
│   ├── features/           # 기능별 모듈화된 디렉터리
│   │   ├── auth/           # 인증 기능 (로그인, 회원가입 등)
│   │   ├── autobiography/  # 자서전 관련 기능
│   │   ├── avatar_chat/    # 아바타 채팅 기능
│   │   ├── home/           # 홈 화면
│   │   └── ... (기타 기능들)
│   ├── bootstrap.dart      # 앱 초기화 로직
│   └── main.dart           # 앱 진입점
├── test/                   # 테스트 코드
├── pubspec.yaml            # 프로젝트 의존성 및 설정 파일
└── README.md               # 프로젝트 개요
```

---

## 상세 설명

### 1. `lib/app/core/`
앱 전체에서 공통으로 사용되는 핵심 모듈들이 위치합니다.
- `ai/`: AI 연동 관련 로직 및 서비스
- `config/`: 환경 설정 및 상수 정의
- `models/`: 전역적으로 사용되는 데이터 모델
- `network/`: API 통신을 위한 Dio/Http 클라이언트 설정
- `routes/`: GetX 기반 라우팅 설정 (`app_pages.dart`, `app_routes.dart`)
- `theme/`: 앱 디자인 시스템 (색상, 폰트, 스타일)
- `utils/`: 공통 유틸리티 함수

### 2. `lib/features/`
각 기능은 독립적인 모듈로 구성되며, 일반적으로 다음과 같은 내부 구조를 가집니다.
- `data/`: 데이터 레이어
    - `models/`: 해당 기능에서만 사용되는 데이터 모델
    - `auth_api.dart`: API 호출 로직
    - `auth_repository.dart`: 데이터 소스 관리 및 비즈니스 로직 추상화
- `presentation/`: UI 레이어
    - `bindings.dart`: 의존성 주입(Dependency Injection) 설정
    - `controllers/`: 비즈니스 로직 및 상태 관리 (GetxController)
    - `pages/`: 실제 화면 UI 코드 (Stateless/Stateful Widget)

### 3. `docs/`
개발 및 협업을 위한 문서들이 정리되어 있습니다.
- `API_MAPPING_TABLE.md`: 프론트엔드와 백엔드 간의 API 매핑 테이블
- `COMMIT_MESSAGES.md`: 커밋 메시지 규칙 및 히스토리
- `design-canvas.jsx.md`: 디자인 관련 컴포넌트 명세

---

이 구조는 코드의 가독성을 높이고, 기능 단위의 확장 및 유지보수를 용이하게 하도록 설계되었습니다.
