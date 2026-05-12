# AI 자서전 (Life Legacy) API 설계서

## 1. 개요
본 문서는 AI 자서전(Life Legacy) 백엔드 서비스의 API 명세를 정의합니다. 모든 API는 JSON 형식을 사용하며, 인증이 필요한 API는 헤더에 Bearer 토큰을 포함해야 합니다.

- **Base URL**: `http://localhost:3000` (환경에 따라 다름)
- **Swagger UI**: `/api-docs`

---

## 2. 인증 API (Auth)
Base Path: `/auth`

### 2.1 회원가입
- **Endpoint**: `POST /auth/signup`
- **Description**: 새로운 사용자를 등록합니다.
- **Request Body**:
  ```json
  {
    "email": "test@naver.com",
    "password": "password123"
  }
  ```
- **Response**: `Success201ResponseDTO<JwtTokenResponseDTO>`

### 2.2 로그인
- **Endpoint**: `POST /auth/login`
- **Description**: 이메일과 비밀번호로 로그인하여 토큰을 발급받습니다.
- **Request Body**:
  ```json
  {
    "email": "test@naver.com",
    "password": "password123"
  }
  ```
- **Response**: `SuccessResponseDTO<JwtTokenResponseDTO>`

### 2.3 토큰 갱신
- **Endpoint**: `POST /auth/refresh-token`
- **Description**: Refresh Token을 사용하여 새로운 Access Token을 발급받습니다.
- **Request Body**:
  ```json
  {
    "refreshToken": "string"
  }
  ```
- **Response**: `Success201ResponseDTO<JwtTokenResponseDTO>`

---

## 3. 사용자 및 프로필 API (Users/Me)
Base Path: `/users/me`
*모든 API는 JWT 인증 필요*

### 3.1 자기소개 저장
- **Endpoint**: `POST /users/me/intro`
- **Description**: 유저의 기본 자기소개 텍스트를 저장합니다.
- **Request Body**:
  ```json
  {
    "userIntroText": "안녕하세요, 저는 서울에 살고 있는..."
  }
  ```

### 3.2 목차 및 진행도 조회
- **Endpoint**: `GET /users/me/toc`
- **Description**: 유저 맞춤형 목차와 각 항목별 진행률(퍼센테이지)을 조회합니다.

### 3.3 목차 및 질문 조회
- **Endpoint**: `GET /users/me/toc-questions`
- **Description**: 유저 맞춤형 목차와 해당 목차에 포함된 질문 리스트를 조회합니다.

### 3.4 답변 조회
- **Endpoint**: `GET /users/me/answers`
- **Description**: 특정 목차와 질문에 대해 유저가 작성한 답변을 조회합니다.
- **Query Parameters**:
  - `questionId` (number, required)
  - `tocId` (number, required)

### 3.5 답변 수정
- **Endpoint**: `PATCH /users/me/answers/:answerId`
- **Description**: 작성된 자서전 답변 내용을 수정합니다.
- **Request Body**:
  ```json
  {
    "updateAnswer": "수정된 답변 내용",
    "tocId": 1,
    "questionId": 1
  }
  ```

### 3.6 회원 탈퇴
- **Endpoint**: `DELETE /users/me`
- **Description**: 회원 탈퇴를 처리합니다.
- **Request Body**:
  ```json
  {
    "withdrawalReason": "REASON_CODE",
    "withdrawalText": "탈퇴 사유 상세"
  }
  ```

---

## 4. AI 서비스 API (AI)
Base Path: `/api`
*모든 API는 JWT 인증 필요*

### 4.1 유저 케이스 분류
- **Endpoint**: `POST /api/case`
- **Description**: 입력된 자기소개를 바탕으로 유저의 라이프 스타일 케이스(case1~6)를 분류합니다.
- **Request Body**:
  ```json
  {
    "data": "자기소개 텍스트"
  }
  ```

### 4.2 기억 동기화
- **Endpoint**: `POST /api/sync`
- **Description**: 유저의 일기나 답변 원문을 AI 서버에 동기화합니다.
- **Request Body**:
  ```json
  {
    "content": "동기화할 텍스트 내용"
  }
  ```

### 4.3 꼬리 질문 생성
- **Endpoint**: `POST /api/question`
- **Description**: 유저의 답변을 분석하여 심화 질문(꼬리 질문)을 생성합니다.
- **Request Body**:
  ```json
  {
    "question": "1차 질문 내용",
    "data": "유저의 1차 답변"
  }
  ```

### 4.4 자서전 생성 및 PDF 발행
- **Endpoint**: `POST /api/autobiography`
- **Description**: 지금까지의 답변을 종합하여 자서전을 제작하고 PDF를 발행합니다.

### 4.5 아바타 채팅
- **Endpoint**: `POST /api/chat`
- **Description**: AI 아바타(부모님 컨셉 등)와 대화합니다.
- **Request Body**:
  ```json
  {
    "message": "사용자 메시지",
    "role": "아버지" // optional
  }
  ```

### 4.6 원문 검색
- **Endpoint**: `POST /api/search`
- **Description**: 유저의 과거 기록 중 특정 키워드와 관련된 원문을 검색합니다.
- **Request Body**:
  ```json
  {
    "query": "검색 키워드"
  }
  ```

### 4.7 답변 합치기
- **Endpoint**: `POST /api/combine`
- **Description**: 1차 답변과 2차 답변(꼬리 질문 답변)을 자연스러운 문장으로 합칩니다.
- **Request Body**:
  ```json
  {
    "question1": "...",
    "data1": "...",
    "question2": "...",
    "data2": "..."
  }
  ```

---

## 5. 자서전 콘텐츠 API (Life Legacy)
Base Path: `/life-legacy`
*모든 API는 JWT 인증 필요*

### 5.1 목차별 질문 조회
- **Endpoint**: `GET /life-legacy/toc/:tocId/questions`
- **Description**: 특정 목차(카테고리)에 해당하는 질문 목록을 가져옵니다.

### 5.2 최종 결과물 저장
- **Endpoint**: `POST /life-legacy/toc/:tocId/questions/:questionId/answers`
- **Description**: 각 질문에 대한 최종 완성된 자서전 문구를 저장합니다.
- **Request Body**:
  ```json
  {
    "answer": "최종 완성된 문장"
  }
  ```
