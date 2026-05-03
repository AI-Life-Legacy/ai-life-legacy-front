// onboarding.jsx — screens 1–6: writer onboarding flow
// Margaret Thompson, 72 — rural Ohio teacher, raising 3 kids.
// Korean UI copy throughout.

// ─── Screen 1: MainPage ──────────────────────────────────────
function S01_Main({ nav }) {
  return (
    <Screen label="01 Main">
      <StatusBar />
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 20px' }}>
        <span style={{ fontSize: 16, fontWeight: 500, color: LL.text, letterSpacing: -0.2 }}>Life Legacy</span>
        <TextBtn fontSize={14} color={LL.textSec} onClick={() => nav && nav('02_Login')}>로그인</TextBtn>
      </div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 32px', gap: 14 }}>
        <div style={{ width: 56, height: 56, borderRadius: 28, background: LL.bgAlt, border: `1px solid ${LL.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8 }} className="ll-surface-alt">
          {Icon.bookOpen(28, LL.text)}
        </div>
        <div style={{ fontSize: 28, fontWeight: 600, color: LL.text, textAlign: 'center', lineHeight: 1.3, letterSpacing: -0.3 }} className="ll-text-primary">
          당신의 이야기를<br/>기록하고 나누세요
        </div>
        <div style={{ fontSize: 13, color: LL.textSec, textAlign: 'center', lineHeight: 1.6 }} className="ll-text-sec">
          자서전을 완성하고 AI 아바타를 만들어<br/>가족에게 내 생각과 기억을 전하세요.
        </div>
      </div>
      <div style={{ padding: '0 20px 32px' }}>
        <button onClick={() => nav && nav('03_Profile')} style={{ width: '100%', padding: '14px 16px', background: LL.cta, color: '#fff', border: 'none', borderRadius: 10, fontSize: 15, fontWeight: 500, cursor: 'pointer' }}>시작하기</button>
      </div>
    </Screen>
  );
}

// ─── Screen 2: LoginPage ─────────────────────────────────────
function S02_Login({ nav }) {
  return (
    <Screen label="02 Login">
      <StatusBar />
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 20px' }}>
        <TextBtn fontSize={14} color={LL.textSec} onClick={() => nav && nav('01_Main')}>취소</TextBtn>
      </div>
      <div style={{ flex: 1, padding: '32px', display: 'flex', flexDirection: 'column', gap: 20 }}>
        <div>
          <div style={{ fontSize: 22, fontWeight: 600, color: LL.text }} className="ll-text-primary">로그인</div>
          <div style={{ fontSize: 12, color: LL.textSec, marginTop: 4 }} className="ll-text-sec">저장된 자서전을 불러옵니다.</div>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <label style={{ fontSize: 11, fontWeight: 500, color: LL.textPh }}>이메일</label>
          <input type="email" style={{ width: '100%', padding: '10px 12px', border: `1px solid ${LL.border}`, borderRadius: 8, outline: 'none', fontFamily: LL.font }} defaultValue="margaret.t@example.com" />
        </div>
        <button onClick={() => nav && nav('05_Dashboard')} style={{ width: '100%', padding: '12px', background: LL.cta, color: '#fff', border: 'none', borderRadius: 8, fontWeight: 500, marginTop: 8, cursor: 'pointer' }}>계속하기</button>
      </div>
    </Screen>
  );
}

// ─── Screen 3: ProfilePage ──────────────────────────────────
function S03_Profile({ nav }) {
  return (
    <Screen label="03 Profile">
      <StatusBar />
      <IOSNavBar title="프로필 설정" onBack={() => nav && nav('01_Main')}/>
      <div style={{ flex: 1, padding: '24px 20px', display: 'flex', flexDirection: 'column', gap: 20 }}>
        <div>
          <div style={{ fontSize: 18, fontWeight: 600, color: LL.text, marginTop: 8 }} className="ll-text-primary">Margaret Thompson님, 환영합니다</div>
          <div style={{ fontSize: 13, color: LL.textSec, marginTop: 4 }} className="ll-text-sec">기본 프로필을 설정하고 자서전을 시작해요.</div>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          <span style={{ fontSize: 11, color: LL.textPh, fontWeight: 500 }}>이름</span>
          <input style={{ width: '100%', padding: '10px 12px', border: `1px solid ${LL.border}`, borderRadius: 8, outline: 'none' }} defaultValue="Margaret Thompson" />
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          <span style={{ fontSize: 11, color: LL.textPh, fontWeight: 500 }}>나이</span>
          <input style={{ width: '100%', padding: '10px 12px', border: `1px solid ${LL.border}`, borderRadius: 8, outline: 'none' }} defaultValue="72" />
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          <span style={{ fontSize: 11, color: LL.textPh, fontWeight: 500 }}>소개 요약</span>
          <textarea style={{ width: '100%', padding: '10px 12px', border: `1px solid ${LL.border}`, borderRadius: 8, outline: 'none', height: 72 }} defaultValue="농촌 지역 학교에서 아이들을 가르치며 3명의 자녀를 키웠습니다." />
        </div>
      </div>
      <div style={{ padding: '20px' }}>
        <button onClick={() => nav && nav('04_Complete')} style={{ width: '100%', padding: '14px', background: LL.cta, color: '#fff', border: 'none', borderRadius: 10, cursor: 'pointer', fontWeight: 500 }}>저장 및 계속</button>
      </div>
    </Screen>
  );
}

// ─── Screen 4: CompletePage ──────────────────────────────────
function S04_Complete({ nav }) {
  return (
    <Screen label="04 Complete">
      <StatusBar />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 32px' }}>
        <div style={{ width: 48, height: 48, background: LL.successBg, borderRadius: 24, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 16 }}>
          <span style={{ fontSize: 20 }}>✓</span>
        </div>
        <div style={{ fontSize: 20, fontWeight: 600, color: LL.text }} className="ll-text-primary">준비되었습니다</div>
        <div style={{ fontSize: 13, color: LL.textSec, textAlign: 'center', marginTop: 8, lineHeight: 1.5 }} className="ll-text-sec">
          이제 7개 챕터의 질문에 답하며 나만의 자서전을 작성할 수 있습니다.
        </div>
      </div>
      <div style={{ padding: '0 20px 32px' }}>
        <button onClick={() => nav && nav('05_Dashboard')} style={{ width: '100%', padding: '14px', background: LL.cta, color: '#fff', border: 'none', borderRadius: 10, cursor: 'pointer', fontWeight: 500 }}>대시보드 보기</button>
      </div>
    </Screen>
  );
}

// ─── Screen 5: DashboardPage ──────────────────────────────────
function S05_Dashboard({ nav }) {
  return (
    <Screen label="05 Dashboard">
      <StatusBar />
      <div style={{ padding: '12px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <span style={{ fontSize: 14, fontWeight: 600, color: LL.text }}>대시보드</span>
        <TextBtn fontSize={13} color={LL.textSec} onClick={() => nav && nav('06_Home')}>홈으로</TextBtn>
      </div>
      <div style={{ flex: 1, padding: '16px', overflow: 'auto' }}>
        <div className="ll-border" style={{ border: `1px solid ${LL.border}`, padding: 20, borderRadius: 12, background: LL.bgAlt }}>
          <div style={{ fontSize: 20, fontWeight: 700, color: LL.text }} className="ll-text-primary">72%</div>
          <div style={{ fontSize: 11, color: LL.textPh, marginTop: 2, textTransform: 'uppercase' }} className="ll-text-ph">총 완료율</div>
          <div style={{ marginTop: 12 }}><ProgressBar value={0.72} height={8}/></div>
        </div>

        <div style={{ ...T.sectionLabel, marginTop: 24, marginBottom: 12 }}>활동 로그</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {[{ d: '2026.04.14', txt: 'Ch. 2 작성 완료' }, { d: '2026.04.10', txt: 'Ch. 1 작성 완료' }].map((l, i) => (
            <div key={i} className="ll-border" style={{ padding: 12, border: `1px solid ${LL.border}`, borderRadius: 8, display: 'flex', justifyContent: 'space-between' }}>
              <span style={{ fontSize: 13, color: LL.text }}>{l.txt}</span>
              <span style={{ fontSize: 12, color: LL.textPh }}>{l.d}</span>
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 6: HomePage ──────────────────────────────────────
function S06_Home({ nav }) {
  const CHAPTERS = [
    { n: 1, title: '유년기: 고향의 기억', done: true },
    { n: 2, title: '청소년기: 학창 시절', done: true },
    { n: 3, title: '첫 직장과 경험', done: true },
    { n: 4, title: '가족의 형성', done: false },
    { n: 5, title: '교직 생활의 보람', done: false },
    { n: 6, title: '황혼의 지혜', done: false },
    { n: 7, title: '남기고 싶은 이야기', done: false },
  ];
  
  const total = CHAPTERS.length;
  const totalDone = CHAPTERS.filter(c => c.done).length;

  const ChapterCard = ({ ch, onClick }) => (
    <div className="ll-pressable" onClick={onClick} style={{
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '14px 16px', background: LL.bg, border: `1px solid ${LL.border}`, borderRadius: 10,
      cursor: 'pointer',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{
          width: 24, height: 24, borderRadius: 12, background: ch.done ? LL.successBg : LL.bgAlt,
          color: ch.done ? LL.success : LL.textPh, display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 12, fontWeight: 600,
        }}>
          {ch.done ? '✓' : ch.n}
        </div>
        <span style={{ fontSize: 14, fontWeight: 500, color: ch.done ? LL.text : LL.textSec }}>{ch.title}</span>
      </div>
      {ch.done ? <span style={{ fontSize: 11, color: LL.textPh }}>보기</span> : <span style={{ fontSize: 11, color: LL.warning }}>진행중</span>}
    </div>
  );

  return (
    <Screen label="06 Home">
      <StatusBar />
      {/* Top Header */}
      <div style={{ padding: '8px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <div style={{ fontSize: 15, fontWeight: 700, color: LL.text }}>Life Legacy</div>
        </div>
        <div style={{ display: 'flex', gap: 10 }}>
          <button onClick={() => nav && nav('15_Search')} style={{ width: 36, height: 36, borderRadius: 8, border: `1px solid ${LL.border}`, background: LL.bg, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            {Icon.search(16, LL.text)}
          </button>
          <button onClick={() => nav && nav('16_Settings')} style={{ width: 36, height: 36, borderRadius: 8, border: `1px solid ${LL.border}`, background: LL.bg, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ fontSize: 13, fontWeight: 600 }}>MT</span>
          </button>
        </div>
      </div>

      <div style={{ flex: 1, overflow: 'auto' }}>
        <div style={{ padding: '16px', display: 'flex', alignItems: 'center', gap: 14, background: LL.bgAlt, borderBottom: `1px solid ${LL.border}` }}>
          <div style={{ width: 56, height: 56, borderRadius: 28, background: '#fff', border: `1px solid ${LL.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18, fontWeight: 600 }}>
            MT
          </div>
          <div>
            <div style={{ fontSize: 15, fontWeight: 600, color: LL.text }} className="ll-text-primary">Margaret Thompson</div>
            <div style={{ fontSize: 12, color: LL.textSec, marginTop: 2, display: 'flex', gap: 6 }} className="ll-text-sec">
              <span>72세</span>
              <span>•</span>
              <span>은퇴한 교육자</span>
            </div>
          </div>
        </div>

        {/* Progress summary */}
        <div style={{
          margin: '16px', padding: 16, background: LL.bgAlt,
          border: `1px solid ${LL.border}`, borderRadius: 12,
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <div style={{ fontSize: 15, fontWeight: 500, color: LL.text }} className="ll-text-primary">7개 챕터 중 3개 완료</div>
          </div>
          <div style={{ fontSize: 13, color: LL.textSec, marginTop: 2 }} className="ll-text-sec">잘 하고 계세요. 계속 이어가봐요.</div>
          <div style={{ marginTop: 14 }}>
            <ProgressBar value={totalDone / total} height={6}/>
            <div style={{ fontSize: 11, color: LL.textPh, textAlign: 'right', marginTop: 4 }} className="ll-text-ph">43%</div>
          </div>
        </div>

        {/* Chapters */}
        <div style={{ padding: '0 16px 16px' }}>
          <div style={{ ...T.sectionLabel, marginBottom: 12 }} className="ll-text-ph">나의 챕터</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {CHAPTERS.map(ch => (
              <ChapterCard key={ch.n} ch={ch} onClick={() => nav && nav('07_Chat')}/>
            ))}
          </div>
        </div>
      </div>
      
      {/* Footer CTA */}
      <div style={{ padding: '10px 16px', borderTop: `1px solid ${LL.border}` }}>
        <button onClick={() => nav && nav('11_GenConfirm')} style={{ width: '100%', padding: '12px', background: LL.successBg, color: LL.success, border: `1px solid ${LL.success}`, borderRadius: 8, cursor: 'pointer', fontWeight: 500 }}>아바타 생성하기</button>
      </div>
    </Screen>
  );
}

Object.assign(window, { S01_Main, S02_Login, S03_Profile, S04_Complete, S05_Dashboard, S06_Home });