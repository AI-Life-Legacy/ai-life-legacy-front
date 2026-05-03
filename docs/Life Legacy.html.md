<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8"/>
<title>Life Legacy — Prototype</title>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<style>
  html, body { margin: 0; padding: 0; background: #f0eee9; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif; }
  * { box-sizing: border-box; }
  /* Korean: keep syllables within words so lines don't break mid-word */
  :lang(ko), html { word-break: keep-all; line-break: strict; }
  /* Tweaks panel */
  .tw-panel {
    position: fixed; bottom: 20px; right: 20px; z-index: 100;
    background: #fff; border: 1px solid #E9E9E7; border-radius: 12px;
    padding: 14px 16px; box-shadow: 0 10px 32px rgba(0,0,0,0.12);
    display: flex; flex-direction: column; gap: 10px; min-width: 220px;
    font-family: "Inter", system-ui, sans-serif; font-size: 13px; color: #37352F;
  }
  .tw-title { font-size: 11px; font-weight: 600; color: #9B9A97; letter-spacing: 0.05em; text-transform: uppercase; }
  .tw-row { display: flex; justify-content: space-between; align-items: center; gap: 16px; }
  .tw-btn { padding: 4px 8px; border-radius: 6px; border: 1px solid #E9E9E7; background: #FAFAFA; font-size: 11px; font-weight: 500; cursor: pointer; }
  .tw-btn.on { background: #2F3437; color: #fff; border-color: #2F3437; }
</style>
<script src="[https://unpkg.com/react@18/umd/react.development.js](https://unpkg.com/react@18/umd/react.development.js)" crossorigin></script>
<script src="[https://unpkg.com/react-dom@18/umd/react-dom.development.js](https://unpkg.com/react-dom@18/umd/react-dom.development.js)" crossorigin></script>
<script src="[https://unpkg.com/@babel/standalone/babel.min.js](https://unpkg.com/@babel/standalone/babel.min.js)"></script>
</head>
<body>

<div id="root"></div>

<script src="primitives.jsx" data-type="jsx"></script>
<script src="avatar-roles.jsx" data-type="jsx"></script>
<script src="design-canvas.jsx" data-type="jsx"></script>
<script src="ios-frame.jsx" data-type="jsx"></script>
<script src="android-frame.jsx" data-type="jsx"></script>
<script src="screens-onboarding.jsx" data-type="jsx"></script>
<script src="screens-writing.jsx" data-type="jsx"></script>
<script src="screens-generation.jsx" data-type="jsx"></script>
<script src="screens-utility.jsx" data-type="jsx"></script>
<script src="screens-viewer.jsx" data-type="jsx"></script>

<script type="text/babel">
// Dummy components, layout switch logic, top-level state
function Screen({ label, children }) {
  return (
    <div style={{
      width: '100%', height: '100%', display: 'flex', flexDirection: 'column',
      position: 'relative', background: '#fff', overflow: 'hidden',
    }}>
      {children}
    </div>
  );
}

function StatusBar() {
  return <IOSStatusBar/>;
}

function TextBtn({ children, onClick, color, fontSize }) {
  return (
    <span onClick={onClick} style={{ cursor: 'pointer', color, fontSize, fontWeight: 500, fontFamily: LL.font }}>
      {children}
    </span>
  );
}

function BtnSecondary({ children, onClick }) {
  return (
    <button onClick={onClick} style={{
      width: '100%', padding: '12px', background: LL.bgAlt,
      border: `1px solid ${LL.border}`, borderRadius: 8,
      fontSize: 15, fontWeight: 500, color: LL.text, cursor: 'pointer',
      textAlign: 'center', fontFamily: LL.font,
    }}>
      {children}
    </button>
  );
}

function BottomNav({ active, avatarUnlocked, onNavOption, onNavOptUn }) {
  return null;
}

// Global toggle buttons for screen mapping
const SCREENS = [
  { id: '01_Main', title: '온보딩', section: 'Writer', C: S01_Main },
  { id: '02_Login', title: '로그인', section: 'Writer', C: S02_Login },
  { id: '03_Profile', title: '프로필 설정', section: 'Writer', C: S03_Profile },
  { id: '04_Complete', title: '초기 세팅 완료', section: 'Writer', C: S04_Complete },
  { id: '05_Dashboard', title: '대시보드', section: 'Writer', C: S05_Dashboard },
  { id: '06_Home', title: '홈 화면', section: 'Writer', C: S06_Home },
  { id: '07_Chat', title: '챕터 인터뷰', section: 'Writer', C: S07_Chat },
  { id: '08_Write', title: '자유 답변 작성', section: 'Writer', C: S08_Write },
  { id: '09_List', title: '챕터 리스트', section: 'Writer', C: S09_List },
  { id: '10_Done', title: '모든 답변 완료', section: 'Writer', C: S10_Done },
  { id: '11_GenConfirm', title: '아바타 생성 모달', section: 'Generation', C: S11_GenConfirm },
  { id: '12_Generating', title: '아바타 생성 로딩', section: 'Generation', C: S12_Generating },
  { id: '13_Generated', title: '아바타 생성 완료', section: 'Generation', C: S13_Generated },
  { id: '14_Locked', title: '잠긴 아바타', section: 'Generation', C: S14_Locked },
  { id: '15_Search', title: '기억 검색', section: 'Utility', C: S15_Search },
  { id: '16_Settings', title: '설정', section: 'Utility', C: S16_Settings },
  { id: '17_ViewerEntry', title: '뷰어 입장', section: 'Viewer', C: S17_ViewerEntry },
  { id: '18_ViewerChat', title: '아바타 대화방', section: 'Viewer', C: S18_ViewerChat },
  { id: '18a_ViewerRole', title: '아바타 역할 선택', section: 'Viewer', C: S18a_ViewerRole },
  { id: '19_ViewerAudio', title: '음성 옵션', section: 'Viewer', C: S19_ViewerAudio },
];

function AIQuestionCard({ children, label }) {
  return (
    <div className="ll-border" style={{ margin: '12px 16px', background: LL.warnBg, borderRadius: 12, border: `1px solid ${LL.warnBorder}`, padding: '12px 14px' }}>
      <div style={{ fontSize: 11, color: LL.warning, fontWeight: 600, marginBottom: 4 }}>{label}</div>
      <div style={{ fontSize: 14, color: LL.text, lineHeight: 1.4 }}>{children}</div>
    </div>
  );
}

function Toggle({ on }) {
  return (
    <div style={{ width: 44, height: 24, borderRadius: 12, background: on ? LL.success : LL.border, position: 'relative', transition: 'background 0.2s' }}>
      <div style={{ width: 18, height: 18, borderRadius: 9, background: '#fff', position: 'absolute', top: 3, left: on ? 23 : 3, transition: 'all 0.2s' }}/>
    </div>
  );
}

function ProgressBar({ value, height }) {
  return (
    <div style={{ width: '100%', height, background: LL.border, borderRadius: height/2, overflow: 'hidden' }}>
      <div style={{ width: `${value * 100}%`, height, background: LL.cta }}/>
    </div>
  );
}

// App layout view
function LifeLegacyApp() {
  const [view, setView] = React.useState('prototype'); // 'prototype' | 'canvas'
  const [viewPersist, setViewPersist] = React.useState('prototype');
  const [activeScreen, setActiveScreen] = React.useState('01_Main');
  const [tweaks, setTweaks] = React.useState({
    device: 'ios',
    dark: false,
    role: 'curator',
  });

  const patch = (obj) => setTweaks({ ...tweaks, ...obj });

  // Custom role updates
  React.useEffect(() => {
    const handleRoleChange = () => {
      // triggers rerender
      setTweaks(t => ({ ...t }));
    };
    window.addEventListener('ll-role-change', handleRoleChange);
    return () => window.removeEventListener('ll-role-change', handleRoleChange);
  }, []);

  if (view === 'canvas') {
    return (
      <DesignCanvas>
        <DCSection id="onboarding" title="Onboarding" subtitle="Writer & Onboarding Screens">
          <DCArtboard id="01" label="01 Main"><S01_Main nav={setActiveScreen}/></DCArtboard>
          <DCArtboard id="02" label="02 Login"><S02_Login nav={setActiveScreen}/></DCArtboard>
          <DCArtboard id="03" label="03 Profile"><S03_Profile nav={setActiveScreen}/></DCArtboard>
          <DCArtboard id="04" label="04 Complete"><S04_Complete nav={setActiveScreen}/></DCArtboard>
        </DCSection>
        
        <DCSection id="dashboard" title="Dashboard">
          <DCArtboard id="05" label="05 Dashboard"><S05_Dashboard nav={setActiveScreen}/></DCArtboard>
          <DCArtboard id="06" label="06 Home"><S06_Home nav={setActiveScreen}/></DCArtboard>
        </DCSection>

        <DCSection id="writing" title="Writing Flows">
          <DCArtboard id="07" label="07 Chat"><S07_Chat nav={setActiveScreen}/></DCArtboard>
          <DCArtboard id="08" label="08 Write"><S08_Write nav={setActiveScreen}/></DCArtboard>
          <DCArtboard id="09" label="09 List"><S09_List nav={setActiveScreen}/></DCArtboard>
          <DCArtboard id="10" label="10 Done"><S10_Done nav={setActiveScreen}/></DCArtboard>
        </DCSection>
      </DesignCanvas>
    );
  }

  // Prototype Renderer
  const SelectedComponent = SCREENS.find(s => s.id === activeScreen)?.C || S01_Main;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100vh', alignItems: 'center', justifyContent: 'center' }}>
      {tweaks.device === 'ios' ? (
        <IOSDevice>
          <SelectedComponent nav={setActiveScreen} />
        </IOSDevice>
      ) : (
        <AndroidDevice label={activeScreen} onNav={() => setActiveScreen('06_Home')}>
          <SelectedComponent nav={setActiveScreen} />
        </AndroidDevice>
      )}

      {/* Screen Selector control UI */}
      <div style={{ marginTop: 24, display: 'flex', gap: 6, flexWrap: 'wrap', maxWidth: 420, justifyContent: 'center' }}>
        {SCREENS.map(s => (
          <button key={s.id} onClick={() => setActiveScreen(s.id)} style={{
            fontSize: 10, padding: '4px 6px', background: activeScreen === s.id ? '#2F3437' : '#fff',
            color: activeScreen === s.id ? '#fff' : '#37352F',
            border: '1px solid #E9E9E7', borderRadius: 4, cursor: 'pointer',
          }}>{s.title}</button>
        ))}
      </div>

      <div className="tw-panel">
        <div className="tw-title">프로토타입 컨트롤</div>
        <div className="tw-row">
          <label>기기</label>
          <div style={{ display: 'flex', gap: 4 }}>
            <button className={`tw-btn ${tweaks.device === 'ios' ? 'on' : ''}`} onClick={() => patch({ device: 'ios' })}>iOS</button>
            <button className={`tw-btn ${tweaks.device === 'android' ? 'on' : ''}`} onClick={() => patch({ device: 'android' })}>Android</button>
          </div>
        </div>
        <div className="tw-row">
          <label>화면 보기</label>
          <button className="tw-btn" onClick={() => setView('canvas')}>캔버스 편집기</button>
        </div>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<LifeLegacyApp/>);
</script>
</body>
</html>