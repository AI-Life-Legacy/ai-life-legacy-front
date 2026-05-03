// screens-generation.jsx — screens 11–14

// ─── Screen 11: GenConfirmModal ─────────────────────────────
function S11_GenConfirm({ nav }) {
  return (
    <Screen label="11 GenConfirm">
      <StatusBar />
      <div style={{ flex: 1, position: 'relative', background: LL.bg }}>
        <div style={{ position: 'absolute', inset: 0, opacity: 0.2, pointerEvents: 'none', padding: 16 }}>
          <div style={{ height: 40, background: LL.bgAlt, borderRadius: 10, marginBottom: 12 }}/>
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} style={{ height: 52, border: `1px solid ${LL.border}`, borderRadius: 10, marginBottom: 8 }}/>
          ))}
        </div>
        <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.3)' }}/>
        <div className="ll-fade-in" style={{ position: 'absolute', left: 0, right: 0, bottom: 0, background: '#fff', borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 24, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <div style={{ width: 36, height: 4, background: LL.border, borderRadius: 2, marginBottom: 16 }}/>
          {Icon.bookMarked(36, LL.text)}
          <div style={{ fontSize: 18, fontWeight: 600, color: LL.text, marginTop: 12 }} className="ll-text-primary">자서전을 완성하셨습니다</div>
          <div style={{ fontSize: 13, color: LL.textSec, textAlign: 'center', marginTop: 8, maxWidth: 280, lineHeight: 1.5 }} className="ll-text-sec">
            AI 아바타를 생성하면 가족들이 내 기억을 더 생생하게 만나볼 수 있습니다. 생성하시겠습니까?
          </div>

          <div style={{ marginTop: 24, width: '100%', display: 'flex', flexDirection: 'column', gap: 10 }}>
            <button onClick={() => nav && nav('12_Generating')} style={{ width: '100%', padding: '14px', background: LL.cta, color: '#fff', border: 'none', borderRadius: 10, fontSize: 15, fontWeight: 500, cursor: 'pointer' }}>아바타 생성하기</button>
            <BtnSecondary onClick={() => nav && nav('06_Home')}>다음에 하기</BtnSecondary>
          </div>
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 12: GeneratingPage ────────────────────────────
function S12_Generating({ nav }) {
  React.useEffect(() => {
    const t = setTimeout(() => {
      nav && nav('13_Generated');
    }, 3800);
    return () => clearTimeout(t);
  }, [nav]);

  return (
    <Screen label="12 Generating">
      <StatusBar />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 32px' }}>
        <div style={{ width: 56, height: 56, background: LL.successBg, borderRadius: 28, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 20 }}>
          <div style={{ width: 20, height: 20, border: `3px solid ${LL.success}`, borderRadius: '50%', borderTopColor: 'transparent', animation: 'spin 1s linear infinite' }}/>
          <style>{`@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }`}</style>
        </div>
        <div style={{ fontSize: 18, fontWeight: 600, color: LL.text }} className="ll-text-primary">아바타 학습 중입니다</div>
        <div style={{ fontSize: 13, color: LL.textSec, textAlign: 'center', marginTop: 8, lineHeight: 1.5 }} className="ll-text-sec">
          기록하신 자서전 내용을 바탕으로 Margaret 님의 기억과 감성을 학습하고 있습니다. 잠시만 기다려주세요.
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 13: GeneratedPage ────────────────────────────
function S13_Generated({ nav }) {
  return (
    <Screen label="13 Generated">
      <StatusBar />
      <div style={{ padding: '12px 16px', display: 'flex', justifyContent: 'flex-end' }}>
        <TextBtn fontSize={14} color={LL.textSec} onClick={() => nav && nav('06_Home')}>완료</TextBtn>
      </div>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '16px 24px 0' }}>
        <div style={{ width: 72, height: 72, borderRadius: 36, background: LL.successBg, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24 }}>
          ✦
        </div>
        <div style={{ fontSize: 20, fontWeight: 600, color: LL.text, marginTop: 16 }} className="ll-text-primary">생성이 완료되었습니다</div>
        <div style={{ fontSize: 13, color: LL.textSec, textAlign: 'center', marginTop: 8, maxWidth: 280, lineHeight: 1.5 }} className="ll-text-sec">
          이제 가족들이 뷰어 코드를 통해 Margaret 님의 AI 아바타와 대화를 시작할 수 있습니다.
        </div>
        
        <div className="ll-border" style={{ marginTop: 32, width: '100%', background: LL.bgAlt, borderRadius: 12, border: `1px solid ${LL.border}`, padding: '16px', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <div style={{ fontSize: 11, color: LL.textPh, fontWeight: 600 }} className="ll-text-ph">가족용 뷰어 코드</div>
          <div style={{ fontSize: 24, fontWeight: 700, color: LL.cta, marginTop: 8, letterSpacing: '0.1em' }}>A3F7K2</div>
        </div>

        <div style={{ width: '100%', marginTop: 24 }}>
          <BtnSecondary onClick={() => nav && nav('18_ViewerChat')}>대화 테스트하기</BtnSecondary>
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 14: LockedPage ──────────────────────────────────
function S14_Locked({ nav }) {
  return (
    <Screen label="14 Locked">
      <StatusBar />
      <div style={{ padding: '12px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <TextBtn fontSize={14} color={LL.textSec} onClick={() => nav && nav('06_Home')}>닫기</TextBtn>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginTop: 48 }}>
        <div style={{ width: 64, height: 64, borderRadius: 32, background: LL.bgAlt, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20, fontWeight: 600 }}>
          MT
        </div>
        <div style={{ fontSize: 15, fontWeight: 500, color: LL.text, marginTop: 8 }} className="ll-text-primary">Margaret Thompson</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{ width: 6, height: 6, borderRadius: 3, background: LL.textPh }}/>
          <span style={{ fontSize: 12, color: LL.textPh }} className="ll-text-ph">잠김</span>
        </div>
      </div>

      <div style={{ flex: 1, position: 'relative' }}>
        <div style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 24px', gap: 16 }}>
          {Icon.lock(40, LL.border)}
          <div style={{ fontSize: 15, fontWeight: 500, color: LL.text, textAlign: 'center', maxWidth: 220, lineHeight: 1.5 }} className="ll-text-primary">
            자서전을 완성하면<br/>아바타 대화가 열려요
          </div>
          <div style={{ width: 200 }}>
            <BtnSecondary onClick={() => nav && nav('06_Home')}>계속 쓰러 가기</BtnSecondary>
          </div>
        </div>
      </div>
    </Screen>
  );
}

Object.assign(window, { S11_GenConfirm, S12_Generating, S13_Generated, S14_Locked });