# Life Legacy - 전체 소스코드 통합본

## 1. screens-utility.jsx

```jsx
// screens-utility.jsx — screens 15–16

// ─── Screen 15: SearchPage ──────────────────────────────────
function S15_Search({ nav }) {
  const [query, setQuery] = React.useState('학교');
  const results = [
    { ch: 2, q: '학창 시절 가장 좋아했던 과목은 무엇이었고, 그 이유는 무엇인가요?', a: 'Mrs. Harlow 선생님의 영문학 수업. 학생 하나하나를 진심으로 봐주셨고, "네 안에 이야기가 있어"라고 자주 말씀하셨죠.' },
    { ch: 5, q: '선생님이 되고 처음 맡은 반은 어땠나요?', a: '작은 학교의 3학년 반이었어요. 스무 명 남짓한 아이들과 함께한 첫 해가 지금도 가장 선명해요.' },
    { ch: 2, q: '학교에서 가장 기억에 남는 친구는 누구인가요?', a: 'Ruthie라는 아이였어요. 우리는 매일 같은 학교 버스를 탔고, 여름방학이면 같이 복숭아를 땄어요.' },
  ];
  return (
    <Screen label="15 Search">
      <StatusBar />
      <div style={{ padding: '8px 16px', display: 'flex', alignItems: 'center', gap: 10 }}>
        <div className="ll-border" style={{ flex: 1, height: 40, border: `1px solid ${LL.border}`, borderRadius: 8, display: 'flex', alignItems: 'center', padding: '0 12px', gap: 8 }}>
          {Icon.search(18, LL.textPh)}
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            style={{ border: 'none', outline: 'none', background: 'transparent', flex: 1, fontSize: 14, color: LL.text, fontFamily: 'inherit' }}
            placeholder="기억을 검색해보세요"
          />
        </div>
        <TextBtn fontSize={14} color={LL.textSec} onClick={() => nav && nav('06_Home')}>취소</TextBtn>
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: '16px' }}>
        <div style={{ ...T.sectionLabel, marginBottom: 12 }} className="ll-text-ph">검색 결과</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {results.map((r, i) => (
            <div key={i} className="ll-pressable ll-border" onClick={() => nav && nav('07_Chat')} style={{ padding: 14, background: LL.bg, border: `1px solid ${LL.border}`, borderRadius: 10, cursor: 'pointer' }}>
              <div style={{ fontSize: 11, color: LL.warning, marginBottom: 4, fontWeight: 500 }}>Ch.{r.ch} · 관련 기억</div>
              <div style={{ fontSize: 13, fontWeight: 500, color: LL.text, lineHeight: 1.4, marginBottom: 8 }} className="ll-text-primary">{r.q}</div>
              <div style={{ fontSize: 13, color: LL.textSec, lineHeight: 1.4 }} className="ll-text-sec">"{r.a}"</div>
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 16: SettingsPage ────────────────────────────────
function S16_Settings({ nav }) {
  const [notify, setNotify] = React.useState(true);
  const Row = ({ label, right, onClick }) => (
    <div className="ll-pressable" onClick={onClick} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 16px', borderBottom: `1px solid ${LL.border}`, cursor: 'pointer', background: LL.bg }}>
      <div style={{ fontSize: 15, color: LL.text }} className="ll-text-primary">{label}</div>
      <div>{right}</div>
    </div>
  );

  return (
    <Screen label="16 Settings">
      <StatusBar />
      <div className="ll-border" style={{ borderBottom: `1px solid ${LL.border}`, padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={() => nav && nav('06_Home')} style={{ border: 'none', background: 'none', padding: 4, cursor: 'pointer', display: 'flex' }}>{Icon.arrow(20)}</button>
        <div style={{ flex: 1, textAlign: 'center', fontSize: 15, fontWeight: 500, color: LL.text }} className="ll-text-primary">설정</div>
        <div style={{ width: 28 }} />
      </div>

      <div style={{ flex: 1, overflow: 'auto' }}>
        <div style={{ display: 'flex', flexDirection: 'column', padding: '24px 16px 16px', alignItems: 'center', borderBottom: `1px solid ${LL.border}`, background: LL.bgAlt }}>
          <div style={{ width: 60, height: 60, borderRadius: 30, background: LL.textPh, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20, fontWeight: 600 }}>MT</div>
          <div style={{ fontSize: 16, fontWeight: 600, color: LL.text, marginTop: 10 }} className="ll-text-primary">Margaret Thompson</div>
          <div style={{ fontSize: 12, color: LL.textSec, marginTop: 2 }} className="ll-text-sec">margaret.t@example.com</div>
        </div>

        <div style={{ ...T.sectionLabel, padding: '20px 16px 8px' }} className="ll-text-ph">진행 상황</div>
        <div className="ll-border" style={{ borderTop: `1px solid ${LL.border}` }}>
          <Row label="내 자서전 다운로드" right={Icon.download(16, LL.textSec)} onClick={() => {}}/>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 16px', background: LL.bg }}>
            <span style={{ fontSize: 15, color: LL.text }}>데이터 공유 허용</span>
            <span style={{ borderRadius: 4 }} className="ll-border">완료 ✓</span>
          </div>
        </div>

        <div style={{ ...T.sectionLabel, padding: '20px 16px 8px' }} className="ll-text-ph">알림</div>
        <div className="ll-border" style={{ borderTop: `1px solid ${LL.border}` }}>
          <Row label="인터뷰 리마인더" right={
            <span onClick={() => setNotify(n => !n)} style={{ cursor: 'pointer' }}><Toggle on={notify}/></span>
          }/>
          <Row label="알림 시간" right={
            <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <span style={{ fontSize: 14, color: LL.textSec }}>오전 9:00</span>
              {Icon.chevRight(16)}
            </div>
          } onClick={() => {}}/>
        </div>

        <div style={{ ...T.sectionLabel, padding: '20px 16px 8px' }} className="ll-text-ph">계정</div>
        <div className="ll-border" style={{ borderTop: `1px solid ${LL.border}` }}>
          <Row label="비밀번호 변경" right={Icon.chevRight(16)} onClick={() => {}}/>
          <Row label="로그아웃" onClick={() => nav && nav('01_Main')}/>
        </div>

        <div style={{ textAlign: 'center', margin: '28px 0 32px' }}>
          <TextBtn fontSize={15} color={LL.error}>계정 삭제</TextBtn>
        </div>
      </div>
    </Screen>
  );
}

Object.assign(window, { S15_Search, S16_Settings });