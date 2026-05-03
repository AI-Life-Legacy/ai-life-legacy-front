# Required Backend APIs for Life Legacy App

본 문서는 현재 앱의 네트워크 레이어(`api_endpoints.dart`)에 선언된 기존 API들과 새롭게 추가된 UI(아바타, 뷰어, 검색 등)가 작동하기 위해 필요한 백엔드 API 명세서를 정리한 것입니다.

## 1. Auth (인증)

| 기능 | 엔드포인트 | Method | Request | Response |
|------|-----------|--------|---------|----------|
| **회원 가입** | `/auth/signup` | POST | `{ email, password }` | `{ accessToken, refreshToken }` |
| **로그인** | `/auth/login` | POST | `{ email, password }` | `{ accessToken, refreshToken }` |
| **토큰 재발급** | `/auth/refresh-token` | POST | `{ refreshToken }` | `{ accessToken }` |

## 2. User (유저 정보 및 목차 진행률)

| 기능 | 엔드포인트 | Method | Request | Response |
|------|-----------|--------|---------|----------|
| **자기소개 서문 저장** | `/users/me/intro` | POST | `{ name, age, summary }` | `{ success: true }` |
| **맞춤 목차 목록 조회** | `/users/me/toc` | GET | - | `[{ id, title, done, percent }]` |
| **목차별 질문 트리 조회** | `/users/me/toc-questions` | GET | - | `[{ tocId, questions: [...] }]` |
| **작성된 답변 조회** | `/users/me/answers` | GET | `?tocId={id}&questionId={id}` | `{ answerText }` |
| **기존 답변 수정** | `/users/me/answers/:answerId` | PATCH | `{ newText }` | `{ success: true }` |
| **회원 탈퇴** | `/users/me` | DELETE | `{ reason }` | `{ success: true }` |

## 3. Life Legacy (자서전 작성 기록)

| 기능 | 엔드포인트 | Method | Request | Response |
|------|-----------|--------|---------|----------|
| **특정 목차 질문 목록** | `/life-legacy/toc/:tocId/questions` | GET | - | `[{ questionId, text }]` |
| **질문 답변 제출** | `/life-legacy/toc/:tocId/questions/:questionId/answers` | POST | `{ text }` | `{ success: true }` |

## 4. AI (인공지능 기능)

| 기능 | 엔드포인트 | Method | Request | Response |
|------|-----------|--------|---------|----------|
| **질문 생성 AI** | `/api/question` | POST | `{ previousAnswer }` | `{ aiQuestionText }` |
| **AI 채팅 세션** | `/api/chat` | POST | `{ message }` | `{ aiReply }` |
| **기억 검색** | `/api/search` | POST | `{ query: "학교" }` | `[{ chapterId, question, answer }]` |
| **답변 병합/분석** | `/api/autobiography` | POST | `{ tocId }` | `{ mergedText }` |
| **유저 Case 생성** | `/api/case` | POST | - | `{ success: true }` |
| **데이터 동기화** | `/api/sync` | POST | - | `{ success: true }` |

## 5. Avatar Generation (아바타 생성 - 신규 기획)

| 기능 | 엔드포인트 | Method | Request | Response |
|------|-----------|--------|---------|----------|
| **아바타 생성 요청** | `/avatar/generate` | POST | - | `{ status: 'generating', estimatedTime }` |
| **생성 상태 확인** | `/avatar/status` | GET | - | `{ status: 'completed', viewerCode: 'A3F7K2' }` |

## 6. Viewer Flow (가족용 아바타 뷰어 - 신규 기획)

| 기능 | 엔드포인트 | Method | Request | Response |
|------|-----------|--------|---------|----------|
| **뷰어 코드 검증** | `/viewer/verify` | POST | `{ code: 'A3F7K2' }` | `{ valid: true, writerName: 'Margaret' }` |
| **관계 설정** | `/viewer/role` | POST | `{ code, role: '딸' }` | `{ success: true }` |
| **아바타 채팅 전송** | `/viewer/chat` | POST | `{ code, message }` | `{ aiReply, audioUrl }` |
| **아바타 음성 스트림**| `/viewer/audio` | GET | `?messageId=123` | `(Audio Stream or URL)` |
