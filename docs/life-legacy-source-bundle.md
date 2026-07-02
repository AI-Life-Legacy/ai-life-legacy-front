# AI 자서전 앱 (Life Legacy) — 전체 소스 코드

> 이 문서는 프로젝트의 모든 소스 파일을 하나로 모은 참고용 자료입니다.
> Antigravity 등 다른 도구에서 디자인/코드를 참고할 때 사용하세요.

## 📁 파일 구조

```
Life Legacy.html
primitives.jsx
avatar-roles.jsx
ios-frame.jsx
android-frame.jsx
design-canvas.jsx
screens-onboarding.jsx
screens-writing.jsx
screens-generation.jsx
screens-viewer.jsx
screens-utility.jsx
```

---

## 📑 목차

1. [Life Legacy.html](#1-life-legacy-html)
2. [primitives.jsx](#2-primitives-jsx)
3. [avatar-roles.jsx](#3-avatar-roles-jsx)
4. [ios-frame.jsx](#4-ios-frame-jsx)
5. [android-frame.jsx](#5-android-frame-jsx)
6. [design-canvas.jsx](#6-design-canvas-jsx)
7. [screens-onboarding.jsx](#7-screens-onboarding-jsx)
8. [screens-writing.jsx](#8-screens-writing-jsx)
9. [screens-generation.jsx](#9-screens-generation-jsx)
10. [screens-viewer.jsx](#10-screens-viewer-jsx)
11. [screens-utility.jsx](#11-screens-utility-jsx)

---

## 1. Life Legacy.html

- **경로:** `Life Legacy.html`
- **줄 수:** 231
- **크기:** 13,842 bytes

```html
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
  .tw-title { font-size: 11px; font-weight: 600; color: #9B9A97; letter-spacing: 0.08em; text-transform: uppercase; }
  .tw-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
  .tw-row label { color: #37352F; }
  .tw-row select, .tw-row button { font: inherit; }
  .tw-btn { border: 1px solid #E9E9E7; background: #fff; border-radius: 6px; padding: 5px 10px; cursor: pointer; color: #37352F; }
  .tw-btn.on { background: #2F3437; color: #fff; border-color: #2F3437; }
</style>
</head>
<body>
<div id="root"></div>

<script src="https://unpkg.com/react@18.3.1/umd/react.development.js" integrity="sha384-hD6/rw4ppMLGNu3tX5cjIb+uRZ7UkRJ6BPkLpg4hAu/6onKUg4lLsHAs9EBPT82L" crossorigin="anonymous"></script>
<script src="https://unpkg.com/react-dom@18.3.1/umd/react-dom.development.js" integrity="sha384-u6aeetuaXnQ38mYT8rp6sbXaQe3NL9t+IBXmnYxwkUI2Hw4bsp2Wvmx4yRQF1uAm" crossorigin="anonymous"></script>
<script src="https://unpkg.com/@babel/standalone@7.29.0/babel.min.js" integrity="sha384-m08KidiNqLdpJqLq95G/LEi8Qvjl/xUYll3QILypMoQ65QorJ9Lvtp2RXYGBFj1y" crossorigin="anonymous"></script>

<script type="text/babel" src="design-canvas.jsx"></script>
<script type="text/babel" src="primitives.jsx"></script>
<script type="text/babel" src="screens-onboarding.jsx"></script>
<script type="text/babel" src="screens-writing.jsx"></script>
<script type="text/babel" src="screens-generation.jsx"></script>
<script type="text/babel" src="screens-utility.jsx"></script>
<script type="text/babel" src="avatar-roles.jsx"></script>
<script type="text/babel" src="screens-viewer.jsx"></script>

<script type="text/babel">
// ─── Tweak defaults ──────────────────────────────────────────
const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "dark": false
}/*EDITMODE-END*/;

function useTweaks() {
  const [state, setState] = React.useState(TWEAK_DEFAULTS);
  const [active, setActive] = React.useState(false);
  React.useEffect(() => {
    const onMsg = (e) => {
      if (!e.data || !e.data.type) return;
      if (e.data.type === '__activate_edit_mode') setActive(true);
      if (e.data.type === '__deactivate_edit_mode') setActive(false);
    };
    window.addEventListener('message', onMsg);
    window.parent.postMessage({ type: '__edit_mode_available' }, '*');
    return () => window.removeEventListener('message', onMsg);
  }, []);
  const patch = (p) => {
    setState(s => ({ ...s, ...p }));
    window.parent.postMessage({ type: '__edit_mode_set_keys', edits: p }, '*');
  };
  return [state, patch, active];
}

// ─── Navigation targets ─────────────────────────────────────
const SCREEN_MAP = {
  '01_Main':        { C: S01_Main,       title: 'MainPage' },
  '02_Login':       { C: S02_Login,      title: 'LoginPage' },
  '03_SignUp':      { C: S03_SignUp,     title: 'SignUpPage' },
  '04_SelfIntro':   { C: S04_SelfIntro,  title: 'SelfIntroPage' },
  '05_ChapterGen':  { C: S05_ChapterGen, title: 'ChapterGenLoading' },
  '06_Home':        { C: S06_Home,       title: 'HomeTabView' },
  '07_Chat':        { C: S07_Chat,       title: 'ChapterChatPage' },
  '08_Complete':    { C: S08_Complete,   title: 'ChapterComplete (sheet)' },
  '09_BookList':    { C: S09_BookList,   title: 'AutobiographyList' },
  '10_Write':       { C: S10_Write,      title: 'AutobiographyWrite' },
  '11_GenConfirm':  { C: S11_GenConfirm, title: 'GenConfirm (sheet)' },
  '12_GenLoading':  { C: S12_GenLoading, title: 'GenerationLoading' },
  '13_BookComplete':{ C: S13_BookComplete,title:'AutobiographyComplete' },
  '14_Avatar':      { C: S14_Avatar,     title: 'AvatarChat (unlocked)' },
  '14_AvatarLocked':{ C: S14b_AvatarLocked, title: 'AvatarChat (locked)' },
  '15_Search':      { C: S15_Search,     title: 'SearchPage' },
  '16_MyPage':      { C: S16_MyPage,     title: 'MyPage' },
  '17_ViewerEntry': { C: S17_ViewerEntry, title: 'ViewerEntry' },
  '18a_RoleSelect': { C: S18a_RoleSelect, title: 'AvatarRoleSelect' },
  '18_ViewerIntro': { C: S18_ViewerIntro, title: 'ViewerAvatarIntro' },
  '19_ViewerChat':  { C: S19_ViewerChat,  title: 'ViewerAvatarChat' },
};

// ─── Artboard wrapper with shadow + bezel-free device ────────
function PhoneArtboard({ children, dark }) {
  return (
    <div style={{ width: LL.W, height: LL.H, background: dark ? '#191918' : '#fff', borderRadius: 28, overflow: 'hidden', boxShadow: '0 1px 2px rgba(0,0,0,0.04), 0 12px 40px rgba(0,0,0,0.08)', border: dark ? '1px solid #33332F' : '1px solid #E9E9E7' }}>
      {children}
    </div>
  );
}

// ─── Prototype mode: single phone + floating nav ─────────────
function PrototypeView({ dark }) {
  const [screen, setScreen] = React.useState(() => localStorage.getItem('ll-screen') || '01_Main');
  React.useEffect(() => { localStorage.setItem('ll-screen', screen); }, [screen]);
  const nav = (id) => setScreen(id);
  const Screen = SCREEN_MAP[screen];
  const C = Screen ? Screen.C : S01_Main;

  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 40, gap: 40 }}>
      <div style={{ width: 220, flexShrink: 0 }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: '#9B9A97', letterSpacing: '0.08em', textTransform: 'uppercase', marginBottom: 10 }}>화면 목록</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 2, maxHeight: 600, overflow: 'auto', padding: 4, background: '#fff', border: '1px solid #E9E9E7', borderRadius: 10 }}>
          {Object.entries(SCREEN_MAP).map(([k, v]) => (
            <button key={k} onClick={() => setScreen(k)}
              style={{ textAlign: 'left', padding: '8px 10px', border: 'none', background: screen === k ? '#F7F7F5' : 'transparent', borderRadius: 6, fontSize: 12, color: '#37352F', cursor: 'pointer', fontFamily: 'inherit' }}>
              <span style={{ color: '#9B9A97', marginRight: 6, fontFamily: 'ui-monospace, monospace' }}>{k.split('_')[0]}</span>
              {v.title}
            </button>
          ))}
        </div>
      </div>
      <PhoneArtboard dark={dark}>
        <C nav={nav}/>
      </PhoneArtboard>
    </div>
  );
}

// ─── Canvas mode: all screens, grouped ───────────────────────
function CanvasView({ dark }) {
  const [focusedNav, setFocusedNav] = React.useState(null);
  // Clicking into a card from canvas switches to prototype mode at that screen.
  const gotoPrototype = (id) => {
    localStorage.setItem('ll-screen', id);
    window.dispatchEvent(new CustomEvent('ll-set-view', { detail: 'prototype' }));
  };
  const mk = (id) => {
    const S = SCREEN_MAP[id];
    return <S.C nav={gotoPrototype}/>;
  };
  return (
    <DesignCanvas>
      <DCSection id="writer-onb" title="Writer · 온보딩" subtitle="1 – 6 · 처음 앱을 여는 순간부터 홈 화면까지">
        <DCArtboard id="01" label="01 · MainPage"        width={LL.W} height={LL.H}>{mk('01_Main')}</DCArtboard>
        <DCArtboard id="02" label="02 · LoginPage"       width={LL.W} height={LL.H}>{mk('02_Login')}</DCArtboard>
        <DCArtboard id="03" label="03 · SignUpPage"      width={LL.W} height={LL.H}>{mk('03_SignUp')}</DCArtboard>
        <DCArtboard id="04" label="04 · SelfIntroPage"   width={LL.W} height={LL.H}>{mk('04_SelfIntro')}</DCArtboard>
        <DCArtboard id="05" label="05 · ChapterGenLoading" width={LL.W} height={LL.H}>{mk('05_ChapterGen')}</DCArtboard>
        <DCArtboard id="06" label="06 · HomeTabView"     width={LL.W} height={LL.H}>{mk('06_Home')}</DCArtboard>
      </DCSection>
      <DCSection id="writer-write" title="Writer · 집필" subtitle="7 – 10 · AI와 대화하며 한 챕터씩 채워 나가기">
        <DCArtboard id="07" label="07 · ChapterChatPage" width={LL.W} height={LL.H}>{mk('07_Chat')}</DCArtboard>
        <DCArtboard id="08" label="08 · ChapterComplete" width={LL.W} height={LL.H}>{mk('08_Complete')}</DCArtboard>
        <DCArtboard id="09" label="09 · AutobiographyList" width={LL.W} height={LL.H}>{mk('09_BookList')}</DCArtboard>
        <DCArtboard id="10" label="10 · AutobiographyWrite" width={LL.W} height={LL.H}>{mk('10_Write')}</DCArtboard>
      </DCSection>
      <DCSection id="writer-gen" title="Writer · 자서전 생성" subtitle="11 – 14 · 한 권의 책으로 엮고 아바타를 깨우는 순간">
        <DCArtboard id="11" label="11 · GenConfirm"      width={LL.W} height={LL.H}>{mk('11_GenConfirm')}</DCArtboard>
        <DCArtboard id="12" label="12 · GenerationLoading" width={LL.W} height={LL.H}>{mk('12_GenLoading')}</DCArtboard>
        <DCArtboard id="13" label="13 · AutobiographyComplete" width={LL.W} height={LL.H}>{mk('13_BookComplete')}</DCArtboard>
        <DCArtboard id="14" label="14 · AvatarChat (unlocked)" width={LL.W} height={LL.H}>{mk('14_Avatar')}</DCArtboard>
        <DCArtboard id="14b" label="14 · AvatarChat (locked)" width={LL.W} height={LL.H}>{mk('14_AvatarLocked')}</DCArtboard>
      </DCSection>
      <DCSection id="writer-util" title="Writer · 기타" subtitle="15 – 16 · 검색과 설정">
        <DCArtboard id="15" label="15 · SearchPage"      width={LL.W} height={LL.H}>{mk('15_Search')}</DCArtboard>
        <DCArtboard id="16" label="16 · MyPage"          width={LL.W} height={LL.H}>{mk('16_MyPage')}</DCArtboard>
      </DCSection>
      <DCSection id="viewer" title="Viewer · 가족용" subtitle="17 – 19 · 코드를 받은 가족이 고인·부모의 이야기를 만나는 흐름">
        <DCArtboard id="17" label="17 · ViewerEntry"     width={LL.W} height={LL.H}>{mk('17_ViewerEntry')}</DCArtboard>
        <DCArtboard id="18a" label="18a · AvatarRoleSelect" width={LL.W} height={LL.H}>{mk('18a_RoleSelect')}</DCArtboard>
        <DCArtboard id="18" label="18 · ViewerAvatarIntro" width={LL.W} height={LL.H}>{mk('18_ViewerIntro')}</DCArtboard>
        <DCArtboard id="19" label="19 · ViewerAvatarChat" width={LL.W} height={LL.H}>{mk('19_ViewerChat')}</DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}

// ─── App root ────────────────────────────────────────────────
function App() {
  const [tweaks, patch, active] = useTweaks();
  const [view, setView] = React.useState(() => localStorage.getItem('ll-view') || 'canvas');

  React.useEffect(() => {
    const h = (e) => { setView(e.detail); localStorage.setItem('ll-view', e.detail); };
    window.addEventListener('ll-set-view', h);
    return () => window.removeEventListener('ll-set-view', h);
  }, []);

  const setViewPersist = (v) => { setView(v); localStorage.setItem('ll-view', v); };

  return (
    <>
      {view === 'canvas' ? <CanvasView dark={tweaks.dark}/> : <PrototypeView dark={tweaks.dark}/>}

      {active && (
        <div className="tw-panel">
          <div className="tw-title">Tweaks</div>
          <div className="tw-row">
            <label>보기 모드</label>
            <div style={{ display: 'flex', gap: 4 }}>
              <button className={`tw-btn ${view === 'canvas' ? 'on' : ''}`} onClick={() => setViewPersist('canvas')}>캔버스</button>
              <button className={`tw-btn ${view === 'prototype' ? 'on' : ''}`} onClick={() => setViewPersist('prototype')}>프로토타입</button>
            </div>
          </div>
          <div className="tw-row">
            <label>다크 모드</label>
            <button className={`tw-btn ${tweaks.dark ? 'on' : ''}`} onClick={() => patch({ dark: !tweaks.dark })}>
              {tweaks.dark ? '켜짐' : '꺼짐'}
            </button>
          </div>
        </div>
      )}

      {/* Floating view toggle (always visible, top-right) */}
      <div style={{ position: 'fixed', top: 16, right: 16, zIndex: 50, display: 'flex', gap: 6, background: '#fff', border: '1px solid #E9E9E7', borderRadius: 10, padding: 4, boxShadow: '0 4px 14px rgba(0,0,0,0.06)', whiteSpace: 'nowrap' }}>
        <button onClick={() => setViewPersist('canvas')} style={{ border: 'none', background: view === 'canvas' ? '#2F3437' : 'transparent', color: view === 'canvas' ? '#fff' : '#37352F', padding: '6px 12px', borderRadius: 7, fontSize: 12, fontWeight: 500, cursor: 'pointer', fontFamily: 'inherit', whiteSpace: 'nowrap' }}>캔버스</button>
        <button onClick={() => setViewPersist('prototype')} style={{ border: 'none', background: view === 'prototype' ? '#2F3437' : 'transparent', color: view === 'prototype' ? '#fff' : '#37352F', padding: '6px 12px', borderRadius: 7, fontSize: 12, fontWeight: 500, cursor: 'pointer', fontFamily: 'inherit', whiteSpace: 'nowrap' }}>프로토타입</button>
      </div>
    </>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
</script>
</body>
</html>
```

## 2. primitives.jsx

- **경로:** `primitives.jsx`
- **줄 수:** 468
- **크기:** 28,530 bytes

```jsx
// primitives.jsx — Life Legacy design tokens + shared UI primitives
// Uses the Notion-inspired palette from the spec. All screens render at a
// canonical 390×844 frame (iPhone 14-ish) so they sit consistently in the
// design canvas.

const LL = {
  // Colors (strict palette from spec)
  bg: '#FFFFFF',
  bgAlt: '#F7F7F5',
  text: '#37352F',
  textSec: '#6B6B6B',
  textPh: '#9B9A97',
  border: '#E9E9E7',
  cta: '#2F3437',
  success: '#4DAB9A',
  warning: '#CB912F',
  error: '#D44C47',
  warnBg: '#FFFBF0',
  warnBorder: '#FDE68A',
  successBg: '#F0FAF8',
  highlight: '#FEF9C3',

  // Typography
  font: '"Inter", -apple-system, BlinkMacSystemFont, system-ui, "Segoe UI", sans-serif',

  // Sizes
  W: 390,
  H: 844,
};

// Global Inter stylesheet + reset for screens inside artboards
if (typeof document !== 'undefined' && !document.getElementById('ll-styles')) {
  const link = document.createElement('link');
  link.rel = 'stylesheet';
  link.href = 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap';
  document.head.appendChild(link);

  const s = document.createElement('style');
  s.id = 'll-styles';
  s.textContent = `
    .ll-screen, .ll-screen * { box-sizing: border-box; }
    .ll-screen { font-family: ${LL.font}; color: ${LL.text}; font-weight: 400; font-size: 16px; line-height: 1.6; -webkit-font-smoothing: antialiased; }
    .ll-screen button { font-family: inherit; }
    .ll-screen input, .ll-screen textarea { font-family: inherit; font-size: 16px; color: ${LL.text}; }
    .ll-screen input::placeholder, .ll-screen textarea::placeholder { color: ${LL.textPh}; }
    .ll-screen::-webkit-scrollbar { display: none; }
    .ll-btn-primary:active { opacity: 0.88; }
    .ll-btn-secondary:active { background: ${LL.bgAlt}; }
    .ll-pressable { cursor: pointer; transition: background 0.12s ease, opacity 0.12s ease; }
    .ll-pressable:active { opacity: 0.75; }
    .ll-card-tap { cursor: pointer; transition: background 0.12s ease; }
    .ll-card-tap:hover { background: ${LL.bgAlt}; }
    @keyframes ll-breathe { 0%,100% { transform: scale(0.97); } 50% { transform: scale(1.03); } }
    @keyframes ll-bar-fill { 0% { width: 10%; } 100% { width: 70%; } }
    @keyframes ll-pop { 0% { transform: scale(0.6); opacity: 0; } 60% { transform: scale(1.08); } 100% { transform: scale(1); opacity: 1; } }
    @keyframes ll-slide-up { from { transform: translateY(100%); } to { transform: translateY(0); } }
    @keyframes ll-fade-in { from { opacity: 0; } to { opacity: 1; } }
    .ll-breathe { animation: ll-breathe 2.4s ease-in-out infinite; }
    .ll-pop { animation: ll-pop 0.4s cubic-bezier(.3,1.4,.5,1) both; }
    .ll-fade-in { animation: ll-fade-in 0.35s ease-out both; }
    .ll-bar-anim > span { animation: ll-bar-fill 2.6s ease-in-out infinite alternate; }
    .ll-dark { background: #191918 !important; color: #E9E9E7 !important; }
    .ll-dark .ll-surface-alt { background: #232321 !important; border-color: #33332F !important; }
    .ll-dark .ll-border { border-color: #33332F !important; }
    .ll-dark .ll-cta { background: #E9E9E7 !important; color: #191918 !important; }
    .ll-dark .ll-sec-btn { background: #191918 !important; color: #E9E9E7 !important; border-color: #33332F !important; }
    .ll-dark .ll-text-primary { color: #E9E9E7 !important; }
    .ll-dark .ll-text-sec { color: #8B8B87 !important; }
    .ll-dark .ll-text-ph { color: #5B5B57 !important; }
  `;
  document.head.appendChild(s);
}

// ─────────────────────────────────────────────────────────────
// Frame — the phone-shaped artboard wrapper (no bezel; a clean screen)
// ─────────────────────────────────────────────────────────────
function Screen({ children, dark = false, style = {}, label }) {
  return (
    <div
      className={`ll-screen ${dark ? 'll-dark' : ''}`}
      data-screen-label={label}
      style={{
        width: LL.W, height: LL.H, overflow: 'hidden',
        background: dark ? '#191918' : LL.bg,
        position: 'relative', display: 'flex', flexDirection: 'column',
        ...style,
      }}>
      {children}
    </div>
  );
}

// Status bar — minimal Android-ish top status strip
function StatusBar({ dark = false }) {
  const c = dark ? '#E9E9E7' : LL.text;
  return (
    <div style={{
      height: 44, flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 22px', fontSize: 13, fontWeight: 500, color: c, letterSpacing: 0.2,
    }}>
      <span>9:41</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        {/* signal */}
        <svg width="16" height="10" viewBox="0 0 16 10"><rect x="0" y="7" width="2.5" height="3" rx="0.3" fill={c}/><rect x="4" y="5" width="2.5" height="5" rx="0.3" fill={c}/><rect x="8" y="3" width="2.5" height="7" rx="0.3" fill={c}/><rect x="12" y="0" width="2.5" height="10" rx="0.3" fill={c}/></svg>
        {/* wifi */}
        <svg width="14" height="10" viewBox="0 0 14 10" fill="none"><path d="M1 3.2C2.7 1.6 4.8.8 7 .8s4.3.8 6 2.4" stroke={c} strokeWidth="1.3" strokeLinecap="round"/><path d="M3.5 5.4c1-.9 2.2-1.4 3.5-1.4s2.5.5 3.5 1.4" stroke={c} strokeWidth="1.3" strokeLinecap="round"/><circle cx="7" cy="8.2" r="1" fill={c}/></svg>
        {/* battery */}
        <svg width="22" height="10" viewBox="0 0 22 10"><rect x="0.5" y="0.5" width="19" height="9" rx="2" fill="none" stroke={c} strokeOpacity="0.5"/><rect x="2" y="2" width="16" height="6" rx="1" fill={c}/><rect x="20" y="3.5" width="1.5" height="3" rx="0.5" fill={c} fillOpacity="0.5"/></svg>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Typography tokens
// ─────────────────────────────────────────────────────────────
const T = {
  display: { fontSize: 28, fontWeight: 600, lineHeight: 1.3, color: LL.text, letterSpacing: -0.2 },
  h1: { fontSize: 22, fontWeight: 600, lineHeight: 1.3, color: LL.text },
  h2: { fontSize: 18, fontWeight: 600, lineHeight: 1.3, color: LL.text },
  body: { fontSize: 16, fontWeight: 400, lineHeight: 1.6, color: LL.text },
  bodySec: { fontSize: 14, fontWeight: 400, lineHeight: 1.6, color: LL.textSec },
  label: { fontSize: 12, fontWeight: 500, color: LL.textSec, lineHeight: 1.4 },
  caption: { fontSize: 12, fontWeight: 400, color: LL.textPh, lineHeight: 1.4 },
  sectionLabel: { fontSize: 12, fontWeight: 500, color: LL.textPh, textTransform: 'uppercase', letterSpacing: '0.06em' },
};

// ─────────────────────────────────────────────────────────────
// Buttons
// ─────────────────────────────────────────────────────────────
function BtnPrimary({ children, icon, onClick, height = 48, disabled }) {
  return (
    <button
      className="ll-btn-primary ll-pressable ll-cta"
      onClick={onClick}
      disabled={disabled}
      style={{
        width: '100%', height, borderRadius: 8, border: 'none',
        background: disabled ? LL.textPh : LL.cta, color: '#fff',
        fontSize: 15, fontWeight: 500, cursor: disabled ? 'not-allowed' : 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      }}>
      {icon && <span style={{ display: 'flex' }}>{icon}</span>}
      {children}
    </button>
  );
}

function BtnSecondary({ children, icon, onClick, height = 44 }) {
  return (
    <button
      className="ll-btn-secondary ll-pressable ll-sec-btn"
      onClick={onClick}
      style={{
        width: '100%', height, borderRadius: 8,
        background: '#fff', color: LL.text, border: `1px solid ${LL.border}`,
        fontSize: 15, fontWeight: 500, cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      }}>
      {icon && <span style={{ display: 'flex' }}>{icon}</span>}
      {children}
    </button>
  );
}

function TextBtn({ children, color = LL.textSec, fontSize = 14, onClick, weight = 400, style = {} }) {
  return (
    <button className="ll-pressable" onClick={onClick}
      style={{ background: 'none', border: 'none', padding: 0, color, fontSize, fontWeight: weight, cursor: 'pointer', ...style }}>
      {children}
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────
function Field({ label, children, hint }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      {label && <div style={{ ...T.label, display: 'flex', alignItems: 'center', gap: 6 }}>{label}</div>}
      {children}
      {hint && <div style={{ ...T.caption, marginTop: 2 }}>{hint}</div>}
    </div>
  );
}

function Input({ value, placeholder, type = 'text', right, onFocus, autofocus }) {
  return (
    <div className="ll-border" style={{
      height: 44, border: `1px solid ${LL.border}`, borderRadius: 8,
      display: 'flex', alignItems: 'center', padding: '0 14px', background: '#fff',
      gap: 8,
    }}>
      <input
        type={type}
        defaultValue={value}
        placeholder={placeholder}
        autoFocus={autofocus}
        onFocus={onFocus}
        style={{
          flex: 1, border: 'none', outline: 'none', background: 'transparent',
          fontSize: 15, color: LL.text,
        }}
      />
      {right}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Icons (Lucide-style, 1.5px stroke, 20px default) — only the ones we use
// ─────────────────────────────────────────────────────────────
const Icon = {
  arrow: (size = 20, color = LL.text) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
  ),
  search: (size = 20, color = LL.textSec) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
  ),
  eye: (size = 20, color = LL.textSec) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
  ),
  check: (size = 20, color = LL.success) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
  ),
  circle: (size = 20, color = LL.border) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5"><circle cx="12" cy="12" r="9"/></svg>
  ),
  checkCircle: (size = 20, color = LL.success) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
  ),
  home: (size = 20, color = LL.textSec) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M3 9.5L12 3l9 6.5V20a2 2 0 0 1-2 2h-4v-7h-6v7H5a2 2 0 0 1-2-2V9.5z"/></svg>
  ),
  user: (size = 20, color = LL.textSec) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
  ),
  book: (size = 20, color = LL.textSec) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
  ),
  bookOpen: (size = 48, color = LL.text) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
  ),
  bookMarked: (size = 36, color = LL.text) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M19 21l-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z"/></svg>
  ),
  bookHeart: (size = 52, color = LL.text) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/><path d="M9.5 9.5c.6-.8 1.5-1.2 2.5-1.2s1.9.4 2.5 1.2c.6.8.9 1.9.3 2.8-.6.9-3 2.5-3 2.5s-2.3-1.6-3-2.5c-.6-.9-.4-2 .3-2.8z"/></svg>
  ),
  lock: (size = 20, color = LL.textPh) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
  ),
  unlock: (size = 16, color = '#fff') => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 9.9-1"/></svg>
  ),
  mic: (size = 20, color = LL.textSec) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><rect x="9" y="2" width="6" height="12" rx="3"/><path d="M19 10v2a7 7 0 0 1-14 0v-2"/><line x1="12" y1="19" x2="12" y2="22"/></svg>
  ),
  send: (size = 20, color = '#fff') => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
  ),
  volume: (size = 14, color = LL.textPh) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/></svg>
  ),
  chevDown: (size = 16, color = LL.textPh) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
  ),
  chevRight: (size = 16, color = LL.textPh) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 6 15 12 9 18"/></svg>
  ),
  chevLeft: (size = 20, color = LL.textSec) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
  ),
  x: (size = 14, color = LL.textPh) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
  ),
  info: (size = 20, color = LL.textPh) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
  ),
  alert: (size = 14, color = LL.warning) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
  ),
  download: (size = 18, color = '#fff') => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
  ),
  share: (size = 18, color = LL.text) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/></svg>
  ),
  key: (size = 44, color = LL.text) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.78 7.78 5.5 5.5 0 0 1 7.78-7.78zm0 0L15.5 7.5m0 0L19 4"/></svg>
  ),
  messageCircle: (size = 18, color = '#fff') => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/></svg>
  ),
  more: (size = 20, color = LL.textPh) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="5" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="12" cy="19" r="1"/></svg>
  ),
  google: (size = 18) => (
    <svg width={size} height={size} viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
  ),
  kakao: (size = 18) => (
    <svg width={size} height={size} viewBox="0 0 24 24"><path d="M12 3C6.48 3 2 6.58 2 11c0 2.89 1.95 5.42 4.87 6.8l-1.03 3.79c-.07.27.22.49.46.35l4.54-3c.38.05.77.06 1.16.06 5.52 0 10-3.58 10-8S17.52 3 12 3z" fill="#FFE812"/></svg>
  ),
  heart: (size = 18, color = '#fff') => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
  ),
  plus: (size = 16, color = LL.textSec) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
  ),
};

// ─────────────────────────────────────────────────────────────
// Status badge (Ch cards)
// ─────────────────────────────────────────────────────────────
function StatusBadge({ status }) {
  const styles = {
    'not-started': { color: LL.textPh, bg: 'transparent', text: '시작 전' },
    'in-progress': { color: LL.warning, bg: LL.warnBg, text: '진행 중' },
    'complete': { color: LL.success, bg: LL.successBg, text: '완료 ✓' },
  }[status];
  return (
    <span style={{
      fontSize: 11, fontWeight: 500, color: styles.color, background: styles.bg,
      padding: '2px 8px', borderRadius: 4, letterSpacing: 0.1,
    }}>{styles.text}</span>
  );
}

// ─────────────────────────────────────────────────────────────
// Bottom nav
// ─────────────────────────────────────────────────────────────
function BottomNav({ active = 'home', onNav, avatarUnlocked = false }) {
  const Tab = ({ id, iconFn, label, disabled }) => {
    const isActive = active === id;
    const color = disabled ? LL.textPh : (isActive ? LL.text : LL.textSec);
    return (
      <button
        onClick={() => onNav && onNav(id)}
        className="ll-pressable"
        style={{
          flex: 1, background: 'none', border: 'none', padding: '8px 0 10px',
          display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
          cursor: 'pointer', color,
        }}>
        <span style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>
          {iconFn(22, color)}
          {disabled && (
            <span style={{ position: 'absolute', bottom: -2, right: -3, width: 12, height: 12, borderRadius: 6, background: LL.bgAlt, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              {Icon.lock(8, LL.textPh)}
            </span>
          )}
        </span>
        <span style={{ fontSize: 11, fontWeight: isActive ? 500 : 400, letterSpacing: 0.1 }}>{label}</span>
      </button>
    );
  };
  return (
    <div className="ll-border" style={{
      flexShrink: 0, borderTop: `1px solid ${LL.border}`, background: '#fff',
      display: 'flex', padding: '0 8px', height: 64,
    }}>
      <Tab id="home" iconFn={Icon.home} label="홈" />
      <Tab id="avatar" iconFn={avatarUnlocked ? Icon.user : Icon.lock} label="아바타" disabled={!avatarUnlocked} />
      <Tab id="book" iconFn={Icon.book} label="자서전" />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Chat input bar (bottom)
// ─────────────────────────────────────────────────────────────
function ChatInput({ placeholder = '답변을 입력하세요...', value = '', onSend, recording = false }) {
  return (
    <div className="ll-border" style={{
      flexShrink: 0, borderTop: `1px solid ${LL.border}`, background: '#fff',
      padding: '10px 16px 14px', display: 'flex', alignItems: 'center', gap: 10,
    }}>
      <div className="ll-border" style={{
        flex: 1, minHeight: 40, border: `1px solid ${LL.border}`, borderRadius: 20,
        padding: '8px 14px', display: 'flex', alignItems: 'center',
        fontSize: 15, color: value ? LL.text : LL.textPh,
      }}>{value || placeholder}</div>
      <button className="ll-pressable" style={{
        width: 40, height: 40, borderRadius: 20, border: 'none',
        background: recording ? LL.error : LL.bgAlt,
        display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
      }}>{Icon.mic(20, recording ? '#fff' : LL.textSec)}</button>
      <button className="ll-pressable" disabled={!value} style={{
        width: 40, height: 40, borderRadius: 20, border: 'none',
        background: value ? LL.cta : LL.bgAlt,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: value ? 'pointer' : 'default',
      }}>{Icon.send(18, value ? '#fff' : LL.textPh)}</button>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Progress bar
// ─────────────────────────────────────────────────────────────
function ProgressBar({ value = 0.5, height = 6, fill = LL.cta, bg = LL.border }) {
  return (
    <div style={{ width: '100%', height, background: bg, borderRadius: 8, overflow: 'hidden' }}>
      <div style={{ width: `${Math.max(0, Math.min(1, value)) * 100}%`, height: '100%', background: fill, borderRadius: 8, transition: 'width 0.3s ease' }} />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// AI question card
// ─────────────────────────────────────────────────────────────
function AIQuestionCard({ children, label = 'AI 질문', listen = true }) {
  return (
    <div className="ll-surface-alt ll-border" style={{
      margin: '12px 16px', padding: 14, background: LL.bgAlt,
      border: `1px solid ${LL.border}`, borderRadius: 12,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 8 }}>
        <span style={{ width: 4, height: 4, borderRadius: 2, background: LL.textPh }}/>
        <span style={{ fontSize: 11, fontWeight: 500, color: LL.textPh, letterSpacing: 0.1 }}>{label}</span>
      </div>
      <div className="ll-text-primary" style={{ fontSize: 17, fontWeight: 500, color: LL.text, lineHeight: 1.5 }}>{children}</div>
      {listen && (
        <div style={{ display: 'flex', justifyContent: 'flex-end', alignItems: 'center', gap: 4, marginTop: 10 }}>
          {Icon.volume(14)}
          <span style={{ fontSize: 12, color: LL.textPh }}>다시 듣기</span>
        </div>
      )}
    </div>
  );
}

// Chat bubbles
function AIBubble({ children, time }) {
  return (
    <div style={{ maxWidth: '76%', alignSelf: 'flex-start', marginBottom: 2 }}>
      <div className="ll-surface-alt" style={{
        background: LL.bgAlt, borderRadius: 12, padding: '10px 12px',
        fontSize: 15, color: LL.text, lineHeight: 1.5,
      }}>{children}</div>
      {time && <div style={{ ...T.caption, marginTop: 4, marginLeft: 4 }}>{time}</div>}
    </div>
  );
}

function UserBubble({ children, time }) {
  return (
    <div style={{ maxWidth: '76%', alignSelf: 'flex-end', marginBottom: 2 }}>
      <div style={{
        background: LL.cta, color: '#fff', borderRadius: 12, padding: '10px 12px',
        fontSize: 15, lineHeight: 1.5,
      }}>{children}</div>
      {time && <div style={{ ...T.caption, marginTop: 4, textAlign: 'right', marginRight: 4 }}>{time}</div>}
    </div>
  );
}

// Export globals
Object.assign(window, {
  LL, T, Icon,
  Screen, StatusBar,
  BtnPrimary, BtnSecondary, TextBtn,
  Field, Input,
  StatusBadge, BottomNav, ChatInput,
  ProgressBar, AIQuestionCard, AIBubble, UserBubble,
});
```

## 3. avatar-roles.jsx

- **경로:** `avatar-roles.jsx`
- **줄 수:** 97
- **크기:** 4,294 bytes

```jsx
// avatar-roles.jsx — role model + sample responses for the avatar chat
// Shared between screens 18a / 18 / 19.

const AVATAR_ROLES = [
  {
    id: 'curator',
    name: '큐레이터',
    sub: 'Life Legacy 기본',
    desc: '3인칭 존댓말. Margaret 님의 이야기를 정리해 차분하게 안내합니다.',
    emoji: '✦',
    greet: '안녕하세요. 저는 Margaret 님의 이야기를 안내하는 큐레이터예요. 어떤 이야기가 궁금하신가요?',
    sample: 'Margaret 님께서는 오하이오의 작은 마을에서 자라셨어요. 어릴 적 가장 선명한 기억은 할머니 댁 뒤뜰의 복숭아나무라고 말씀하셨답니다.',
    tag: '큐레이터',
    group: '기본',
  },
  {
    id: 'father',
    name: '아버지',
    sub: '아빠로 부르는 관계',
    desc: '1인칭 반말. "아빠가 있지," 같은 다정하고 담백한 말투.',
    emoji: '◐',
    greet: '왔구나. 아빠다. 뭐가 궁금해서 왔어?',
    sample: '아빠가 네 나이쯤엔 말이야, 새벽마다 공장 굴뚝에서 연기 올라오는 거 보면서 학교 갔었지. 별거 아닌 것 같아도 그게 다 지금 생각하면 그립더라.',
    tag: '아버지',
    group: '가족',
  },
  {
    id: 'mother',
    name: '어머니',
    sub: '엄마로 부르는 관계',
    desc: '1인칭 반말. "엄마가 있잖니," 다정하고 포근한 말투.',
    emoji: '◑',
    greet: '왔어? 엄마야. 오늘은 무슨 얘기 하고 싶어서 왔니?',
    sample: '엄마는 네 살쯤, 할머니 뒷마당 복숭아 나무 아래서 놀던 여름 오후가 제일 선명해. 벌들이 맴돌던 소리, 그 단내. 엄마가 제일 좋아하는 기억이야.',
    tag: '어머니',
    group: '가족',
  },
  {
    id: 'self',
    name: '나',
    sub: '스스로를 돌아보는 나',
    desc: '1인칭 존댓말. "저는 ~였어요." 회고하듯 담담한 말투.',
    emoji: '◉',
    greet: '안녕. 나야. 내 안의 어느 시간이 궁금한 거야?',
    sample: '나는 그때, 교실 창밖으로 해 지는 걸 가만히 보곤 했어. 아이들 떠든 소리가 사라진 그 짧은 정적이 참 좋았어.',
    tag: '나',
    group: '가족',
  },
  {
    id: 'sister',
    name: '누나 · 언니',
    sub: '손위 자매로 부르는 관계',
    desc: '1인칭 반말. "있잖아," 조금 장난스럽고 편안한 말투.',
    emoji: '◒',
    greet: '어, 왔어? 누나야. 뭐 물어보게?',
    sample: '있잖아, 내가 여덟 살 여름에 말이야, 복숭아 나무 밑에서 책 읽다가 잠들었었거든. 일어나 보니 할머니가 옆에 앉아계셨어. 그 장면이 왜 이렇게 오래 남지.',
    tag: '누나',
    group: '가족',
  },
  {
    id: 'brother',
    name: '형 · 오빠',
    sub: '손위 형제로 부르는 관계',
    desc: '1인칭 반말. "야, 그게 말이지," 덤덤하지만 따뜻한 말투.',
    emoji: '◓',
    greet: '야, 왔냐. 형이야. 궁금한 거 있어?',
    sample: '야, 그거 말이지. 내가 일곱 살인가 여덟 살인가, 복숭아 나무 밑에서 동생이랑 둘이 낮잠 잔 적 있거든. 그 냄새가 아직도 안 잊혀진다.',
    tag: '형',
    group: '가족',
  },
];

const AVATAR_ROLE_MAP = Object.fromEntries(AVATAR_ROLES.map(r => [r.id, r]));

function getSelectedRole() {
  const id = (typeof localStorage !== 'undefined' && localStorage.getItem('ll-avatar-role')) || 'curator';
  return AVATAR_ROLE_MAP[id] || AVATAR_ROLE_MAP.curator;
}

function setSelectedRole(id) {
  if (typeof localStorage !== 'undefined') localStorage.setItem('ll-avatar-role', id);
  window.dispatchEvent(new CustomEvent('ll-role-change', { detail: id }));
}

function useSelectedRole() {
  const [id, setId] = React.useState(() =>
    (typeof localStorage !== 'undefined' && localStorage.getItem('ll-avatar-role')) || 'curator');
  React.useEffect(() => {
    const h = (e) => setId(e.detail);
    window.addEventListener('ll-role-change', h);
    return () => window.removeEventListener('ll-role-change', h);
  }, []);
  return [AVATAR_ROLE_MAP[id] || AVATAR_ROLE_MAP.curator, (newId) => { setSelectedRole(newId); }];
}

Object.assign(window, { AVATAR_ROLES, AVATAR_ROLE_MAP, getSelectedRole, setSelectedRole, useSelectedRole });
```

## 4. ios-frame.jsx

- **경로:** `ios-frame.jsx`
- **줄 수:** 339
- **크기:** 15,755 bytes

```jsx

// iOS.jsx — Simplified iOS 26 (Liquid Glass) device frame
// Based on the iOS 26 UI Kit + Figma status bar spec. No assets, no deps.
// Exports: IOSDevice, IOSStatusBar, IOSNavBar, IOSGlassPill, IOSList, IOSListRow, IOSKeyboard

// ─────────────────────────────────────────────────────────────
// Status bar
// ─────────────────────────────────────────────────────────────
function IOSStatusBar({ dark = false, time = '9:41' }) {
  const c = dark ? '#fff' : '#000';
  return (
    <div style={{
      display: 'flex', gap: 154, alignItems: 'center', justifyContent: 'center',
      padding: '21px 24px 19px', boxSizing: 'border-box',
      position: 'relative', zIndex: 20, width: '100%',
    }}>
      <div style={{ flex: 1, height: 22, display: 'flex', alignItems: 'center', justifyContent: 'center', paddingTop: 1.5 }}>
        <span style={{
          fontFamily: '-apple-system, "SF Pro", system-ui', fontWeight: 590,
          fontSize: 17, lineHeight: '22px', color: c,
        }}>{time}</span>
      </div>
      <div style={{ flex: 1, height: 22, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7, paddingTop: 1, paddingRight: 1 }}>
        <svg width="19" height="12" viewBox="0 0 19 12">
          <rect x="0" y="7.5" width="3.2" height="4.5" rx="0.7" fill={c}/>
          <rect x="4.8" y="5" width="3.2" height="7" rx="0.7" fill={c}/>
          <rect x="9.6" y="2.5" width="3.2" height="9.5" rx="0.7" fill={c}/>
          <rect x="14.4" y="0" width="3.2" height="12" rx="0.7" fill={c}/>
        </svg>
        <svg width="17" height="12" viewBox="0 0 17 12">
          <path d="M8.5 3.2C10.8 3.2 12.9 4.1 14.4 5.6L15.5 4.5C13.7 2.7 11.2 1.5 8.5 1.5C5.8 1.5 3.3 2.7 1.5 4.5L2.6 5.6C4.1 4.1 6.2 3.2 8.5 3.2Z" fill={c}/>
          <path d="M8.5 6.8C9.9 6.8 11.1 7.3 12 8.2L13.1 7.1C11.8 5.9 10.2 5.1 8.5 5.1C6.8 5.1 5.2 5.9 3.9 7.1L5 8.2C5.9 7.3 7.1 6.8 8.5 6.8Z" fill={c}/>
          <circle cx="8.5" cy="10.5" r="1.5" fill={c}/>
        </svg>
        <svg width="27" height="13" viewBox="0 0 27 13">
          <rect x="0.5" y="0.5" width="23" height="12" rx="3.5" stroke={c} strokeOpacity="0.35" fill="none"/>
          <rect x="2" y="2" width="20" height="9" rx="2" fill={c}/>
          <path d="M25 4.5V8.5C25.8 8.2 26.5 7.2 26.5 6.5C26.5 5.8 25.8 4.8 25 4.5Z" fill={c} fillOpacity="0.4"/>
        </svg>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Liquid glass pill — blur + tint + shine
// ─────────────────────────────────────────────────────────────
function IOSGlassPill({ children, dark = false, style = {} }) {
  return (
    <div style={{
      height: 44, minWidth: 44, borderRadius: 9999,
      position: 'relative', overflow: 'hidden',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      boxShadow: dark
        ? '0 2px 6px rgba(0,0,0,0.35), 0 6px 16px rgba(0,0,0,0.2)'
        : '0 1px 3px rgba(0,0,0,0.07), 0 3px 10px rgba(0,0,0,0.06)',
      ...style,
    }}>
      {/* blur + tint */}
      <div style={{
        position: 'absolute', inset: 0, borderRadius: 9999,
        backdropFilter: 'blur(12px) saturate(180%)',
        WebkitBackdropFilter: 'blur(12px) saturate(180%)',
        background: dark ? 'rgba(120,120,128,0.28)' : 'rgba(255,255,255,0.5)',
      }} />
      {/* shine */}
      <div style={{
        position: 'absolute', inset: 0, borderRadius: 9999,
        boxShadow: dark
          ? 'inset 1.5px 1.5px 1px rgba(255,255,255,0.15), inset -1px -1px 1px rgba(255,255,255,0.08)'
          : 'inset 1.5px 1.5px 1px rgba(255,255,255,0.7), inset -1px -1px 1px rgba(255,255,255,0.4)',
        border: dark ? '0.5px solid rgba(255,255,255,0.15)' : '0.5px solid rgba(0,0,0,0.06)',
      }} />
      <div style={{ position: 'relative', zIndex: 1, display: 'flex', alignItems: 'center', padding: '0 4px' }}>
        {children}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Navigation bar — glass pills + large title
// ─────────────────────────────────────────────────────────────
function IOSNavBar({ title = 'Title', dark = false, trailingIcon = true }) {
  const muted = dark ? 'rgba(255,255,255,0.6)' : '#404040';
  const text = dark ? '#fff' : '#000';
  const pillIcon = (content) => (
    <IOSGlassPill dark={dark}>
      <div style={{ width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {content}
      </div>
    </IOSGlassPill>
  );
  return (
    <div style={{
      display: 'flex', flexDirection: 'column', gap: 10,
      paddingTop: 62, paddingBottom: 10, position: 'relative', zIndex: 5,
    }}>
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 16px',
      }}>
        {/* back chevron */}
        {pillIcon(
          <svg width="12" height="20" viewBox="0 0 12 20" fill="none" style={{ marginLeft: -1 }}>
            <path d="M10 2L2 10l8 8" stroke={muted} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        )}
        {/* trailing ellipsis */}
        {trailingIcon && pillIcon(
          <svg width="22" height="6" viewBox="0 0 22 6">
            <circle cx="3" cy="3" r="2.5" fill={muted}/>
            <circle cx="11" cy="3" r="2.5" fill={muted}/>
            <circle cx="19" cy="3" r="2.5" fill={muted}/>
          </svg>
        )}
      </div>
      {/* large title */}
      <div style={{
        padding: '0 16px',
        fontFamily: '-apple-system, system-ui',
        fontSize: 34, fontWeight: 700, lineHeight: '41px',
        color: text, letterSpacing: 0.4,
      }}>{title}</div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Grouped list (inset card, r:26) + row (52px)
// ─────────────────────────────────────────────────────────────
function IOSListRow({ title, detail, icon, chevron = true, isLast = false, dark = false }) {
  const text = dark ? '#fff' : '#000';
  const sec = dark ? 'rgba(235,235,245,0.6)' : 'rgba(60,60,67,0.6)';
  const ter = dark ? 'rgba(235,235,245,0.3)' : 'rgba(60,60,67,0.3)';
  const sep = dark ? 'rgba(84,84,88,0.65)' : 'rgba(60,60,67,0.12)';
  return (
    <div style={{
      display: 'flex', alignItems: 'center', minHeight: 52,
      padding: '0 16px', position: 'relative',
      fontFamily: '-apple-system, system-ui', fontSize: 17,
      letterSpacing: -0.43,
    }}>
      {icon && (
        <div style={{
          width: 30, height: 30, borderRadius: 7, background: icon,
          marginRight: 12, flexShrink: 0,
        }} />
      )}
      <div style={{ flex: 1, color: text }}>{title}</div>
      {detail && <span style={{ color: sec, marginRight: 6 }}>{detail}</span>}
      {chevron && (
        <svg width="8" height="14" viewBox="0 0 8 14" style={{ flexShrink: 0 }}>
          <path d="M1 1l6 6-6 6" stroke={ter} strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      )}
      {!isLast && (
        <div style={{
          position: 'absolute', bottom: 0, right: 0,
          left: icon ? 58 : 16, height: 0.5, background: sep,
        }} />
      )}
    </div>
  );
}

function IOSList({ header, children, dark = false }) {
  const hc = dark ? 'rgba(235,235,245,0.6)' : 'rgba(60,60,67,0.6)';
  const bg = dark ? '#1C1C1E' : '#fff';
  return (
    <div>
      {header && (
        <div style={{
          fontFamily: '-apple-system, system-ui', fontSize: 13,
          color: hc, textTransform: 'uppercase',
          padding: '8px 36px 6px', letterSpacing: -0.08,
        }}>{header}</div>
      )}
      <div style={{
        background: bg, borderRadius: 26,
        margin: '0 16px', overflow: 'hidden',
      }}>{children}</div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Device frame
// ─────────────────────────────────────────────────────────────
function IOSDevice({
  children, width = 402, height = 874, dark = false,
  title, keyboard = false,
}) {
  return (
    <div style={{
      width, height, borderRadius: 48, overflow: 'hidden',
      position: 'relative', background: dark ? '#000' : '#F2F2F7',
      boxShadow: '0 40px 80px rgba(0,0,0,0.18), 0 0 0 1px rgba(0,0,0,0.12)',
      fontFamily: '-apple-system, system-ui, sans-serif',
      WebkitFontSmoothing: 'antialiased',
    }}>
      {/* dynamic island */}
      <div style={{
        position: 'absolute', top: 11, left: '50%', transform: 'translateX(-50%)',
        width: 126, height: 37, borderRadius: 24, background: '#000', zIndex: 50,
      }} />
      {/* status bar (absolute) */}
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, zIndex: 10 }}>
        <IOSStatusBar dark={dark} />
      </div>
      {/* nav + content */}
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
        {title !== undefined && <IOSNavBar title={title} dark={dark} />}
        <div style={{ flex: 1, overflow: 'auto' }}>{children}</div>
        {keyboard && <IOSKeyboard dark={dark} />}
      </div>
      {/* home indicator — always on top */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 60,
        height: 34, display: 'flex', justifyContent: 'center', alignItems: 'flex-end',
        paddingBottom: 8, pointerEvents: 'none',
      }}>
        <div style={{
          width: 139, height: 5, borderRadius: 100,
          background: dark ? 'rgba(255,255,255,0.7)' : 'rgba(0,0,0,0.25)',
        }} />
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Keyboard — iOS 26 liquid glass
// ─────────────────────────────────────────────────────────────
function IOSKeyboard({ dark = false }) {
  const glyph = dark ? 'rgba(255,255,255,0.7)' : '#595959';
  const sugg = dark ? 'rgba(255,255,255,0.6)' : '#333';
  const keyBg = dark ? 'rgba(255,255,255,0.22)' : 'rgba(255,255,255,0.85)';

  // special-key icons
  const icons = {
    shift: <svg width="19" height="17" viewBox="0 0 19 17"><path d="M9.5 1L1 9.5h4.5V16h8V9.5H18L9.5 1z" fill={glyph}/></svg>,
    del: <svg width="23" height="17" viewBox="0 0 23 17"><path d="M7 1h13a2 2 0 012 2v11a2 2 0 01-2 2H7l-6-7.5L7 1z" fill="none" stroke={glyph} strokeWidth="1.6" strokeLinejoin="round"/><path d="M10 5l7 7M17 5l-7 7" stroke={glyph} strokeWidth="1.6" strokeLinecap="round"/></svg>,
    ret: <svg width="20" height="14" viewBox="0 0 20 14"><path d="M18 1v6H4m0 0l4-4M4 7l4 4" fill="none" stroke="#fff" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  };

  const key = (content, { w, flex, ret, fs = 25, k } = {}) => (
    <div key={k} style={{
      height: 42, borderRadius: 8.5,
      flex: flex ? 1 : undefined, width: w, minWidth: 0,
      background: ret ? '#08f' : keyBg,
      boxShadow: '0 1px 0 rgba(0,0,0,0.075)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontFamily: '-apple-system, "SF Compact", system-ui',
      fontSize: fs, fontWeight: 458, color: ret ? '#fff' : glyph,
    }}>{content}</div>
  );

  const row = (keys, pad = 0) => (
    <div style={{ display: 'flex', gap: 6.5, justifyContent: 'center', padding: `0 ${pad}px` }}>
      {keys.map(l => key(l, { flex: true, k: l }))}
    </div>
  );

  return (
    <div style={{
      position: 'relative', zIndex: 15, borderRadius: 27, overflow: 'hidden',
      padding: '11px 0 2px',
      display: 'flex', flexDirection: 'column', alignItems: 'center',
      boxShadow: dark
        ? '0 -2px 20px rgba(0,0,0,0.09)'
        : '0 -1px 6px rgba(0,0,0,0.018), 0 -3px 20px rgba(0,0,0,0.012)',
    }}>
      {/* liquid glass bg — same recipe as nav pills */}
      <div style={{
        position: 'absolute', inset: 0, borderRadius: 27,
        backdropFilter: 'blur(12px) saturate(180%)',
        WebkitBackdropFilter: 'blur(12px) saturate(180%)',
        background: dark ? 'rgba(120,120,128,0.14)' : 'rgba(255,255,255,0.25)',
      }} />
      <div style={{
        position: 'absolute', inset: 0, borderRadius: 27,
        boxShadow: dark
          ? 'inset 1.5px 1.5px 1px rgba(255,255,255,0.15)'
          : 'inset 1.5px 1.5px 1px rgba(255,255,255,0.7), inset -1px -1px 1px rgba(255,255,255,0.4)',
        border: dark ? '0.5px solid rgba(255,255,255,0.15)' : '0.5px solid rgba(0,0,0,0.06)',
        pointerEvents: 'none',
      }} />

      {/* autocorrect bar */}
      <div style={{
        display: 'flex', gap: 20, alignItems: 'center',
        padding: '8px 22px 13px', width: '100%', boxSizing: 'border-box',
        position: 'relative',
      }}>
        {['"The"', 'the', 'to'].map((w, i) => (
          <React.Fragment key={i}>
            {i > 0 && <div style={{ width: 1, height: 25, background: '#ccc', opacity: 0.3 }} />}
            <div style={{
              flex: 1, textAlign: 'center',
              fontFamily: '-apple-system, system-ui', fontSize: 17,
              color: sugg, letterSpacing: -0.43, lineHeight: '22px',
            }}>{w}</div>
          </React.Fragment>
        ))}
      </div>

      {/* key layout */}
      <div style={{
        display: 'flex', flexDirection: 'column', gap: 13,
        padding: '0 6.5px', width: '100%', boxSizing: 'border-box',
        position: 'relative',
      }}>
        {row(['q','w','e','r','t','y','u','i','o','p'])}
        {row(['a','s','d','f','g','h','j','k','l'], 20)}
        <div style={{ display: 'flex', gap: 14.25, alignItems: 'center' }}>
          {key(icons.shift, { w: 45, k: 'shift' })}
          <div style={{ display: 'flex', gap: 6.5, flex: 1 }}>
            {['z','x','c','v','b','n','m'].map(l => key(l, { flex: true, k: l }))}
          </div>
          {key(icons.del, { w: 45, k: 'del' })}
        </div>
        <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
          {key('ABC', { w: 92.25, fs: 18, k: 'abc' })}
          {key('', { flex: true, k: 'space' })}
          {key(icons.ret, { w: 92.25, ret: true, k: 'ret' })}
        </div>
      </div>

      {/* bottom spacer (emoji+mic area, icons omitted) */}
      <div style={{ height: 56, width: '100%', position: 'relative' }} />
    </div>
  );
}

Object.assign(window, {
  IOSDevice, IOSStatusBar, IOSNavBar, IOSGlassPill, IOSList, IOSListRow, IOSKeyboard,
});
```

## 5. android-frame.jsx

- **경로:** `android-frame.jsx`
- **줄 수:** 215
- **크기:** 9,429 bytes

```jsx

// Android.jsx — Simplified Android (Material 3) device frame
// Status bar + top app bar + content + gesture nav + keyboard.
// Based on Figma M3 spec. No dependencies, no image assets.

const MD_C = {
  surface: '#f4fbf8',
  surfaceVariant: '#dae5e1',
  inverseOnSurface: '#ecf2ef',
  secondaryContainer: '#cde8e1',
  primaryFixedDim: '#83d5c6',
  onSurface: '#171d1b',
  onSurfaceVar: '#49454f',
  onPrimaryContainer: '#00201c',
  primary: '#006a60',
  frameBorder: 'rgba(116,119,117,0.5)',
};

// ─────────────────────────────────────────────────────────────
// Status bar (time left, wifi/cell/battery right)
// ─────────────────────────────────────────────────────────────
function AndroidStatusBar({ dark = false }) {
  const c = dark ? '#fff' : MD_C.onSurface;
  return (
    <div style={{
      height: 40, display: 'flex', alignItems: 'center',
      justifyContent: 'space-between', padding: '0 16px',
      position: 'relative',
      fontFamily: 'Roboto, system-ui, sans-serif',
    }}>
      {/* time left */}
      <div style={{ width: 128, display: 'flex', alignItems: 'center', gap: 8 }}>
        <span style={{ fontSize: 14, fontWeight: 400, letterSpacing: 0.25, lineHeight: '20px', color: c }}>9:30</span>
      </div>
      {/* camera punch-hole (center) */}
      <div style={{
        position: 'absolute', left: '50%', top: 8, transform: 'translateX(-50%)',
        width: 24, height: 24, borderRadius: 100, background: '#2e2e2e',
      }} />
      {/* status icons right */}
      <div style={{ display: 'flex', alignItems: 'center' }}>
        <div style={{ display: 'flex', paddingRight: 2 }}>
          <svg width="16" height="16" viewBox="0 0 16 16" style={{ marginRight: -2 }}>
            <path d="M8 13.3L.67 5.97a10.37 10.37 0 0114.66 0L8 13.3z" fill={c}/>
          </svg>
          <svg width="16" height="16" viewBox="0 0 16 16" style={{ marginRight: -2 }}>
            <path d="M14.67 14.67V1.33L1.33 14.67h13.34z" fill={c}/>
          </svg>
        </div>
        <svg width="16" height="16" viewBox="0 0 16 16">
          <rect x="3.75" y="2" width="8.5" height="13" rx="1.5" fill={c}/>
          <rect x="5.5" y="0.9" width="5" height="2" rx="0.5" fill={c}/>
        </svg>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Top app bar (Material 3 small/medium)
// ─────────────────────────────────────────────────────────────
function AndroidAppBar({ title = 'Title', large = false }) {
  const iconDot = (
    <div style={{
      width: 48, height: 48, display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      <div style={{ width: 22, height: 22, borderRadius: '50%', background: MD_C.onSurfaceVar, opacity: 0.3 }} />
    </div>
  );
  return (
    <div style={{ background: MD_C.surface, padding: '4px 4px 0' }}>
      <div style={{ height: 56, display: 'flex', alignItems: 'center', gap: 4 }}>
        {iconDot}
        {!large && (
          <span style={{
            flex: 1, fontSize: 22, fontWeight: 400, color: MD_C.onSurface,
            fontFamily: 'Roboto, system-ui, sans-serif',
          }}>{title}</span>
        )}
        {large && <div style={{ flex: 1 }} />}
        {iconDot}
      </div>
      {large && (
        <div style={{
          padding: '16px 16px 20px',
          fontSize: 28, fontWeight: 400, color: MD_C.onSurface,
          fontFamily: 'Roboto, system-ui, sans-serif',
        }}>{title}</div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// List item (Material 3)
// ─────────────────────────────────────────────────────────────
function AndroidListItem({ headline, supporting, leading }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 16,
      padding: '12px 16px', minHeight: 56, boxSizing: 'border-box',
      fontFamily: 'Roboto, system-ui, sans-serif',
    }}>
      {leading && (
        <div style={{
          width: 40, height: 40, borderRadius: '50%',
          background: MD_C.primary, color: '#fff',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 18, fontWeight: 500, flexShrink: 0,
        }}>{leading}</div>
      )}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 16, color: MD_C.onSurface, lineHeight: '24px' }}>{headline}</div>
        {supporting && (
          <div style={{ fontSize: 14, color: MD_C.onSurfaceVar, lineHeight: '20px' }}>{supporting}</div>
        )}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Gesture nav bar (pill)
// ─────────────────────────────────────────────────────────────
function AndroidNavBar({ dark = false }) {
  return (
    <div style={{
      height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      <div style={{
        width: 108, height: 4, borderRadius: 2,
        background: dark ? '#fff' : MD_C.onSurface, opacity: 0.4,
      }} />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Device frame — wraps everything
// ─────────────────────────────────────────────────────────────
function AndroidDevice({
  children, width = 412, height = 892, dark = false,
  title, large = false, keyboard = false,
}) {
  return (
    <div style={{
      width, height, borderRadius: 18, overflow: 'hidden',
      background: dark ? '#1d1b20' : MD_C.surface,
      border: `8px solid ${MD_C.frameBorder}`,
      boxShadow: '0 30px 80px rgba(0,0,0,0.25)',
      display: 'flex', flexDirection: 'column', boxSizing: 'border-box',
    }}>
      <AndroidStatusBar dark={dark} />
      {title !== undefined && <AndroidAppBar title={title} large={large} />}
      <div style={{ flex: 1, overflow: 'auto' }}>
        {children}
      </div>
      {keyboard && <AndroidKeyboard />}
      <AndroidNavBar dark={dark} />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Keyboard — Gboard (Material 3)
// ─────────────────────────────────────────────────────────────
function AndroidKeyboard() {
  let _k = 0;
  const key = (l, { flex = 1, bg = MD_C.surface, r = 6, minW, fs = 21 } = {}) => (
    <div key={_k++} style={{
      height: 46, borderRadius: r, flex, minWidth: minW,
      background: bg, display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontFamily: 'Roboto, system-ui', fontSize: fs,
      color: MD_C.onPrimaryContainer,
    }}>{l}</div>
  );
  const row = (keys, style = {}) => (
    <div style={{ display: 'flex', gap: 6, justifyContent: 'center', ...style }}>
      {keys.map(l => key(l))}
    </div>
  );
  return (
    <div style={{
      background: MD_C.inverseOnSurface, padding: '0 8px 8px',
      display: 'flex', flexDirection: 'column', gap: 4,
    }}>
      {/* navbar spacer (icons omitted) */}
      <div style={{ height: 44 }} />
      {/* key rows */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {row(['q','w','e','r','t','y','u','i','o','p'])}
        {row(['a','s','d','f','g','h','j','k','l'], { padding: '0 20px' })}
        <div style={{ display: 'flex', gap: 6 }}>
          {key('', { bg: MD_C.surfaceVariant })}
          <div style={{ display: 'flex', gap: 6, flex: 7, minWidth: 274 }}>
            {['z','x','c','v','b','n','m'].map(l => key(l))}
          </div>
          {key('', { bg: MD_C.surfaceVariant })}
        </div>
        <div style={{ display: 'flex', gap: 6 }}>
          {key('?123', { bg: MD_C.secondaryContainer, r: 100, minW: 58, fs: 14 })}
          {key(',', { bg: MD_C.surfaceVariant })}
          {key('', { flex: 3, minW: 154 })}
          {key('.', { bg: MD_C.surfaceVariant })}
          {key('', { bg: MD_C.primaryFixedDim, r: 100, minW: 58 })}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  AndroidDevice, AndroidStatusBar, AndroidAppBar, AndroidListItem, AndroidNavBar, AndroidKeyboard,
});
```

## 6. design-canvas.jsx

- **경로:** `design-canvas.jsx`
- **줄 수:** 623
- **크기:** 31,136 bytes

```jsx

// DesignCanvas.jsx — Figma-ish design canvas wrapper
// Warm gray grid bg + Sections + Artboards + PostIt notes.
// Artboards are reorderable (grip-drag), labels/titles are inline-editable,
// and any artboard can be opened in a fullscreen focus overlay (←/→/Esc).
// State persists to a .design-canvas.state.json sidecar via the host
// bridge. No assets, no deps.
//
// Usage:
//   <DesignCanvas>
//     <DCSection id="onboarding" title="Onboarding" subtitle="First-run variants">
//       <DCArtboard id="a" label="A · Dusk" width={260} height={480}>…</DCArtboard>
//       <DCArtboard id="b" label="B · Minimal" width={260} height={480}>…</DCArtboard>
//     </DCSection>
//   </DesignCanvas>

const DC = {
  bg: '#f0eee9',
  grid: 'rgba(0,0,0,0.06)',
  label: 'rgba(60,50,40,0.7)',
  title: 'rgba(40,30,20,0.85)',
  subtitle: 'rgba(60,50,40,0.6)',
  postitBg: '#fef4a8',
  postitText: '#5a4a2a',
  font: '-apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif',
};

// One-time CSS injection (classes are dc-prefixed so they don't collide with
// the hosted design's own styles).
if (typeof document !== 'undefined' && !document.getElementById('dc-styles')) {
  const s = document.createElement('style');
  s.id = 'dc-styles';
  s.textContent = [
    '.dc-editable{cursor:text;outline:none;white-space:nowrap;border-radius:3px;padding:0 2px;margin:0 -2px}',
    '.dc-editable:focus{background:#fff;box-shadow:0 0 0 1.5px #c96442}',
    '[data-dc-slot]{transition:transform .18s cubic-bezier(.2,.7,.3,1)}',
    '[data-dc-slot].dc-dragging{transition:none;z-index:10;pointer-events:none}',
    '[data-dc-slot].dc-dragging .dc-card{box-shadow:0 12px 40px rgba(0,0,0,.25),0 0 0 2px #c96442;transform:scale(1.02)}',
    '.dc-card{transition:box-shadow .15s,transform .15s}',
    '.dc-card *{scrollbar-width:none}',
    '.dc-card *::-webkit-scrollbar{display:none}',
    '.dc-labelrow{display:flex;align-items:center;gap:4px;height:24px}',
    '.dc-grip{cursor:grab;display:flex;align-items:center;padding:5px 4px;border-radius:4px;transition:background .12s}',
    '.dc-grip:hover{background:rgba(0,0,0,.08)}',
    '.dc-grip:active{cursor:grabbing}',
    '.dc-labeltext{cursor:pointer;border-radius:4px;padding:3px 6px;display:flex;align-items:center;transition:background .12s}',
    '.dc-labeltext:hover{background:rgba(0,0,0,.05)}',
    '.dc-expand{position:absolute;bottom:100%;right:0;margin-bottom:5px;z-index:2;opacity:0;transition:opacity .12s,background .12s;',
    '  width:22px;height:22px;border-radius:5px;border:none;cursor:pointer;padding:0;',
    '  background:transparent;color:rgba(60,50,40,.7);display:flex;align-items:center;justify-content:center}',
    '.dc-expand:hover{background:rgba(0,0,0,.06);color:#2a251f}',
    '[data-dc-slot]:hover .dc-expand{opacity:1}',
  ].join('\n');
  document.head.appendChild(s);
}

const DCCtx = React.createContext(null);

// ─────────────────────────────────────────────────────────────
// DesignCanvas — stateful wrapper around the pan/zoom viewport.
// Owns runtime state (per-section order, renamed titles/labels, focused
// artboard). Order/titles/labels persist to a .design-canvas.state.json
// sidecar next to the HTML. Reads go via plain fetch() so the saved
// arrangement is visible anywhere the HTML + sidecar are served together
// (omelette preview, direct link, downloaded zip). Writes go through the
// host's window.omelette bridge — editing requires the omelette runtime.
// Focus is ephemeral.
// ─────────────────────────────────────────────────────────────
const DC_STATE_FILE = '.design-canvas.state.json';

function DesignCanvas({ children, minScale, maxScale, style }) {
  const [state, setState] = React.useState({ sections: {}, focus: null });
  // Hold rendering until the sidecar read settles so the saved order/titles
  // appear on first paint (no source-order flash). didRead gates writes until
  // the read settles so the empty initial state can't clobber a slow read;
  // skipNextWrite suppresses the one echo-write that would otherwise follow
  // hydration.
  const [ready, setReady] = React.useState(false);
  const didRead = React.useRef(false);
  const skipNextWrite = React.useRef(false);

  React.useEffect(() => {
    let off = false;
    fetch('./' + DC_STATE_FILE)
      .then((r) => (r.ok ? r.json() : null))
      .then((saved) => {
        if (off || !saved || !saved.sections) return;
        skipNextWrite.current = true;
        setState((s) => ({ ...s, sections: saved.sections }));
      })
      .catch(() => {})
      .finally(() => { didRead.current = true; if (!off) setReady(true); });
    const t = setTimeout(() => { if (!off) setReady(true); }, 150);
    return () => { off = true; clearTimeout(t); };
  }, []);

  React.useEffect(() => {
    if (!didRead.current) return;
    if (skipNextWrite.current) { skipNextWrite.current = false; return; }
    const t = setTimeout(() => {
      window.omelette?.writeFile(DC_STATE_FILE, JSON.stringify({ sections: state.sections })).catch(() => {});
    }, 250);
    return () => clearTimeout(t);
  }, [state.sections]);

  // Build registries synchronously from children so FocusOverlay can read
  // them in the same render. Only direct DCSection > DCArtboard children are
  // walked — wrapping them in other elements opts out of focus/reorder.
  const registry = {};     // slotId -> { sectionId, artboard }
  const sectionMeta = {};  // sectionId -> { title, subtitle, slotIds[] }
  const sectionOrder = [];
  React.Children.forEach(children, (sec) => {
    if (!sec || sec.type !== DCSection) return;
    const sid = sec.props.id ?? sec.props.title;
    if (!sid) return;
    sectionOrder.push(sid);
    const persisted = state.sections[sid] || {};
    const srcIds = [];
    React.Children.forEach(sec.props.children, (ab) => {
      if (!ab || ab.type !== DCArtboard) return;
      const aid = ab.props.id ?? ab.props.label;
      if (!aid) return;
      registry[`${sid}/${aid}`] = { sectionId: sid, artboard: ab };
      srcIds.push(aid);
    });
    const kept = (persisted.order || []).filter((k) => srcIds.includes(k));
    sectionMeta[sid] = {
      title: persisted.title ?? sec.props.title,
      subtitle: sec.props.subtitle,
      slotIds: [...kept, ...srcIds.filter((k) => !kept.includes(k))],
    };
  });

  const api = React.useMemo(() => ({
    state,
    section: (id) => state.sections[id] || {},
    patchSection: (id, p) => setState((s) => ({
      ...s,
      sections: { ...s.sections, [id]: { ...s.sections[id], ...(typeof p === 'function' ? p(s.sections[id] || {}) : p) } },
    })),
    setFocus: (slotId) => setState((s) => ({ ...s, focus: slotId })),
  }), [state]);

  // Esc exits focus; any outside pointerdown commits an in-progress rename.
  React.useEffect(() => {
    const onKey = (e) => { if (e.key === 'Escape') api.setFocus(null); };
    const onPd = (e) => {
      const ae = document.activeElement;
      if (ae && ae.isContentEditable && !ae.contains(e.target)) ae.blur();
    };
    document.addEventListener('keydown', onKey);
    document.addEventListener('pointerdown', onPd, true);
    return () => {
      document.removeEventListener('keydown', onKey);
      document.removeEventListener('pointerdown', onPd, true);
    };
  }, [api]);

  return (
    <DCCtx.Provider value={api}>
      <DCViewport minScale={minScale} maxScale={maxScale} style={style}>{ready && children}</DCViewport>
      {state.focus && registry[state.focus] && (
        <DCFocusOverlay entry={registry[state.focus]} sectionMeta={sectionMeta} sectionOrder={sectionOrder} />
      )}
    </DCCtx.Provider>
  );
}

// ─────────────────────────────────────────────────────────────
// DCViewport — transform-based pan/zoom (internal)
//
// Input mapping (Figma-style):
//   • trackpad pinch  → zoom   (ctrlKey wheel; Safari gesture* events)
//   • trackpad scroll → pan    (two-finger)
//   • mouse wheel     → zoom   (notched; distinguished from trackpad scroll)
//   • middle-drag / primary-drag-on-bg → pan
//
// Transform state lives in a ref and is written straight to the DOM
// (translate3d + will-change) so wheel ticks don't go through React —
// keeps pans at 60fps on dense canvases.
// ─────────────────────────────────────────────────────────────
function DCViewport({ children, minScale = 0.1, maxScale = 8, style = {} }) {
  const vpRef = React.useRef(null);
  const worldRef = React.useRef(null);
  const tf = React.useRef({ x: 0, y: 0, scale: 1 });

  const apply = React.useCallback(() => {
    const { x, y, scale } = tf.current;
    const el = worldRef.current;
    if (el) el.style.transform = `translate3d(${x}px, ${y}px, 0) scale(${scale})`;
  }, []);

  React.useEffect(() => {
    const vp = vpRef.current;
    if (!vp) return;

    const zoomAt = (cx, cy, factor) => {
      const r = vp.getBoundingClientRect();
      const px = cx - r.left, py = cy - r.top;
      const t = tf.current;
      const next = Math.min(maxScale, Math.max(minScale, t.scale * factor));
      const k = next / t.scale;
      // keep the world point under the cursor fixed
      t.x = px - (px - t.x) * k;
      t.y = py - (py - t.y) * k;
      t.scale = next;
      apply();
    };

    // Mouse-wheel vs trackpad-scroll heuristic. A physical wheel sends
    // line-mode deltas (Firefox) or large integer pixel deltas with no X
    // component (Chrome/Safari, typically multiples of 100/120). Trackpad
    // two-finger scroll sends small/fractional pixel deltas, often with
    // non-zero deltaX. ctrlKey is set by the browser for trackpad pinch.
    const isMouseWheel = (e) =>
      e.deltaMode !== 0 ||
      (e.deltaX === 0 && Number.isInteger(e.deltaY) && Math.abs(e.deltaY) >= 40);

    const onWheel = (e) => {
      e.preventDefault();
      if (isGesturing) return; // Safari: gesture* owns the pinch — discard concurrent wheels
      if (e.ctrlKey) {
        // trackpad pinch (or explicit ctrl+wheel)
        zoomAt(e.clientX, e.clientY, Math.exp(-e.deltaY * 0.01));
      } else if (isMouseWheel(e)) {
        // notched mouse wheel — fixed-ratio step per click
        zoomAt(e.clientX, e.clientY, Math.exp(-Math.sign(e.deltaY) * 0.18));
      } else {
        // trackpad two-finger scroll — pan
        tf.current.x -= e.deltaX;
        tf.current.y -= e.deltaY;
        apply();
      }
    };

    // Safari sends native gesture* events for trackpad pinch with a smooth
    // e.scale; preferring these over the ctrl+wheel fallback gives a much
    // better feel there. No-ops on other browsers. Safari also fires
    // ctrlKey wheel events during the same pinch — isGesturing makes
    // onWheel drop those entirely so they neither zoom nor pan.
    let gsBase = 1;
    let isGesturing = false;
    const onGestureStart = (e) => { e.preventDefault(); isGesturing = true; gsBase = tf.current.scale; };
    const onGestureChange = (e) => {
      e.preventDefault();
      zoomAt(e.clientX, e.clientY, (gsBase * e.scale) / tf.current.scale);
    };
    const onGestureEnd = (e) => { e.preventDefault(); isGesturing = false; };

    // Drag-pan: middle button anywhere, or primary button on canvas
    // background (anything that isn't an artboard or an inline editor).
    let drag = null;
    const onPointerDown = (e) => {
      const onBg = !e.target.closest('[data-dc-slot], .dc-editable');
      if (!(e.button === 1 || (e.button === 0 && onBg))) return;
      e.preventDefault();
      vp.setPointerCapture(e.pointerId);
      drag = { id: e.pointerId, lx: e.clientX, ly: e.clientY };
      vp.style.cursor = 'grabbing';
    };
    const onPointerMove = (e) => {
      if (!drag || e.pointerId !== drag.id) return;
      tf.current.x += e.clientX - drag.lx;
      tf.current.y += e.clientY - drag.ly;
      drag.lx = e.clientX; drag.ly = e.clientY;
      apply();
    };
    const onPointerUp = (e) => {
      if (!drag || e.pointerId !== drag.id) return;
      vp.releasePointerCapture(e.pointerId);
      drag = null;
      vp.style.cursor = '';
    };

    vp.addEventListener('wheel', onWheel, { passive: false });
    vp.addEventListener('gesturestart', onGestureStart, { passive: false });
    vp.addEventListener('gesturechange', onGestureChange, { passive: false });
    vp.addEventListener('gestureend', onGestureEnd, { passive: false });
    vp.addEventListener('pointerdown', onPointerDown);
    vp.addEventListener('pointermove', onPointerMove);
    vp.addEventListener('pointerup', onPointerUp);
    vp.addEventListener('pointercancel', onPointerUp);
    return () => {
      vp.removeEventListener('wheel', onWheel);
      vp.removeEventListener('gesturestart', onGestureStart);
      vp.removeEventListener('gesturechange', onGestureChange);
      vp.removeEventListener('gestureend', onGestureEnd);
      vp.removeEventListener('pointerdown', onPointerDown);
      vp.removeEventListener('pointermove', onPointerMove);
      vp.removeEventListener('pointerup', onPointerUp);
      vp.removeEventListener('pointercancel', onPointerUp);
    };
  }, [apply, minScale, maxScale]);

  const gridSvg = `url("data:image/svg+xml,%3Csvg width='120' height='120' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M120 0H0v120' fill='none' stroke='${encodeURIComponent(DC.grid)}' stroke-width='1'/%3E%3C/svg%3E")`;
  return (
    <div
      ref={vpRef}
      className="design-canvas"
      style={{
        height: '100vh', width: '100vw',
        background: DC.bg,
        overflow: 'hidden',
        overscrollBehavior: 'none',
        touchAction: 'none',
        position: 'relative',
        fontFamily: DC.font,
        boxSizing: 'border-box',
        ...style,
      }}
    >
      <div
        ref={worldRef}
        style={{
          position: 'absolute', top: 0, left: 0,
          transformOrigin: '0 0',
          willChange: 'transform',
          width: 'max-content', minWidth: '100%',
          minHeight: '100%',
          padding: '60px 0 80px',
        }}
      >
        <div style={{ position: 'absolute', inset: -6000, backgroundImage: gridSvg, backgroundSize: '120px 120px', pointerEvents: 'none', zIndex: -1 }} />
        {children}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// DCSection — editable title + h-row of artboards in persisted order
// ─────────────────────────────────────────────────────────────
function DCSection({ id, title, subtitle, children, gap = 48 }) {
  const ctx = React.useContext(DCCtx);
  const sid = id ?? title;
  const all = React.Children.toArray(children);
  const artboards = all.filter((c) => c && c.type === DCArtboard);
  const rest = all.filter((c) => !(c && c.type === DCArtboard));
  const srcOrder = artboards.map((a) => a.props.id ?? a.props.label);
  const sec = (ctx && sid && ctx.section(sid)) || {};

  const order = React.useMemo(() => {
    const kept = (sec.order || []).filter((k) => srcOrder.includes(k));
    return [...kept, ...srcOrder.filter((k) => !kept.includes(k))];
  }, [sec.order, srcOrder.join('|')]);

  const byId = Object.fromEntries(artboards.map((a) => [a.props.id ?? a.props.label, a]));

  return (
    <div data-dc-section={sid} style={{ marginBottom: 80, position: 'relative' }}>
      <div style={{ padding: '0 60px 56px' }}>
        <DCEditable tag="div" value={sec.title ?? title}
          onChange={(v) => ctx && sid && ctx.patchSection(sid, { title: v })}
          style={{ fontSize: 28, fontWeight: 600, color: DC.title, letterSpacing: -0.4, marginBottom: 6, display: 'inline-block' }} />
        {subtitle && <div style={{ fontSize: 16, color: DC.subtitle }}>{subtitle}</div>}
      </div>
      <div style={{ display: 'flex', gap, padding: '0 60px', alignItems: 'flex-start', width: 'max-content' }}>
        {order.map((k) => (
          <DCArtboardFrame key={k} sectionId={sid} artboard={byId[k]} order={order}
            label={(sec.labels || {})[k] ?? byId[k].props.label}
            onRename={(v) => ctx && ctx.patchSection(sid, (x) => ({ labels: { ...x.labels, [k]: v } }))}
            onReorder={(next) => ctx && ctx.patchSection(sid, { order: next })}
            onFocus={() => ctx && ctx.setFocus(`${sid}/${k}`)} />
        ))}
      </div>
      {rest}
    </div>
  );
}

// DCArtboard — marker; rendered by DCArtboardFrame via DCSection.
function DCArtboard() { return null; }

function DCArtboardFrame({ sectionId, artboard, label, order, onRename, onReorder, onFocus }) {
  const { id: rawId, label: rawLabel, width = 260, height = 480, children, style = {} } = artboard.props;
  const id = rawId ?? rawLabel;
  const ref = React.useRef(null);

  // Live drag-reorder: dragged card sticks to cursor; siblings slide into
  // their would-be slots in real time via transforms. DOM order only
  // changes on drop.
  const onGripDown = (e) => {
    e.preventDefault(); e.stopPropagation();
    const me = ref.current;
    // translateX is applied in local (pre-scale) space but pointer deltas and
    // getBoundingClientRect().left are screen-space — divide by the viewport's
    // current scale so the dragged card tracks the cursor at any zoom level.
    const scale = me.getBoundingClientRect().width / me.offsetWidth || 1;
    const peers = Array.from(document.querySelectorAll(`[data-dc-section="${sectionId}"] [data-dc-slot]`));
    const homes = peers.map((el) => ({ el, id: el.dataset.dcSlot, x: el.getBoundingClientRect().left }));
    const slotXs = homes.map((h) => h.x);
    const startIdx = order.indexOf(id);
    const startX = e.clientX;
    let liveOrder = order.slice();
    me.classList.add('dc-dragging');

    const layout = () => {
      for (const h of homes) {
        if (h.id === id) continue;
        const slot = liveOrder.indexOf(h.id);
        h.el.style.transform = `translateX(${(slotXs[slot] - h.x) / scale}px)`;
      }
    };

    const move = (ev) => {
      const dx = ev.clientX - startX;
      me.style.transform = `translateX(${dx / scale}px)`;
      const cur = homes[startIdx].x + dx;
      let nearest = 0, best = Infinity;
      for (let i = 0; i < slotXs.length; i++) {
        const d = Math.abs(slotXs[i] - cur);
        if (d < best) { best = d; nearest = i; }
      }
      if (liveOrder.indexOf(id) !== nearest) {
        liveOrder = order.filter((k) => k !== id);
        liveOrder.splice(nearest, 0, id);
        layout();
      }
    };

    const up = () => {
      document.removeEventListener('pointermove', move);
      document.removeEventListener('pointerup', up);
      const finalSlot = liveOrder.indexOf(id);
      me.classList.remove('dc-dragging');
      me.style.transform = `translateX(${(slotXs[finalSlot] - homes[startIdx].x) / scale}px)`;
      // After the settle transition, kill transitions + clear transforms +
      // commit the reorder in the same frame so there's no visual snap-back.
      setTimeout(() => {
        for (const h of homes) { h.el.style.transition = 'none'; h.el.style.transform = ''; }
        if (liveOrder.join('|') !== order.join('|')) onReorder(liveOrder);
        requestAnimationFrame(() => requestAnimationFrame(() => {
          for (const h of homes) h.el.style.transition = '';
        }));
      }, 180);
    };
    document.addEventListener('pointermove', move);
    document.addEventListener('pointerup', up);
  };

  return (
    <div ref={ref} data-dc-slot={id} style={{ position: 'relative', flexShrink: 0 }}>
      <div className="dc-labelrow" style={{ position: 'absolute', bottom: '100%', left: -4, marginBottom: 4, color: DC.label }}>
        <div className="dc-grip" onPointerDown={onGripDown} title="Drag to reorder">
          <svg width="9" height="13" viewBox="0 0 9 13" fill="currentColor"><circle cx="2" cy="2" r="1.1"/><circle cx="7" cy="2" r="1.1"/><circle cx="2" cy="6.5" r="1.1"/><circle cx="7" cy="6.5" r="1.1"/><circle cx="2" cy="11" r="1.1"/><circle cx="7" cy="11" r="1.1"/></svg>
        </div>
        <div className="dc-labeltext" onClick={onFocus} title="Click to focus">
          <DCEditable value={label} onChange={onRename} onClick={(e) => e.stopPropagation()}
            style={{ fontSize: 15, fontWeight: 500, color: DC.label, lineHeight: 1 }} />
        </div>
      </div>
      <button className="dc-expand" onClick={onFocus} onPointerDown={(e) => e.stopPropagation()} title="Focus">
        <svg width="12" height="12" viewBox="0 0 12 12" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"><path d="M7 1h4v4M5 11H1V7M11 1L7.5 4.5M1 11l3.5-3.5"/></svg>
      </button>
      <div className="dc-card"
        style={{ borderRadius: 2, boxShadow: '0 1px 3px rgba(0,0,0,.08),0 4px 16px rgba(0,0,0,.06)', overflow: 'hidden', width, height, background: '#fff', ...style }}>
        {children || <div style={{ height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#bbb', fontSize: 13, fontFamily: DC.font }}>{id}</div>}
      </div>
    </div>
  );
}

// Inline rename — commits on blur or Enter.
function DCEditable({ value, onChange, style, tag = 'span', onClick }) {
  const T = tag;
  return (
    <T className="dc-editable" contentEditable suppressContentEditableWarning
      onClick={onClick}
      onPointerDown={(e) => e.stopPropagation()}
      onBlur={(e) => onChange && onChange(e.currentTarget.textContent)}
      onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); e.currentTarget.blur(); } }}
      style={style}>{value}</T>
  );
}

// ─────────────────────────────────────────────────────────────
// Focus mode — overlay one artboard; ←/→ within section, ↑/↓ across
// sections, Esc or backdrop click to exit.
// ─────────────────────────────────────────────────────────────
function DCFocusOverlay({ entry, sectionMeta, sectionOrder }) {
  const ctx = React.useContext(DCCtx);
  const { sectionId, artboard } = entry;
  const sec = ctx.section(sectionId);
  const meta = sectionMeta[sectionId];
  const peers = meta.slotIds;
  const aid = artboard.props.id ?? artboard.props.label;
  const idx = peers.indexOf(aid);
  const secIdx = sectionOrder.indexOf(sectionId);

  const go = (d) => { const n = peers[(idx + d + peers.length) % peers.length]; if (n) ctx.setFocus(`${sectionId}/${n}`); };
  const goSection = (d) => {
    const ns = sectionOrder[(secIdx + d + sectionOrder.length) % sectionOrder.length];
    const first = sectionMeta[ns] && sectionMeta[ns].slotIds[0];
    if (first) ctx.setFocus(`${ns}/${first}`);
  };

  React.useEffect(() => {
    const k = (e) => {
      if (e.key === 'ArrowLeft') { e.preventDefault(); go(-1); }
      if (e.key === 'ArrowRight') { e.preventDefault(); go(1); }
      if (e.key === 'ArrowUp') { e.preventDefault(); goSection(-1); }
      if (e.key === 'ArrowDown') { e.preventDefault(); goSection(1); }
    };
    document.addEventListener('keydown', k);
    return () => document.removeEventListener('keydown', k);
  });

  const { width = 260, height = 480, children } = artboard.props;
  const [vp, setVp] = React.useState({ w: window.innerWidth, h: window.innerHeight });
  React.useEffect(() => { const r = () => setVp({ w: window.innerWidth, h: window.innerHeight }); window.addEventListener('resize', r); return () => window.removeEventListener('resize', r); }, []);
  const scale = Math.max(0.1, Math.min((vp.w - 200) / width, (vp.h - 260) / height, 2));

  const [ddOpen, setDd] = React.useState(false);
  const Arrow = ({ dir, onClick }) => (
    <button onClick={(e) => { e.stopPropagation(); onClick(); }}
      style={{ position: 'absolute', top: '50%', [dir]: 28, transform: 'translateY(-50%)',
        border: 'none', background: 'rgba(255,255,255,.08)', color: 'rgba(255,255,255,.9)',
        width: 44, height: 44, borderRadius: 22, fontSize: 18, cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'background .15s' }}
      onMouseEnter={(e) => (e.currentTarget.style.background = 'rgba(255,255,255,.18)')}
      onMouseLeave={(e) => (e.currentTarget.style.background = 'rgba(255,255,255,.08)')}>
      <svg width="18" height="18" viewBox="0 0 18 18" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
        <path d={dir === 'left' ? 'M11 3L5 9l6 6' : 'M7 3l6 6-6 6'} /></svg>
    </button>
  );

  // Portal to body so position:fixed is the real viewport regardless of any
  // transform on DesignCanvas's ancestors (including the canvas zoom itself).
  return ReactDOM.createPortal(
    <div onClick={() => ctx.setFocus(null)}
      onWheel={(e) => e.preventDefault()}
      style={{ position: 'fixed', inset: 0, zIndex: 100, background: 'rgba(24,20,16,.6)', backdropFilter: 'blur(14px)',
        fontFamily: DC.font, color: '#fff' }}>

      {/* top bar: section dropdown (left) · close (right) */}
      <div onClick={(e) => e.stopPropagation()}
        style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 72, display: 'flex', alignItems: 'flex-start', padding: '16px 20px 0', gap: 16 }}>
        <div style={{ position: 'relative' }}>
          <button onClick={() => setDd((o) => !o)}
            style={{ border: 'none', background: 'transparent', color: '#fff', cursor: 'pointer', padding: '6px 8px',
              borderRadius: 6, textAlign: 'left', fontFamily: 'inherit' }}>
            <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <span style={{ fontSize: 18, fontWeight: 600, letterSpacing: -0.3 }}>{meta.title}</span>
              <svg width="11" height="11" viewBox="0 0 11 11" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" style={{ opacity: .7 }}><path d="M2 4l3.5 3.5L9 4"/></svg>
            </span>
            {meta.subtitle && <span style={{ display: 'block', fontSize: 13, opacity: .6, fontWeight: 400, marginTop: 2 }}>{meta.subtitle}</span>}
          </button>
          {ddOpen && (
            <div style={{ position: 'absolute', top: '100%', left: 0, marginTop: 4, background: '#2a251f', borderRadius: 8,
              boxShadow: '0 8px 32px rgba(0,0,0,.4)', padding: 4, minWidth: 200, zIndex: 10 }}>
              {sectionOrder.map((sid) => (
                <button key={sid} onClick={() => { setDd(false); const f = sectionMeta[sid].slotIds[0]; if (f) ctx.setFocus(`${sid}/${f}`); }}
                  style={{ display: 'block', width: '100%', textAlign: 'left', border: 'none', cursor: 'pointer',
                    background: sid === sectionId ? 'rgba(255,255,255,.1)' : 'transparent', color: '#fff',
                    padding: '8px 12px', borderRadius: 5, fontSize: 14, fontWeight: sid === sectionId ? 600 : 400, fontFamily: 'inherit' }}>
                  {sectionMeta[sid].title}
                </button>
              ))}
            </div>
          )}
        </div>
        <div style={{ flex: 1 }} />
        <button onClick={() => ctx.setFocus(null)}
          onMouseEnter={(e) => (e.currentTarget.style.background = 'rgba(255,255,255,.12)')}
          onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}
          style={{ border: 'none', background: 'transparent', color: 'rgba(255,255,255,.7)', width: 32, height: 32,
            borderRadius: 16, fontSize: 20, cursor: 'pointer', lineHeight: 1, transition: 'background .12s' }}>×</button>
      </div>

      {/* card centered, label + index below — only the card itself stops
          propagation so any backdrop click (including the margins around
          the card) exits focus */}
      <div
        style={{ position: 'absolute', top: 64, bottom: 56, left: 100, right: 100, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 16 }}>
        <div onClick={(e) => e.stopPropagation()} style={{ width: width * scale, height: height * scale, position: 'relative' }}>
          <div style={{ width, height, transform: `scale(${scale})`, transformOrigin: 'top left', background: '#fff', borderRadius: 2, overflow: 'hidden',
            boxShadow: '0 20px 80px rgba(0,0,0,.4)' }}>
            {children || <div style={{ height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#bbb' }}>{aid}</div>}
          </div>
        </div>
        <div onClick={(e) => e.stopPropagation()} style={{ fontSize: 14, fontWeight: 500, opacity: .85, textAlign: 'center' }}>
          {(sec.labels || {})[aid] ?? artboard.props.label}
          <span style={{ opacity: .5, marginLeft: 10, fontVariantNumeric: 'tabular-nums' }}>{idx + 1} / {peers.length}</span>
        </div>
      </div>

      <Arrow dir="left" onClick={() => go(-1)} />
      <Arrow dir="right" onClick={() => go(1)} />

      {/* dots */}
      <div onClick={(e) => e.stopPropagation()}
        style={{ position: 'absolute', bottom: 20, left: '50%', transform: 'translateX(-50%)', display: 'flex', gap: 8 }}>
        {peers.map((p, i) => (
          <button key={p} onClick={() => ctx.setFocus(`${sectionId}/${p}`)}
            style={{ border: 'none', padding: 0, cursor: 'pointer', width: 6, height: 6, borderRadius: 3,
              background: i === idx ? '#fff' : 'rgba(255,255,255,.3)' }} />
        ))}
      </div>
    </div>,
    document.body,
  );
}

// ─────────────────────────────────────────────────────────────
// Post-it — absolute-positioned sticky note
// ─────────────────────────────────────────────────────────────
function DCPostIt({ children, top, left, right, bottom, rotate = -2, width = 180 }) {
  return (
    <div style={{
      position: 'absolute', top, left, right, bottom, width,
      background: DC.postitBg, padding: '14px 16px',
      fontFamily: '"Comic Sans MS", "Marker Felt", "Segoe Print", cursive',
      fontSize: 14, lineHeight: 1.4, color: DC.postitText,
      boxShadow: '0 2px 8px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.08)',
      transform: `rotate(${rotate}deg)`,
      zIndex: 5,
    }}>{children}</div>
  );
}

Object.assign(window, { DesignCanvas, DCSection, DCArtboard, DCPostIt });

```

## 7. screens-onboarding.jsx

- **경로:** `screens-onboarding.jsx`
- **줄 수:** 291
- **크기:** 15,092 bytes

```jsx
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
          당신의 이야기,<br/>영원히 간직하세요.
        </div>
        <div style={{ fontSize: 16, color: LL.textSec, textAlign: 'center', lineHeight: 1.6, maxWidth: 280, marginTop: 4 }} className="ll-text-sec">
          AI와 대화하며 당신의 삶을<br/>한 권의 책으로 남겨보세요.
        </div>
      </div>
      <div style={{ padding: '0 20px 32px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        <BtnPrimary onClick={() => nav && nav('02_Login')}>내 자서전 쓰기 시작하기</BtnPrimary>
        <div style={{ textAlign: 'center', fontSize: 13, color: LL.textPh }} className="ll-text-ph">
          이미 계정이 있으신가요?{' '}
          <TextBtn fontSize={13} color={LL.text} weight={500} onClick={() => nav && nav('02_Login')}>로그인</TextBtn>
        </div>
      </div>
    </Screen>
  );
}

// ─── Shared auth back bar ───────────────────────────────────
function BackBar({ onBack }) {
  return (
    <div style={{ padding: '6px 12px', display: 'flex', alignItems: 'center' }}>
      <button className="ll-pressable" onClick={onBack} style={{ width: 40, height: 40, borderRadius: 8, border: 'none', background: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
        {Icon.arrow(22)}
      </button>
    </div>
  );
}

function OrDivider() {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '8px 0' }}>
      <div className="ll-border" style={{ flex: 1, height: 1, background: LL.border }}/>
      <span style={{ fontSize: 12, color: LL.textPh }}>또는</span>
      <div className="ll-border" style={{ flex: 1, height: 1, background: LL.border }}/>
    </div>
  );
}

// ─── Screen 2: LoginPage ────────────────────────────────────
function S02_Login({ nav }) {
  const [show, setShow] = React.useState(false);
  return (
    <Screen label="02 Login">
      <StatusBar />
      <BackBar onBack={() => nav && nav('01_Main')} />
      <div style={{ flex: 1, padding: '16px 24px 24px', overflow: 'auto', display: 'flex', flexDirection: 'column' }}>
        <div style={{ ...T.h1, fontSize: 22, marginTop: 28 }} className="ll-text-primary">다시 오신 것을 환영합니다</div>
        <div style={{ ...T.bodySec, marginTop: 6 }} className="ll-text-sec">로그인하고 이야기를 이어가세요</div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 16, marginTop: 36 }}>
          <Field label="이메일">
            <Input type="email" value="margaret.thompson@email.com" placeholder="you@email.com" />
          </Field>
          <Field label="비밀번호">
            <Input type={show ? 'text' : 'password'} value="••••••••" placeholder="8자 이상 입력" right={
              <button onClick={() => setShow(s => !s)} style={{ background: 'none', border: 'none', padding: 4, display: 'flex', cursor: 'pointer' }}>{Icon.eye(18)}</button>
            }/>
          </Field>
        </div>

        <div style={{ marginTop: 24 }}>
          <BtnPrimary onClick={() => nav && nav('06_Home')}>로그인</BtnPrimary>
        </div>
        <div style={{ textAlign: 'center', marginTop: 18, fontSize: 14, color: LL.textSec }} className="ll-text-sec">
          계정이 없으신가요?{' '}
          <TextBtn fontSize={14} color={LL.text} weight={500} onClick={() => nav && nav('03_SignUp')}>가입하기</TextBtn>
        </div>

        <OrDivider />

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <BtnSecondary icon={Icon.google(18)}>Google로 계속하기</BtnSecondary>
          <BtnSecondary icon={Icon.kakao(18)}>카카오로 계속하기</BtnSecondary>
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 3: SignUpPage ───────────────────────────────────
function S03_SignUp({ nav }) {
  return (
    <Screen label="03 SignUp">
      <StatusBar />
      <BackBar onBack={() => nav && nav('02_Login')} />
      <div style={{ flex: 1, padding: '16px 24px 24px', overflow: 'auto', display: 'flex', flexDirection: 'column' }}>
        <div style={{ ...T.h1, fontSize: 22, marginTop: 28 }} className="ll-text-primary">계정을 만들어보세요</div>
        <div style={{ ...T.bodySec, marginTop: 6 }} className="ll-text-sec">1분이면 충분합니다.</div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 14, marginTop: 32 }}>
          <Field label={<>이름 {Icon.check(12, LL.success)}</>}>
            <Input value="Margaret Thompson" />
          </Field>
          <Field label={<>이메일 {Icon.check(12, LL.success)}</>}>
            <Input value="margaret.thompson@email.com" />
          </Field>
          <Field label="비밀번호">
            <Input type="password" value="••••••••" placeholder="8자 이상" />
          </Field>
          <Field label="비밀번호 확인">
            <Input type="password" placeholder="다시 입력해주세요" />
          </Field>
        </div>

        <div style={{ marginTop: 28 }}>
          <BtnPrimary onClick={() => nav && nav('04_SelfIntro')}>계정 만들기</BtnPrimary>
        </div>
        <div style={{ fontSize: 11, color: LL.textPh, textAlign: 'center', marginTop: 12, lineHeight: 1.5 }} className="ll-text-ph">
          가입하면 <span style={{ textDecoration: 'underline' }}>이용약관</span>과{' '}
          <span style={{ textDecoration: 'underline' }}>개인정보처리방침</span>에 동의하게 됩니다.
        </div>
        <div style={{ textAlign: 'center', marginTop: 18, fontSize: 14, color: LL.textSec }} className="ll-text-sec">
          이미 계정이 있나요?{' '}
          <TextBtn fontSize={14} color={LL.text} weight={500} onClick={() => nav && nav('02_Login')}>로그인</TextBtn>
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 4: SelfIntroPage ────────────────────────────────
function S04_SelfIntro({ nav }) {
  return (
    <Screen label="04 SelfIntro">
      <StatusBar />
      {/* Top bar */}
      <div className="ll-border" style={{ borderBottom: `1px solid ${LL.border}`, padding: '6px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ width: 40 }} />
        <div style={{ fontSize: 15, fontWeight: 500, color: LL.text }} className="ll-text-primary">알아가기</div>
        <div style={{ fontSize: 13, color: LL.textPh, width: 40, textAlign: 'right' }} className="ll-text-ph">1/3</div>
      </div>

      <AIQuestionCard>
        당신의 삶에서 자서전에 꼭 담고 싶은 주제는 무엇인가요?
      </AIQuestionCard>

      {/* Chat area */}
      <div style={{ flex: 1, overflow: 'auto', padding: '8px 16px 12px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        <UserBubble>
          가족, 그리고 오하이오 작은 마을에서 아이 셋을 키우며 학교에서 가르쳤던 시간들이요.
        </UserBubble>
        <AIBubble>
          소중한 주제네요. 그 시절의 학생 중 가장 기억에 남는 한 명이 있다면 누구인가요?
        </AIBubble>
      </div>

      {/* Follow-up hint */}
      <div style={{ textAlign: 'center', padding: '4px 16px 8px' }}>
        <span style={{ fontSize: 13, color: LL.textPh }} className="ll-text-ph">↪ 다시 질문해주세요</span>
      </div>

      <ChatInput placeholder="답변을 입력하거나 말씀해보세요..." value="제가 처음 가르쳤던 Tommy라는 아이가 있었어요" />
    </Screen>
  );
}

// ─── Screen 5: ChapterGenLoading ────────────────────────────
function S05_ChapterGen({ nav }) {
  React.useEffect(() => {
    const t = setTimeout(() => nav && nav('06_Home'), 3500);
    return () => clearTimeout(t);
  }, []);
  return (
    <Screen label="05 ChapterGen">
      <StatusBar />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 24px' }}>
        <div className="ll-breathe">{Icon.bookOpen(48, LL.text)}</div>
        <div style={{ fontSize: 18, fontWeight: 500, color: LL.text, marginTop: 28, textAlign: 'center' }} className="ll-text-primary">
          챕터를 만들고 있어요...
        </div>
        <div style={{ fontSize: 14, color: LL.textSec, marginTop: 8, textAlign: 'center', maxWidth: 260, lineHeight: 1.6 }} className="ll-text-sec">
          들려주신 이야기를 바탕으로<br/>당신의 삶을 챕터로 정리하고 있어요.
        </div>
        <div style={{ width: '100%', padding: '0 24px', marginTop: 40 }} className="ll-bar-anim">
          <div style={{ width: '100%', height: 4, background: LL.border, borderRadius: 8, overflow: 'hidden' }} className="ll-border">
            <span style={{ display: 'block', height: '100%', background: LL.cta, borderRadius: 8 }} className="ll-cta"/>
          </div>
        </div>
        <div style={{ fontSize: 12, color: LL.textPh, marginTop: 14 }} className="ll-text-ph">보통 몇 초 정도 걸려요...</div>
      </div>
    </Screen>
  );
}

// ─── Screen 6: HomeTabView ──────────────────────────────────
const CHAPTERS = [
  { n: 1, title: '어린 시절과 첫 기억',        done: 8, total: 8, status: 'complete' },
  { n: 2, title: '청소년기와 학창 시절',       done: 3, total: 8, status: 'in-progress' },
  { n: 3, title: '첫 직장, 처음 세상을 만나다', done: 0, total: 7, status: 'not-started' },
  { n: 4, title: '결혼, 그리고 세 아이',       done: 0, total: 8, status: 'not-started' },
];

function ChapterCard({ ch, onClick }) {
  const isActive = ch.status === 'in-progress';
  return (
    <div
      className="ll-card-tap ll-border"
      onClick={onClick}
      style={{
        padding: 16, border: `${isActive ? 1.5 : 1}px solid ${isActive ? LL.cta : LL.border}`,
        borderRadius: 12, background: '#fff', display: 'flex', flexDirection: 'column', gap: 10,
      }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span className="ll-surface-alt" style={{ fontSize: 11, fontWeight: 500, color: LL.textSec, background: LL.bgAlt, padding: '3px 8px', borderRadius: 4, letterSpacing: 0.2 }}>Ch.{ch.n}</span>
        <StatusBadge status={ch.status}/>
      </div>
      <div style={{ fontSize: 16, fontWeight: 500, color: LL.text, lineHeight: 1.35 }} className="ll-text-primary">{ch.title}</div>
      {ch.status !== 'not-started' && (
        <div>
          <ProgressBar value={ch.done / ch.total} height={3} fill={ch.status === 'complete' ? LL.success : LL.cta}/>
          <div style={{ fontSize: 12, color: LL.textPh, marginTop: 6 }} className="ll-text-ph">{ch.done} / {ch.total} 질문 답변 완료</div>
        </div>
      )}
      {ch.status === 'not-started' && (
        <div style={{ fontSize: 12, color: LL.textPh }} className="ll-text-ph">0 / {ch.total} 질문</div>
      )}
    </div>
  );
}

function S06_Home({ nav }) {
  const totalDone = 3, total = 7;
  return (
    <Screen label="06 Home">
      <StatusBar />
      {/* Greeting */}
      <div style={{ padding: '14px 20px 10px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ fontSize: 16, fontWeight: 500, color: LL.text }} className="ll-text-primary">안녕하세요, Margaret 님</div>
        <button className="ll-pressable" onClick={() => nav && nav('15_Search')} style={{ background: 'none', border: 'none', padding: 4, cursor: 'pointer', display: 'flex' }}>
          {Icon.search(20, LL.textSec)}
        </button>
      </div>

      <div style={{ flex: 1, overflow: 'auto' }}>
        {/* Progress card */}
        <div className="ll-surface-alt ll-border" style={{
          margin: '6px 16px 20px', padding: 16, background: LL.bgAlt,
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

      <BottomNav active="home" avatarUnlocked={false} onNav={(id) => {
        if (id === 'avatar') nav && nav('14_AvatarLocked');
        if (id === 'book') nav && nav('09_BookList');
      }}/>
    </Screen>
  );
}

Object.assign(window, {
  S01_Main, S02_Login, S03_SignUp, S04_SelfIntro, S05_ChapterGen, S06_Home,
  CHAPTERS,
});
```

## 8. screens-writing.jsx

- **경로:** `screens-writing.jsx`
- **줄 수:** 240
- **크기:** 14,278 bytes

```jsx
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
        <AIBubble time="오전 9:32">청소년 시절로 들어가볼까요. 가장 기억에 남는 선생님은 누구셨나요?</AIBubble>
        <UserBubble time="오전 9:33">Mrs. Harlow요. 영문학을 가르치셨어요. 그분 덕에 제가 나중에 선생님이 된 것 같아요.</UserBubble>
        <AIBubble time="오전 9:34">그분이 당신에게 어떤 영향을 주셨는지 조금 더 들려주시겠어요?</AIBubble>
        <UserBubble time="오전 9:35">학생 하나하나를 진심으로 봐주셨어요. "네 안에 이야기가 있어"라고 자주 말씀하셨죠.</UserBubble>
      </div>

      {allDone ? (
        <div style={{ padding: '10px 16px', borderTop: `1px solid ${LL.border}`, textAlign: 'center' }} className="ll-border">
          <TextBtn fontSize={13} color={LL.success} weight={500}>모든 질문에 답하셨어요! 챕터 완료하기 →</TextBtn>
        </div>
      ) : (
        <div style={{ textAlign: 'center', padding: '4px 16px 8px' }}>
          <span style={{ fontSize: 13, color: LL.textPh }} className="ll-text-ph">↪ 추가 질문하기</span>
        </div>
      )}

      <ChatInput value="학생들에게 이야기의 힘을 가르쳐주신 분이에요" onSend={() => nav && nav('08_Complete')}/>
    </Screen>
  );
}

// ─── Screen 8: ChapterCompletePage (bottom sheet) ───────────
function BottomSheetBg({ children }) {
  return (
    <Screen label="08 Complete">
      <StatusBar />
      {/* Dimmed background showing chat behind */}
      <div style={{ flex: 1, position: 'relative', background: LL.bg }}>
        {/* Fake chat content peeking through */}
        <div style={{ position: 'absolute', inset: 0, opacity: 0.25, pointerEvents: 'none', display: 'flex', flexDirection: 'column', padding: '20px 16px', gap: 10 }}>
          <div style={{ alignSelf: 'flex-start', background: LL.bgAlt, padding: '10px 12px', borderRadius: 12, maxWidth: '70%' }}>Mrs. Harlow 이야기...</div>
          <div style={{ alignSelf: 'flex-end', background: LL.cta, color: '#fff', padding: '10px 12px', borderRadius: 12, maxWidth: '70%' }}>그분이 제게...</div>
        </div>
        <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.3)' }}/>
        {/* Sheet */}
        <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, background: '#fff', borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 24, display: 'flex', flexDirection: 'column', alignItems: 'center' }} className="ll-fade-in">
          {children}
        </div>
      </div>
    </Screen>
  );
}

function S08_Complete({ nav }) {
  return (
    <BottomSheetBg>
      <div style={{ width: 36, height: 4, background: LL.border, borderRadius: 2, marginBottom: 16 }}/>
      <div className="ll-pop" style={{ display: 'flex' }}>{Icon.checkCircle(40, LL.success)}</div>
      <div style={{ fontSize: 20, fontWeight: 600, color: LL.text, marginTop: 14, textAlign: 'center' }} className="ll-text-primary">챕터 완료</div>
      <div style={{ fontSize: 14, color: LL.textSec, marginTop: 6, textAlign: 'center' }} className="ll-text-sec">
        Ch.2 — 청소년기가 저장되었어요.
      </div>

      <div style={{ display: 'flex', width: '100%', marginTop: 24, border: `1px solid ${LL.border}`, borderRadius: 10, overflow: 'hidden' }} className="ll-border">
        {[
          { n: 8, l: '질문 수' },
          { n: 8, l: '답변 완료' },
          { n: 2, l: '완료 챕터' },
        ].map((s, i) => (
          <div key={i} style={{ flex: 1, padding: '14px 0', textAlign: 'center', borderLeft: i === 0 ? 'none' : `1px solid ${LL.border}` }} className={i === 0 ? '' : 'll-border'}>
            <div style={{ fontSize: 18, fontWeight: 600, color: LL.text }} className="ll-text-primary">{s.n}</div>
            <div style={{ fontSize: 11, color: LL.textPh, marginTop: 2 }} className="ll-text-ph">{s.l}</div>
          </div>
        ))}
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, width: '100%', marginTop: 24 }}>
        <BtnPrimary onClick={() => nav && nav('07_Chat')}>다음 챕터 시작하기</BtnPrimary>
        <BtnSecondary onClick={() => nav && nav('06_Home')}>홈으로 돌아가기</BtnSecondary>
      </div>
    </BottomSheetBg>
  );
}

// ─── Screen 9: AutobiographyListPage ────────────────────────
const QUESTIONS_CH1 = [
  { q: '당신의 가장 어릴 적 기억은 무엇인가요?', done: true },
  { q: '어린 시절 집을 묘사해 주세요.', done: true },
  { q: '부모님에 대한 첫 기억은 무엇인가요?', done: true },
  { q: '형제자매와의 에피소드가 있나요?', done: true },
  { q: '가장 좋아했던 놀이는 무엇이었나요?', done: true },
  { q: '어린 시절 가장 행복했던 순간은?', done: true },
  { q: '가장 무서웠던 순간은 언제였나요?', done: true },
  { q: '그 시절 당신에게 소중했던 사람은?', done: true },
];

function ChapterAccordion({ n, title, done, total, expanded, onToggle, onQuestion }) {
  const color = done === total ? LL.success : LL.warning;
  return (
    <div className="ll-border" style={{ border: `1px solid ${LL.border}`, borderRadius: 10, background: '#fff', overflow: 'hidden' }}>
      <div onClick={onToggle} className="ll-card-tap" style={{ padding: 14, display: 'flex', alignItems: 'center', gap: 10, cursor: 'pointer' }}>
        <span className="ll-surface-alt" style={{ fontSize: 11, fontWeight: 500, color: LL.textSec, background: LL.bgAlt, padding: '3px 8px', borderRadius: 4 }}>Ch.{n}</span>
        <div style={{ flex: 1, fontSize: 14, fontWeight: 500, color: LL.text }} className="ll-text-primary">{title}</div>
        <span style={{ fontSize: 12, fontWeight: 500, color }}>{done}/{total}</span>
        <span style={{ display: 'flex', transform: expanded ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s' }}>{Icon.chevDown(16)}</span>
      </div>
      {expanded && (
        <div className="ll-border" style={{ borderTop: `1px solid ${LL.border}` }}>
          {QUESTIONS_CH1.map((item, i) => (
            <div
              key={i}
              onClick={onQuestion}
              className="ll-card-tap ll-border"
              style={{
                padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10,
                borderBottom: i === QUESTIONS_CH1.length - 1 ? 'none' : `1px solid ${LL.border}`,
                cursor: 'pointer',
              }}>
              <div style={{ flex: 1, fontSize: 14, color: LL.text, lineHeight: 1.5 }} className="ll-text-primary">{item.q}</div>
              <span style={{ display: 'flex' }}>
                {item.done ? Icon.check(18, LL.success) : Icon.circle(18)}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function S09_BookList({ nav }) {
  const [open, setOpen] = React.useState(1);
  const chapters = [
    { n: 1, title: '어린 시절과 첫 기억', done: 8, total: 8 },
    { n: 2, title: '청소년기와 학창 시절', done: 8, total: 8 },
    { n: 3, title: '첫 직장, 처음 세상을 만나다', done: 7, total: 7 },
    { n: 4, title: '결혼, 그리고 세 아이', done: 8, total: 8 },
    { n: 5, title: '교실에서 보낸 30년',   done: 5, total: 8 },
    { n: 6, title: '오하이오의 사계절',    done: 8, total: 8 },
    { n: 7, title: '손주들에게 남기는 말', done: 8, total: 8 },
  ];
  return (
    <Screen label="09 BookList">
      <StatusBar />
      <div style={{ padding: '14px 20px 10px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ fontSize: 18, fontWeight: 600, color: LL.text }} className="ll-text-primary">나의 자서전</div>
        <button className="ll-pressable" style={{ background: 'none', border: 'none', padding: 4, cursor: 'pointer', display: 'flex' }}>{Icon.info(20)}</button>
      </div>

      <div style={{ flex: 1, overflow: 'auto' }}>
        <div className="ll-surface-alt ll-border" style={{ margin: '4px 16px 16px', padding: 12, background: LL.bgAlt, border: `1px solid ${LL.border}`, borderRadius: 10 }}>
          <div style={{ fontSize: 14, fontWeight: 500, color: LL.text }} className="ll-text-primary">7개 챕터 중 6개 준비 완료</div>
          <div style={{ fontSize: 12, color: LL.textPh, marginTop: 2 }} className="ll-text-ph">질문을 탭하면 답변을 수정할 수 있어요.</div>
        </div>

        <div style={{ padding: '0 16px 16px', display: 'flex', flexDirection: 'column', gap: 8 }}>
          {chapters.map(ch => (
            <ChapterAccordion
              key={ch.n} {...ch}
              expanded={open === ch.n}
              onToggle={() => setOpen(o => o === ch.n ? null : ch.n)}
              onQuestion={() => nav && nav('10_Write')}
            />
          ))}
        </div>
      </div>

      <div className="ll-border" style={{ flexShrink: 0, borderTop: `1px solid ${LL.border}`, padding: 16, background: '#fff' }}>
        <div style={{ fontSize: 12, color: LL.warning, textAlign: 'center', marginBottom: 10 }}>
          2개 질문에 아직 답변이 필요해요
        </div>
        <BtnPrimary height={52} onClick={() => nav && nav('11_GenConfirm')}>내 자서전 만들기</BtnPrimary>
      </div>

      <BottomNav active="book" avatarUnlocked={false} onNav={(id) => {
        if (id === 'home') nav && nav('06_Home');
        if (id === 'avatar') nav && nav('14_AvatarLocked');
      }}/>
    </Screen>
  );
}

// ─── Screen 10: AutobiographyWritePage ──────────────────────
function S10_Write({ nav }) {
  const [text, setText] = React.useState(
    '제가 가장 일찍 기억하는 장면은 네 살 무렵, 할머니가 키우시던 뒷마당의 복숭아 나무 아래예요. 여름 오후였고, 바람이 불 때마다 잎사귀들이 서걱거리는 소리가 났어요. 할머니는 나무 옆 접이식 의자에 앉아 책을 읽고 계셨고, 저는 떨어진 복숭아를 주우며 뛰어다녔어요.\n\n그 향기는 지금도 눈을 감으면 선명해요. 잘 익은 복숭아 특유의 단내와, 그 위를 맴도는 벌들 소리까지. 어린 제게는 그곳이 온 세상의 전부였던 것 같아요.'
  );
  const chars = text.length;
  const words = text.trim().split(/\s+/).filter(Boolean).length;
  return (
    <Screen label="10 Write">
      <StatusBar />
      <div className="ll-border" style={{ borderBottom: `1px solid ${LL.border}`, padding: '8px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <TextBtn fontSize={15} color={LL.textSec} onClick={() => nav && nav('09_BookList')}>취소</TextBtn>
        <div style={{ fontSize: 14, fontWeight: 500, color: LL.text }} className="ll-text-primary">Q3 / 8</div>
        <TextBtn fontSize={15} color={LL.text} weight={500} onClick={() => nav && nav('09_BookList')}>저장</TextBtn>
      </div>

      <div className="ll-surface-alt ll-border" style={{ margin: '14px 16px', padding: 14, background: LL.bgAlt, border: `1px solid ${LL.border}`, borderRadius: 10 }}>
        <div style={{ fontSize: 11, fontWeight: 500, color: LL.textPh, marginBottom: 6, letterSpacing: 0.1 }} className="ll-text-ph">질문</div>
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
          <button style={{ background: 'none', border: 'none', padding: 4, cursor: 'pointer', display: 'flex' }}>{Icon.chevRight(20, LL.textSec)}</button>
        </div>
        <span style={{ fontSize: 12, color: LL.textPh }} className="ll-text-ph">{words} 단어</span>
      </div>
    </Screen>
  );
}

Object.assign(window, { S07_Chat, S08_Complete, S09_BookList, S10_Write });
```

## 9. screens-generation.jsx

- **경로:** `screens-generation.jsx`
- **줄 수:** 232
- **크기:** 13,702 bytes

```jsx
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
          <div style={{ fontSize: 20, fontWeight: 600, color: LL.text, marginTop: 14, textAlign: 'center' }} className="ll-text-primary">
            자서전을 만들 준비가 되셨나요?
          </div>
          <div style={{ fontSize: 14, color: LL.textSec, marginTop: 6, textAlign: 'center' }} className="ll-text-sec">
            당신의 답변을 모아 아름다운 책으로 만들어 드려요.
          </div>

          <div className="ll-surface-alt" style={{ width: '100%', marginTop: 20, background: LL.bgAlt, borderRadius: 10, padding: 12, display: 'flex', flexDirection: 'column', gap: 8 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              {Icon.check(14, LL.success)}
              <span style={{ fontSize: 14, fontWeight: 500, color: LL.text }} className="ll-text-primary">7개 챕터 완료</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              {Icon.alert(14, LL.warning)}
              <span style={{ fontSize: 14, fontWeight: 500, color: LL.text }} className="ll-text-primary">1개 챕터 미완성</span>
            </div>
          </div>

          <div style={{ width: '100%', marginTop: 12, background: LL.warnBg, border: `1px solid ${LL.warnBorder}`, borderRadius: 8, padding: 12 }}>
            <div style={{ fontSize: 13, color: '#92400E', lineHeight: 1.5 }}>
              일부 챕터가 미완성이에요. 지금 만들어도 되지만, 그 부분은 짧게 작성돼요.
            </div>
          </div>

          <div style={{ width: '100%', marginTop: 24, display: 'flex', flexDirection: 'column', gap: 10 }}>
            <BtnPrimary height={52} onClick={() => nav && nav('12_GenLoading')}>내 자서전 만들기</BtnPrimary>
            <button className="ll-pressable" onClick={() => nav && nav('09_BookList')} style={{ background: 'none', border: 'none', padding: '12px 0', fontSize: 15, color: LL.textSec, cursor: 'pointer' }}>
              돌아가서 더 쓰기
            </button>
          </div>
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 12: GenerationLoadingPage ───────────────────────
function S12_GenLoading({ nav }) {
  const stages = [
    { title: '기억을 모으는 중...',        desc: '당신의 이야기들을 찾고 있어요' },
    { title: '이야기를 엮는 중...',        desc: '흩어진 이야기들을 하나의 흐름으로 연결하고 있어요' },
    { title: '문장을 다듬는 중...',        desc: '당신의 목소리를 담아 정성스럽게 다듬고 있어요' },
    { title: 'PDF를 만드는 중...',         desc: '한 권의 책으로 엮어내고 있어요' },
  ];
  const [stage, setStage] = React.useState(1);
  React.useEffect(() => {
    const ids = [];
    ids.push(setTimeout(() => setStage(2), 1400));
    ids.push(setTimeout(() => setStage(3), 2600));
    ids.push(setTimeout(() => nav && nav('13_BookComplete'), 4000));
    return () => ids.forEach(clearTimeout);
  }, []);
  const cur = stages[stage];
  const pct = Math.round((stage + 1) / 4 * 100);
  return (
    <Screen label="12 GenLoading">
      <StatusBar />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 24px' }}>
        <div className="ll-breathe">{Icon.bookOpen(48, LL.text)}</div>
        <div key={stage} className="ll-fade-in" style={{ fontSize: 18, fontWeight: 500, color: LL.text, marginTop: 28, textAlign: 'center' }}>
          {cur.title}
        </div>
        <div style={{ fontSize: 14, color: LL.textSec, marginTop: 8, textAlign: 'center', maxWidth: 260, lineHeight: 1.6 }} className="ll-text-sec">
          {cur.desc}
        </div>
        <div style={{ width: '100%', padding: '0 24px', marginTop: 48 }}>
          <div style={{ width: '100%', height: 4, background: LL.border, borderRadius: 8, overflow: 'hidden' }} className="ll-border">
            <div style={{ width: `${pct}%`, height: '100%', background: LL.cta, borderRadius: 8, transition: 'width 0.6s ease' }} className="ll-cta"/>
          </div>
          <div style={{ marginTop: 10, display: 'flex', justifyContent: 'space-between', fontSize: 12, color: LL.textPh }} className="ll-text-ph">
            <span>단계 {stage + 1} / 4</span>
            <span>{pct}%</span>
          </div>
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 13: AutobiographyCompletePage ───────────────────
function S13_BookComplete({ nav }) {
  const [shared, setShared] = React.useState(false);
  const [showToast, setShowToast] = React.useState(true);
  React.useEffect(() => {
    const t = setTimeout(() => setShowToast(false), 4000);
    return () => clearTimeout(t);
  }, []);
  return (
    <Screen label="13 BookComplete">
      <StatusBar />
      <div style={{ flex: 1, overflow: 'auto', paddingTop: 40, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <div className="ll-pop">{Icon.bookHeart(52, LL.text)}</div>
        <div style={{ fontSize: 24, fontWeight: 600, color: LL.text, marginTop: 20, textAlign: 'center', letterSpacing: -0.3 }} className="ll-text-primary">
          자서전이 완성되었어요.
        </div>
        <div style={{ fontSize: 15, color: LL.textSec, marginTop: 10, textAlign: 'center', maxWidth: 280, lineHeight: 1.6, padding: '0 16px' }} className="ll-text-sec">
          들려주신 모든 이야기가<br/>한 권의 책으로 엮였어요.
        </div>

        <div className="ll-border" style={{ margin: '28px 16px 0', border: `1px solid ${LL.border}`, borderRadius: 12, padding: 16, display: 'flex', gap: 14, alignSelf: 'stretch' }}>
          <div className="ll-surface-alt" style={{ width: 48, height: 64, background: LL.bgAlt, borderRadius: 6, flexShrink: 0, border: `1px solid ${LL.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            {Icon.book(20, LL.textSec)}
          </div>
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2, justifyContent: 'center' }}>
            <div style={{ fontSize: 15, fontWeight: 500, color: LL.text }} className="ll-text-primary">나의 인생 이야기</div>
            <div style={{ fontSize: 13, color: LL.textPh }} className="ll-text-ph">Margaret Thompson · 2026</div>
            <div style={{ fontSize: 12, color: LL.textPh }} className="ll-text-ph">7개 챕터 · 약 42쪽</div>
          </div>
        </div>

        <div style={{ alignSelf: 'stretch', padding: '24px 16px 0', display: 'flex', flexDirection: 'column', gap: 10 }}>
          <BtnPrimary height={52} icon={Icon.download(18, '#fff')}>PDF 다운로드</BtnPrimary>
          <BtnSecondary icon={Icon.share(18)} onClick={() => setShared(s => !s)}>가족에게 공유 — 뷰어 코드 받기</BtnSecondary>
          {shared && (
            <div className="ll-surface-alt ll-fade-in" style={{ background: LL.bgAlt, borderRadius: 10, padding: 16, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10 }}>
              <div style={{ fontSize: 12, fontWeight: 500, color: LL.textPh, letterSpacing: 0.2 }} className="ll-text-ph">뷰어 코드</div>
              <div style={{ fontSize: 28, fontWeight: 600, color: LL.text, letterSpacing: '0.15em' }} className="ll-text-primary">A3F7K2</div>
              <div style={{ display: 'flex', gap: 20 }}>
                <TextBtn fontSize={13} color={LL.textSec} weight={500}>코드 복사</TextBtn>
                <TextBtn fontSize={13} color={LL.textSec} weight={500}>공유</TextBtn>
              </div>
            </div>
          )}
        </div>
        <div style={{ height: 80 }}/>
      </div>

      {showToast && (
        <div className="ll-fade-in" style={{
          position: 'absolute', left: 20, right: 20, bottom: 80,
          background: LL.cta, color: '#fff', borderRadius: 10, padding: '12px 14px',
          display: 'flex', alignItems: 'center', gap: 10, fontSize: 13,
        }}>
          {Icon.unlock(16, '#fff')}
          <span>아바타 대화가 잠금 해제되었어요</span>
        </div>
      )}

      <BottomNav active="book" avatarUnlocked={true} onNav={(id) => {
        if (id === 'home') nav && nav('06_Home');
        if (id === 'avatar') nav && nav('14_Avatar');
      }}/>
    </Screen>
  );
}

// ─── Screen 14: AvatarChatPage ──────────────────────────────
function S14_Avatar({ nav }) {
  return (
    <Screen label="14 Avatar">
      <StatusBar />
      <div style={{ padding: '14px 16px 10px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
        <div className="ll-surface-alt ll-border" style={{ width: 52, height: 52, borderRadius: 26, background: LL.bgAlt, border: `1px solid ${LL.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16, fontWeight: 500, color: LL.text }}>
          MT
        </div>
        <div style={{ fontSize: 15, fontWeight: 500, color: LL.text, marginTop: 8 }} className="ll-text-primary">Margaret Thompson</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{ width: 6, height: 6, borderRadius: 3, background: LL.success }}/>
          <span style={{ fontSize: 12, color: LL.textPh }} className="ll-text-ph">대화 준비됨</span>
        </div>
      </div>
      <div className="ll-border" style={{ borderTop: `1px solid ${LL.border}`, marginTop: 6 }}/>

      <div style={{ flex: 1, overflow: 'auto', padding: '16px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        <AIBubble time="오후 2:14">안녕, 오늘은 어떤 이야기가 듣고 싶으세요?</AIBubble>
        <UserBubble time="오후 2:14">어머니가 Tommy라는 학생에 대해 자주 말씀하셨어요. 그 아이 기억나세요?</UserBubble>
        <AIBubble time="오후 2:15">
          당연하죠. Tommy는 제가 처음 맡았던 3학년 반에 있었어요. 말수가 적었지만, 글을 쓸 때는 어른보다 깊은 눈을 가지고 있었어요. 어느 날 제게 쓴 편지에서…
        </AIBubble>
      </div>

      <ChatInput placeholder="무엇이든 물어보세요..."/>
    </Screen>
  );
}

// ─── Screen 14b: AvatarChatPage (LOCKED state) ──────────────
function S14b_AvatarLocked({ nav }) {
  return (
    <Screen label="14b AvatarLocked">
      <StatusBar />
      <div style={{ padding: '14px 16px 10px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, opacity: 0.4 }}>
        <div className="ll-surface-alt ll-border" style={{ width: 52, height: 52, borderRadius: 26, background: LL.bgAlt, border: `1px solid ${LL.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16, fontWeight: 500, color: LL.text }}>
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

      <BottomNav active="avatar" avatarUnlocked={false} onNav={(id) => {
        if (id === 'home') nav && nav('06_Home');
        if (id === 'book') nav && nav('09_BookList');
      }}/>
    </Screen>
  );
}

Object.assign(window, { S11_GenConfirm, S12_GenLoading, S13_BookComplete, S14_Avatar, S14b_AvatarLocked });
```

## 10. screens-viewer.jsx

- **경로:** `screens-viewer.jsx`
- **줄 수:** 392
- **크기:** 20,757 bytes

```jsx
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
            <div key={i} className="ll-surface-alt ll-border" style={{
              width: 44, height: 56, border: `1px solid ${LL.text}`, borderRadius: 8,
              background: LL.bgAlt, display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 24, fontWeight: 600, color: LL.text,
            }}>{c}</div>
          ))}
        </div>

        <div style={{ width: '100%', marginTop: 32 }}>
          <BtnPrimary height={52} onClick={() => nav && nav('18a_RoleSelect')}>입장</BtnPrimary>
        </div>
      </div>
      <div style={{ padding: '0 24px 32px', textAlign: 'center', fontSize: 13, color: LL.textPh }} className="ll-text-ph">
        코드가 없으신가요?{' '}
        <TextBtn fontSize={13} color={LL.text} weight={500} onClick={() => nav && nav('01_Main')} style={{ textDecoration: 'underline' }}>
          내 이야기 쓰기
        </TextBtn>
      </div>
    </Screen>
  );
}

// ─── Screen 18a: AvatarRoleSelect ───────────────────────────
function S18a_RoleSelect({ nav }) {
  const [role, chooseRole] = useSelectedRole();
  const basic = AVATAR_ROLES.filter(r => r.group === '기본');
  const family = AVATAR_ROLES.filter(r => r.group === '가족');

  const Card = ({ r }) => {
    const selected = role.id === r.id;
    return (
      <button
        onClick={() => chooseRole(r.id)}
        className="ll-pressable ll-border"
        style={{
          width: '100%', textAlign: 'left', cursor: 'pointer',
          background: selected ? LL.text : '#fff',
          color: selected ? '#fff' : LL.text,
          border: `1px solid ${selected ? LL.text : LL.border}`,
          borderRadius: 12, padding: '14px 16px',
          display: 'flex', alignItems: 'flex-start', gap: 12,
          fontFamily: 'inherit',
          transition: 'background 0.15s, color 0.15s, border-color 0.15s',
        }}
      >
        <div style={{
          width: 36, height: 36, borderRadius: 18, flexShrink: 0,
          background: selected ? 'rgba(255,255,255,0.14)' : LL.bgAlt,
          border: `1px solid ${selected ? 'rgba(255,255,255,0.3)' : LL.border}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 16, color: selected ? '#fff' : LL.textSec,
        }}>{r.emoji}</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
            <div style={{ fontSize: 15, fontWeight: 600, letterSpacing: -0.1 }}>{r.name}</div>
            <div style={{ fontSize: 11, opacity: selected ? 0.7 : 0.5 }}>{r.sub}</div>
          </div>
          <div style={{ fontSize: 12, lineHeight: 1.5, marginTop: 4, opacity: selected ? 0.85 : 0.7 }}>
            {r.desc}
          </div>
          {selected && (
            <div className="ll-fade-in" style={{
              marginTop: 10, padding: '8px 10px',
              background: 'rgba(255,255,255,0.08)',
              borderLeft: '2px solid rgba(255,255,255,0.4)',
              borderRadius: 6, fontSize: 12, lineHeight: 1.55, fontStyle: 'italic',
            }}>
              "{r.greet}"
            </div>
          )}
        </div>
        <div style={{
          width: 20, height: 20, borderRadius: 10, flexShrink: 0, marginTop: 2,
          border: `1.5px solid ${selected ? '#fff' : LL.border}`,
          background: selected ? '#fff' : 'transparent',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          {selected && <div style={{ width: 8, height: 8, borderRadius: 4, background: LL.text }}/>}
        </div>
      </button>
    );
  };

  return (
    <Screen label="18a RoleSelect">
      <StatusBar />
      <BackBar onBack={() => nav && nav('17_ViewerEntry')} />
      <div style={{ flex: 1, overflow: 'auto', padding: '8px 20px 20px', display: 'flex', flexDirection: 'column' }}>
        <div style={{ fontSize: 11, fontWeight: 500, color: LL.textPh, letterSpacing: 0.1 }} className="ll-text-ph">
          Margaret Thompson 님의 아바타
        </div>
        <div style={{ fontSize: 22, fontWeight: 600, color: LL.text, marginTop: 6, lineHeight: 1.35 }} className="ll-text-primary">
          어떤 목소리로<br/>이야기를 만나시겠어요?
        </div>
        <div style={{ fontSize: 13, color: LL.textSec, marginTop: 10, lineHeight: 1.6 }} className="ll-text-sec">
          선택하신 역할에 따라 아바타의 말투가 달라져요. 언제든 다시 바꿀 수 있어요.
        </div>

        <div style={{ fontSize: 11, fontWeight: 600, color: LL.textPh, letterSpacing: 0.08, textTransform: 'uppercase', marginTop: 24, marginBottom: 8 }} className="ll-text-ph">
          추천
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {basic.map(r => <Card key={r.id} r={r}/>)}
        </div>

        <div style={{ fontSize: 11, fontWeight: 600, color: LL.textPh, letterSpacing: 0.08, textTransform: 'uppercase', marginTop: 20, marginBottom: 8 }} className="ll-text-ph">
          가족 · 가까운 관계
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {family.map(r => <Card key={r.id} r={r}/>)}
        </div>
      </div>

      <div className="ll-border" style={{ borderTop: `1px solid ${LL.border}`, padding: '12px 20px 20px', background: '#fff' }}>
        <BtnPrimary height={52} onClick={() => nav && nav('18_ViewerIntro')}>
          {role.name}(으)로 만나기
        </BtnPrimary>
      </div>
    </Screen>
  );
}

// ─── Screen 18: ViewerAvatarIntroPage ───────────────────────
function S18_ViewerIntro({ nav }) {
  const [role] = useSelectedRole();
  return (
    <Screen label="18 ViewerIntro">
      <StatusBar />
      <BackBar onBack={() => nav && nav('18a_RoleSelect')} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '24px', justifyContent: 'center' }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <div className="ll-surface-alt ll-border" style={{
            width: 72, height: 72, borderRadius: 36, background: LL.bgAlt,
            border: `1px solid ${LL.border}`, display: 'flex', alignItems: 'center',
            justifyContent: 'center', fontSize: 22, fontWeight: 500, color: LL.text,
          }}>MT</div>
          <div style={{ fontSize: 12, fontWeight: 500, color: LL.textPh, marginTop: 16, letterSpacing: 0.1 }} className="ll-text-ph">
            이분의 이야기를 만나보세요
          </div>
          <div style={{ fontSize: 22, fontWeight: 600, color: LL.text, marginTop: 4 }} className="ll-text-primary">
            Margaret Thompson
          </div>
          <div className="ll-border" style={{
            marginTop: 10, display: 'inline-flex', alignItems: 'center', gap: 6,
            padding: '4px 10px', borderRadius: 999, border: `1px solid ${LL.border}`,
            fontSize: 11, color: LL.textSec,
          }}>
            <span style={{ fontSize: 12 }}>{role.emoji}</span>
            {role.tag} 목소리로 대화 중
            <span style={{ color: LL.border }}>·</span>
            <TextBtn fontSize={11} color={LL.text} weight={500} onClick={() => nav && nav('18a_RoleSelect')} style={{ textDecoration: 'underline' }}>
              변경
            </TextBtn>
          </div>
        </div>

        <div className="ll-border" style={{ marginTop: 28, border: `1px solid ${LL.border}`, borderRadius: 12, padding: 16 }}>
          <div style={{ fontSize: 11, fontWeight: 500, color: LL.textPh, marginBottom: 12, letterSpacing: 0.1 }} className="ll-text-ph">자서전에 대해</div>
          <div style={{ display: 'flex' }}>
            {[
              { n: '7', l: '챕터' },
              { n: '42', l: '쪽' },
              { n: '2026', l: '작성 연도' },
            ].map((s, i) => (
              <div key={i} className="ll-border" style={{ flex: 1, textAlign: 'center', borderLeft: i === 0 ? 'none' : `1px solid ${LL.border}` }}>
                <div style={{ fontSize: 14, fontWeight: 500, color: LL.text }} className="ll-text-primary">{s.n}</div>
                <div style={{ fontSize: 11, color: LL.textPh, marginTop: 2 }} className="ll-text-ph">{s.l}</div>
              </div>
            ))}
          </div>
          <div className="ll-border" style={{ height: 1, background: LL.border, margin: '12px 0' }}/>
          <div style={{ fontSize: 15, fontStyle: 'italic', color: LL.text, lineHeight: 1.7, display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden' }} className="ll-text-primary">
            "{role.greet}"
          </div>
        </div>

        <div style={{ marginTop: 28 }}>
          <BtnPrimary height={52} icon={Icon.messageCircle(18, '#fff')} onClick={() => nav && nav('19_ViewerChat')}>
            대화 시작하기
          </BtnPrimary>
          <div style={{ textAlign: 'center', fontSize: 12, color: LL.textPh, marginTop: 12 }} className="ll-text-ph">
            Margaret 님의 삶에 대해 무엇이든 물어보세요.
          </div>
        </div>
      </div>
    </Screen>
  );
}

// ─── Screen 19: ViewerAvatarChatPage ────────────────────────
function S19_ViewerChat({ nav }) {
  const [role, chooseRole] = useSelectedRole();
  const [hintOpen, setHintOpen] = React.useState(true);
  const [menuOpen, setMenuOpen] = React.useState(false);
  const [sheetOpen, setSheetOpen] = React.useState(false);

  // Role-specific question to show from the user in the conversation
  const userQuestion = {
    curator: 'Margaret 님 어릴 적 가장 행복했던 기억이 뭐예요?',
    father:  '아빠, 어릴 적 가장 행복했던 기억이 뭐야?',
    mother:  '엄마, 어릴 적 가장 행복했던 기억이 뭐야?',
    self:    '어릴 적 가장 행복했던 기억이 뭐였어?',
    sister:  '누나, 어릴 적 가장 행복했던 기억이 뭐야?',
    brother: '형, 어릴 적 가장 행복했던 기억이 뭐야?',
  }[role.id] || '어릴 적 가장 행복했던 기억이 뭐예요?';

  const placeholder = role.id === 'curator'
    ? 'Margaret 님께 무엇이든 물어보세요...'
    : `${role.name.split(' · ')[0]}에게 무엇이든 물어보세요...`;

  return (
    <Screen label="19 ViewerChat">
      <StatusBar />
      {/* Top bar */}
      <div className="ll-border" style={{ borderBottom: `1px solid ${LL.border}`, padding: '8px 12px', display: 'flex', alignItems: 'center', gap: 10, position: 'relative' }}>
        <button className="ll-pressable" onClick={() => nav && nav('18_ViewerIntro')} style={{ width: 36, height: 36, borderRadius: 8, border: 'none', background: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          {Icon.arrow(20)}
        </button>
        <button
          onClick={() => setSheetOpen(true)}
          className="ll-pressable"
          style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 10, border: 'none', background: 'none', padding: '4px 6px', borderRadius: 8, cursor: 'pointer', fontFamily: 'inherit', textAlign: 'left' }}>
          <div className="ll-surface-alt ll-border" style={{ width: 36, height: 36, borderRadius: 18, background: LL.bgAlt, border: `1px solid ${LL.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 12, fontWeight: 500, color: LL.text, position: 'relative' }}>
            MT
            <div style={{
              position: 'absolute', right: -4, bottom: -4,
              width: 18, height: 18, borderRadius: 9, background: '#fff',
              border: `1px solid ${LL.border}`, display: 'flex', alignItems: 'center',
              justifyContent: 'center', fontSize: 10, color: LL.textSec,
            }}>{role.emoji}</div>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <div style={{ fontSize: 15, fontWeight: 500, color: LL.text, lineHeight: 1.2 }} className="ll-text-primary">Margaret Thompson</div>
              <div className="ll-border" style={{ fontSize: 10, color: LL.textSec, border: `1px solid ${LL.border}`, borderRadius: 999, padding: '1px 7px' }}>
                {role.tag}
              </div>
            </div>
            <div style={{ fontSize: 11, color: LL.textPh, marginTop: 2, display: 'flex', alignItems: 'center', gap: 4 }} className="ll-text-ph">
              역할 변경 {Icon.arrow && <span style={{ fontSize: 8 }}>▾</span>}
            </div>
          </div>
        </button>
        <button className="ll-pressable" onClick={() => setMenuOpen(o => !o)} style={{ width: 36, height: 36, borderRadius: 8, border: 'none', background: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          {Icon.more(20)}
        </button>
        {menuOpen && (
          <div className="ll-fade-in ll-border" style={{
            position: 'absolute', top: 52, right: 10, background: '#fff',
            border: `1px solid ${LL.border}`, borderRadius: 10, padding: 6,
            boxShadow: '0 6px 24px rgba(0,0,0,0.08)', minWidth: 180, zIndex: 10,
          }}>
            <div onClick={() => { setMenuOpen(false); setSheetOpen(true); }} className="ll-card-tap" style={{ padding: '10px 12px', fontSize: 14, color: LL.text, borderRadius: 6, display: 'flex', alignItems: 'center', gap: 10, cursor: 'pointer' }}>
              {Icon.user(18, LL.textSec)} 역할 바꾸기
            </div>
            <div className="ll-card-tap" style={{ padding: '10px 12px', fontSize: 14, color: LL.text, borderRadius: 6, display: 'flex', alignItems: 'center', gap: 10, cursor: 'pointer' }}>
              {Icon.book(18, LL.textSec)} 자서전 보기
            </div>
            <div className="ll-card-tap" style={{ padding: '10px 12px', fontSize: 14, color: LL.text, borderRadius: 6, display: 'flex', alignItems: 'center', gap: 10, cursor: 'pointer' }}>
              {Icon.key(18, LL.textSec)} 다른 코드 입력
            </div>
          </div>
        )}
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: 16, display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div style={{ fontSize: 11, color: LL.textPh, alignSelf: 'flex-start', marginLeft: 2 }} className="ll-text-ph">
          Margaret Thompson · {role.tag} 목소리
        </div>
        <div style={{ maxWidth: '82%', alignSelf: 'flex-start' }}>
          <div className="ll-surface-alt" style={{
            background: LL.bgAlt, borderLeft: `2px solid ${LL.border}`,
            borderRadius: 12, padding: '12px 14px',
            fontSize: 15, color: LL.text, lineHeight: 1.55,
          }}>
            {role.greet}
          </div>
          <div style={{ fontSize: 11, color: LL.textPh, marginTop: 4, marginLeft: 4 }} className="ll-text-ph">오후 2:10</div>
        </div>

        <UserBubble time="오후 2:11">{userQuestion}</UserBubble>

        <div style={{ maxWidth: '82%', alignSelf: 'flex-start' }}>
          <div className="ll-surface-alt" style={{
            background: LL.bgAlt, borderLeft: `2px solid ${LL.border}`,
            borderRadius: 12, padding: '12px 14px',
            fontSize: 15, color: LL.text, lineHeight: 1.55,
          }}>
            {role.sample}
          </div>
          <div style={{ fontSize: 11, color: LL.textPh, marginTop: 4, marginLeft: 4 }} className="ll-text-ph">오후 2:11</div>
        </div>
      </div>

      {hintOpen && (
        <div className="ll-surface-alt" style={{
          margin: '8px 16px', background: LL.bgAlt, borderRadius: 10,
          padding: '10px 12px', display: 'flex', alignItems: 'center', gap: 10,
        }}>
          <div style={{ flex: 1, fontSize: 12, color: LL.textSec, lineHeight: 1.5 }} className="ll-text-sec">
            Margaret 님의 어린 시절, 교사 생활, 또는 어떤 삶의 기억이든 물어보세요.
          </div>
          <button onClick={() => setHintOpen(false)} style={{ background: 'none', border: 'none', padding: 4, cursor: 'pointer', display: 'flex' }}>
            {Icon.x(14)}
          </button>
        </div>
      )}

      <ChatInput placeholder={placeholder} />

      {/* Role change sheet */}
      {sheetOpen && (
        <>
          <div onClick={() => setSheetOpen(false)} style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.28)', zIndex: 20 }}/>
          <div className="ll-fade-in" style={{
            position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 21,
            background: '#fff', borderTopLeftRadius: 16, borderTopRightRadius: 16,
            boxShadow: '0 -8px 28px rgba(0,0,0,0.14)',
            maxHeight: '78%', display: 'flex', flexDirection: 'column',
          }}>
            <div style={{ padding: '10px 0 0', display: 'flex', justifyContent: 'center' }}>
              <div style={{ width: 36, height: 4, borderRadius: 2, background: LL.border }}/>
            </div>
            <div style={{ padding: '12px 20px 4px' }}>
              <div style={{ fontSize: 16, fontWeight: 600, color: LL.text }} className="ll-text-primary">
                역할 바꾸기
              </div>
              <div style={{ fontSize: 12, color: LL.textSec, marginTop: 4, lineHeight: 1.5 }} className="ll-text-sec">
                고르신 역할의 말투로 계속 대화해요.
              </div>
            </div>
            <div style={{ flex: 1, overflow: 'auto', padding: '8px 16px 16px' }}>
              {AVATAR_ROLES.map(r => {
                const selected = role.id === r.id;
                return (
                  <button
                    key={r.id}
                    onClick={() => { chooseRole(r.id); setTimeout(() => setSheetOpen(false), 120); }}
                    className="ll-pressable ll-border"
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
        </>
      )}
    </Screen>
  );
}

Object.assign(window, { S17_ViewerEntry, S18a_RoleSelect, S18_ViewerIntro, S19_ViewerChat });
```

## 11. screens-utility.jsx

- **경로:** `screens-utility.jsx`
- **줄 수:** 144
- **크기:** 8,216 bytes

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
            onChange={e => setQuery(e.target.value)}
            placeholder="기억을 검색해보세요..."
            style={{ flex: 1, border: 'none', outline: 'none', fontSize: 15, color: LL.text, background: 'transparent' }}
          />
        </div>
        <TextBtn fontSize={15} color={LL.textSec} onClick={() => nav && nav('06_Home')}>취소</TextBtn>
      </div>

      {!query ? (
        <div style={{ padding: 16 }}>
          <div style={{ ...T.sectionLabel, marginBottom: 12 }} className="ll-text-ph">최근 검색</div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {['학교', '어머니', '첫 직장'].map(t => (
              <div key={t} className="ll-surface-alt ll-border" style={{
                height: 32, background: LL.bgAlt, border: `1px solid ${LL.border}`, borderRadius: 8,
                padding: '0 10px', display: 'flex', alignItems: 'center', gap: 6,
                fontSize: 13, color: LL.textSec,
              }}>
                <span>{t}</span>
                {Icon.x(12)}
              </div>
            ))}
          </div>
        </div>
      ) : (
        <div style={{ flex: 1, overflow: 'auto' }}>
          <div style={{ fontSize: 12, color: LL.textPh, padding: '10px 16px' }} className="ll-text-ph">
            "{query}"에 대한 {results.length}개 결과
          </div>
          {results.map((r, i) => (
            <div key={i} onClick={() => nav && nav('10_Write')} className="ll-card-tap ll-border"
              style={{ padding: '14px 16px', borderBottom: `1px solid ${LL.border}`, cursor: 'pointer' }}>
              <div className="ll-surface-alt" style={{ fontSize: 11, fontWeight: 500, color: LL.textSec, background: LL.bgAlt, padding: '2px 7px', borderRadius: 4, display: 'inline-block', marginBottom: 8 }}>Ch.{r.ch}</div>
              <div style={{ fontSize: 13, fontWeight: 500, color: LL.text, marginBottom: 6, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }} className="ll-text-primary">{r.q}</div>
              <div style={{ fontSize: 13, color: LL.textSec, lineHeight: 1.5, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }} className="ll-text-sec">
                {r.a.split(query).map((part, idx, arr) => (
                  <React.Fragment key={idx}>
                    {part}
                    {idx < arr.length - 1 && <span style={{ background: LL.highlight, padding: '0 1px' }}>{query}</span>}
                  </React.Fragment>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}
    </Screen>
  );
}

// ─── Screen 16: MyPage ──────────────────────────────────────
function Row({ icon, label, right, danger, onClick }) {
  return (
    <div onClick={onClick} className="ll-card-tap ll-border"
      style={{ padding: '0 16px', minHeight: 48, display: 'flex', alignItems: 'center', gap: 14,
        borderBottom: `1px solid ${LL.border}`, cursor: onClick ? 'pointer' : 'default' }}>
      {icon && <span style={{ display: 'flex' }}>{icon}</span>}
      <span style={{ flex: 1, fontSize: 15, color: danger ? LL.error : LL.text }} className={danger ? '' : 'll-text-primary'}>{label}</span>
      {right}
    </div>
  );
}

function Toggle({ on = true }) {
  return (
    <div style={{ width: 36, height: 20, borderRadius: 10, background: on ? LL.cta : LL.border, position: 'relative', transition: 'background 0.15s' }} className={on ? 'll-cta' : 'll-border'}>
      <div style={{ position: 'absolute', top: 2, left: on ? 18 : 2, width: 16, height: 16, borderRadius: 8, background: '#fff', transition: 'left 0.15s' }}/>
    </div>
  );
}

function S16_MyPage({ nav }) {
  const [notify, setNotify] = React.useState(true);
  return (
    <Screen label="16 MyPage">
      <StatusBar />
      <div style={{ flex: 1, overflow: 'auto' }}>
        {/* Profile */}
        <div className="ll-border" style={{ padding: '20px 16px 24px', borderBottom: `1px solid ${LL.border}`, display: 'flex', flexDirection: 'column', gap: 14 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
            <div className="ll-surface-alt ll-border" style={{ width: 48, height: 48, borderRadius: 24, background: LL.bgAlt, border: `1px solid ${LL.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16, fontWeight: 500, color: LL.text }}>MT</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 16, fontWeight: 500, color: LL.text }} className="ll-text-primary">Margaret Thompson</div>
              <div style={{ fontSize: 13, color: LL.textPh }} className="ll-text-ph">margaret.thompson@email.com</div>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            <span className="ll-surface-alt ll-border" style={{ fontSize: 12, color: LL.text, background: LL.bgAlt, border: `1px solid ${LL.border}`, padding: '4px 10px', borderRadius: 4 }}>7개 챕터</span>
            <span style={{ fontSize: 12, color: LL.success, background: LL.successBg, border: `1px solid ${LL.border}`, padding: '4px 10px', borderRadius: 4 }} className="ll-border">완료 ✓</span>
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

      <BottomNav active="book" avatarUnlocked={true} onNav={(id) => {
        if (id === 'home') nav && nav('06_Home');
        if (id === 'avatar') nav && nav('14_Avatar');
      }}/>
    </Screen>
  );
}

Object.assign(window, { S15_Search, S16_MyPage });
```

