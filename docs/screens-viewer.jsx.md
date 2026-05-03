// screens-viewer.jsx — screens 17, 18a, 18, 19: viewer entry flow

// ─── Screen 17: ViewerEntryPage ─────────────────────────────
function S17_ViewerEntry({ nav }) {
  const code = 'A3F7K2';
  return (
    <Screen label="17 ViewerEntry">
      <StatusBar />
      <div style={{ textAlign: 'center', paddingTop: 40, fontSize: 16, fontWeight: 500, color: LL.text, letterSpacing: -0.2 }} className="ll-text-primary">
        Life Legacy
      </div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '48px 24px 0' }}>
        {Icon.key(44, LL.text)}
        <div style={{ fontSize: 22, fontWeight: 600, color: LL.text, marginTop: 24, textAlign: 'center' }} className="ll-text-primary">
          뷰어 코드를 입력해주세요
        </div>
        <div style={{ fontSize: 14, color: LL.textSec, marginTop: 8, textAlign: 'center', maxWidth: 280, lineHeight: 1.6 }} className="ll-text-sec">
          이야기를 공유해주신 분께<br/>받은 6자리 코드를 입력하세요.
        </div>

        <div style={{ display: 'flex', gap: 8, marginTop: 40 }}>
          {code.split('').map((c, i) => (
            <div key={i} className="ll-border" style={{ width: 42, height: 50, border: `1px solid ${LL.border}`, borderRadius: 8, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18, fontWeight: 600, color: LL.text }}>
              {c}
            </div>
          ))}
        </div>

        <div style={{ width: '100%', marginTop: 48 }}>
          <button onClick={() => nav && nav('18a_ViewerRole')} style={{ width: '100%', padding: '14px', background: LL.cta, color: '#fff', border: 'none', borderRadius: 10, fontSize: 15, fontWeight: 500, cursor: 'pointer' }}>입장하기</button>
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 18a: ViewerRolePage ─────────────────────────────
function S18a_ViewerRole({ nav }) {
  return (
    <Screen label="18a ViewerRole">
      <StatusBar />
      <IOSNavBar title="관계 선택" onBack={() => nav && nav('17_ViewerEntry')}/>
      <div style={{ padding: '24px 20px', flex: 1, overflow: 'auto' }}>
        <div>
          <div style={{ fontSize: 16, fontWeight: 600, color: LL.text }} className="ll-text-primary">Margaret 님을 어떻게 부르시나요?</div>
          <div style={{ fontSize: 13, color: LL.textSec, marginTop: 4 }} className="ll-text-sec">선택한 역할에 따라 AI 아바타의 어조가 달라집니다.</div>
        </div>

        <div style={{ marginTop: 24, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {AVATAR_ROLES.map(r => {
            const selected = getSelectedRole().id === r.id;
            return (
              <button
                key={r.id}
                onClick={() => {
                  setSelectedRole(r.id);
                  nav && nav('18_ViewerChat');
                }}
                style={{
                  width: '100%', display: 'flex', alignItems: 'center', gap: 12,
                  padding: '12px 12px', border: `1px solid ${selected ? LL.text : LL.border}`,
                  borderRadius: 10, background: selected ? LL.bgAlt : '#fff',
                  marginBottom: 8, cursor: 'pointer', fontFamily: 'inherit', textAlign: 'left',
                }}>
                <div className="ll-surface-alt ll-border" style={{
                  width: 34, height: 34, borderRadius: 17, background: '#fff',
                  border: `1px solid ${LL.border}`, display: 'flex', alignItems: 'center',
                  justifyContent: 'center', fontSize: 15, color: LL.textSec, flexShrink: 0,
                }}>{r.emoji}</div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 14, fontWeight: 500, color: LL.text }}>{r.name}</div>
                  <div style={{ fontSize: 11, color: LL.textPh, marginTop: 2 }} className="ll-text-ph">{r.sub}</div>
                </div>
                {selected && (
                  <div style={{ fontSize: 11, fontWeight: 500, color: LL.text }}>선택됨</div>
                )}
              </button>
            );
          })}
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 18: ViewerChatPage ────────────────────────────
function S18_ViewerChat({ nav }) {
  const [role, setRole] = React.useState(getSelectedRole());

  React.useEffect(() => {
    const handleRole = () => setRole(getSelectedRole());
    window.addEventListener('ll-role-change', handleRole);
    return () => window.removeEventListener('ll-role-change', handleRole);
  }, []);

  return (
    <Screen label="18 ViewerChat">
      <StatusBar />
      <div className="ll-border" style={{ borderBottom: `1px solid ${LL.border}`, padding: '6px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', height: 48 }}>
        <button onClick={() => nav && nav('18a_ViewerRole')} style={{ border: 'none', background: 'none', padding: 0, cursor: 'pointer' }}>
          <span style={{ fontSize: 14, color: LL.textSec }}>역할 변경</span>
        </button>
        <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
          <span style={{ fontSize: 13, fontWeight: 600, color: LL.text }}>{role.name} 모드</span>
        </div>
        <button onClick={() => nav && nav('19_ViewerAudio')} style={{ border: 'none', background: 'none', padding: 0, cursor: 'pointer' }}>
          {Icon.volume(16)}
        </button>
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: '16px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        <AIBubble time="오전 10:00">{role.greet}</AIBubble>
        <AIBubble time="오전 10:01">{role.sample}</AIBubble>
      </div>

      <div className="ll-border" style={{ borderTop: `1px solid ${LL.border}`, padding: '10px 16px', background: '#fff' }}>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <input style={{ flex: 1, border: `1px solid ${LL.border}`, borderRadius: 8, padding: '10px 12px', fontSize: 14, outline: 'none', fontFamily: LL.font }} placeholder="아바타에게 질문하기..." />
          <button style={{ padding: '10px 14px', background: LL.text, color: '#fff', border: 'none', borderRadius: 8, fontWeight: 500, cursor: 'pointer' }}>전송</button>
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 19: ViewerAudioOptionsPage ────────────────────
function S19_ViewerAudio({ nav }) {
  const [listen, setListen] = React.useState(true);
  return (
    <Screen label="19 ViewerAudio">
      <StatusBar />
      <IOSNavBar title="음성 및 설정" onBack={() => nav && nav('18_ViewerChat')}/>
      <div style={{ flex: 1, padding: 20 }}>
        <div className="ll-border" style={{ border: `1px solid ${LL.border}`, borderRadius: 12, padding: 16 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div style={{ fontSize: 14, fontWeight: 500, color: LL.text }}>음성으로 듣기</div>
              <div style={{ fontSize: 11, color: LL.textSec, marginTop: 2 }}>아바타의 음성 기능을 사용합니다.</div>
            </div>
            <span onClick={() => setListen(l => !l)}><Toggle on={listen}/></span>
          </div>
        </div>
      </div>
    </Screen>
  );
}

Object.assign(window, { S17_ViewerEntry, S18a_ViewerRole, S18_ViewerChat, S19_ViewerAudio });