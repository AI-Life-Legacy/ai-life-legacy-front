// screens-writing.jsx — screens 7–10: chapter chat, completion, autobiography list, write.

// ─── Screen 7: ChapterChatPage ──────────────────────────────
function S07_Chat({ nav }) {
  const allDone = false;
  return (
    <Screen label="07 Chat">
      <StatusBar />
      <div className="ll-border" style={{ borderBottom: `1px solid ${LL.border}`, padding: '6px 12px', display: 'flex', alignItems: 'center', gap: 8 }}>
        <button className="ll-pressable" onClick={() => nav && nav('06_Home')} style={{ width: 40, height: 40, borderRadius: 8, border: 'none', background: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          {Icon.arrow(20)}
        </button>
        <div style={{ flex: 1, textAlign: 'center', fontSize: 15, fontWeight: 500, color: LL.text }} className="ll-text-primary">Ch.2 — 청소년기</div>
        <div style={{ fontSize: 13, color: LL.textPh, width: 40, textAlign: 'right' }} className="ll-text-ph">3/8</div>
      </div>

      <AIQuestionCard label="AI 질문">
        학창 시절 가장 좋아했던 과목은 무엇이었고, 그 이유는 무엇인가요?
      </AIQuestionCard>

      <div style={{ flex: 1, overflow: 'auto', padding: '8px 16px 12px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        <AIBubble time="오전 9:10">학창 시절 기억 중에서 가장 남는 장면이나 과목을 들려주세요.</AIBubble>
        <UserBubble time="오전 9:15">Mrs. Harlow 선생님의 영문학 수업이요. 책 속에 삶이 있다는 걸 처음 가르쳐 주신 분이었어요.</UserBubble>
        <AIBubble time="오전 9:16">그 수업이 Margaret님의 삶에 어떤 영감을 주었나요?</AIBubble>
      </div>

      <div className="ll-border" style={{ borderTop: `1px solid ${LL.border}`, padding: '10px 16px', display: 'flex', gap: 10, background: '#fff' }}>
        <button onClick={() => nav && nav('08_Write')} style={{ width: 40, height: 40, borderRadius: 8, border: `1px solid ${LL.border}`, background: LL.bgAlt, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          {Icon.pencil(16, LL.text)}
        </button>
        <input style={{ flex: 1, padding: '8px 12px', border: `1px solid ${LL.border}`, borderRadius: 8, outline: 'none', fontFamily: LL.font, fontSize: 14 }} placeholder="Mrs. Harlow 선생님은..." />
        <button onClick={() => nav && nav('09_List')} style={{ padding: '0 16px', background: LL.cta, color: '#fff', border: 'none', borderRadius: 8, fontWeight: 500, cursor: 'pointer' }}>전송</button>
      </div>
    </Screen>
  );
}

// ─── Screen 8: WritePage ────────────────────────────────────
function S08_Write({ nav }) {
  const [text, setText] = React.useState('Mrs. Harlow 선생님의 영문학 수업. 학생 하나하나를 진심으로 봐주셨고, "네 안에 이야기가 있어"라고 자주 말씀하셨죠. 선생님의 말씀을 통해 내면의 목소리를 처음 들을 수 있었어요.');
  const [chars, setChars] = React.useState(text.length);

  React.useEffect(() => {
    setChars(text.length);
  }, [text]);

  return (
    <Screen label="08 Write">
      <StatusBar />
      <div className="ll-border" style={{ borderBottom: `1px solid ${LL.border}`, padding: '8px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <TextBtn fontSize={14} color={LL.textSec} onClick={() => nav && nav('07_Chat')}>취소</TextBtn>
        <span style={{ fontSize: 14, fontWeight: 600, color: LL.text }}>기억 수정 · 기록하기</span>
        <TextBtn fontSize={14} color={LL.success} onClick={() => nav && nav('07_Chat')}>저장</TextBtn>
      </div>

      <div style={{ padding: '16px 16px 8px' }}>
        <div style={{ ...T.sectionLabel, marginBottom: 6 }} className="ll-text-ph">질문</div>
        <div style={{ fontSize: 15, fontWeight: 500, color: LL.text, lineHeight: 1.5 }} className="ll-text-primary">당신의 가장 어릴 적 기억은 무엇인가요?</div>
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: '0 16px 16px' }}>
        <textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          style={{
            width: '100%', minHeight: 260, border: 'none', outline: 'none', resize: 'none',
            fontSize: 16, color: LL.text, lineHeight: 1.7, background: 'transparent',
          }}
          placeholder="답변을 여기에 적어보세요..."
        />
      </div>

      <div className="ll-border" style={{ flexShrink: 0, borderTop: `1px solid ${LL.border}`, padding: '8px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: '#fff' }}>
        <span style={{ fontSize: 12, color: LL.textPh }} className="ll-text-ph">{chars}자</span>
        <div style={{ display: 'flex', gap: 16 }}>
          <button style={{ background: 'none', border: 'none', padding: 4, cursor: 'pointer', display: 'flex' }}>{Icon.chevLeft(20)}</button>
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 9: ChapterListPage ───────────────────────────
function S09_List({ nav }) {
  return (
    <Screen label="09 List">
      <StatusBar />
      <IOSNavBar title="챕터 완료 리스트" onBack={() => nav && nav('06_Home')}/>
      <div style={{ flex: 1, overflow: 'auto', padding: 20 }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {[{ title: '유년기: 기억', done: true }, { title: '청소년기: 학창 시절', done: true }].map((ch, i) => (
            <div key={i} style={{ border: `1px solid ${LL.border}`, padding: '16px', borderRadius: 10, background: LL.bg, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <span style={{ fontSize: 14, fontWeight: 500, color: LL.text }}>챕터 {i + 1}. {ch.title}</span>
                <div style={{ fontSize: 12, color: LL.textSec, marginTop: 4 }}>답변 완료 8개 / 8개</div>
              </div>
              <button onClick={() => nav && nav('08_Write')} style={{ background: LL.bgAlt, border: `1px solid ${LL.border}`, padding: '6px 12px', borderRadius: 6, cursor: 'pointer', fontSize: 12, fontWeight: 500 }}>
                수정
              </button>
            </div>
          ))}
        </div>
        <div style={{ marginTop: 24 }}>
          <button onClick={() => nav && nav('10_Done')} style={{ width: '100%', padding: '14px', background: LL.cta, color: '#fff', border: 'none', borderRadius: 8 }}>완료 상태로 전환</button>
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 10: CompletionPage ──────────────────────────────
function S10_Done({ nav }) {
  return (
    <Screen label="10 Done">
      <StatusBar />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', padding: '0 32px' }}>
        <div style={{ width: 64, height: 64, background: LL.successBg, borderRadius: 32, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24, marginBottom: 24 }}>
          ✨
        </div>
        <div style={{ fontSize: 20, fontWeight: 600, color: LL.text, textAlign: 'center' }} className="ll-text-primary">
          축하합니다. <br/> 모든 챕터를 완료했어요.
        </div>
        <div style={{ fontSize: 13, color: LL.textSec, marginTop: 12, textAlign: 'center', maxWidth: 260 }} className="ll-text-sec">
          Margaret님의 소중한 삶의 기록이 전부 모였습니다. 이제 아바타 생성 기능이 열립니다.
        </div>
        <div style={{ width: 200, marginTop: 32 }}>
          <BtnSecondary onClick={() => nav && nav('13_Generated')}>아바타 확인</BtnSecondary>
        </div>
      </div>
    </Screen>
  );
}

Object.assign(window, { S07_Chat, S08_Write, S09_List, S10_Done });