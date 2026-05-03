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
          <path d="M0 4C0 2.89543 0.895431 2 2 2H14C15.1046 2 16 2.89543 16 4V8C16 9.10457 15.1046 10 14 10H2C0.895432 10 0 9.10457 0 8V4Z" fill="none" stroke={c} strokeWidth="1.2" strokeLinecap="round" strokeLinejoin="round"/>
          <path d="M16.5 4.5C17.3284 4.5 18 5.17157 18 6C18 6.82843 17.3284 7.5 16.5 7.5" fill="none" stroke={c} strokeWidth="1" strokeLinecap="round" opacity="0.4"/>
          <rect x="3" y="4" width="10" height="4" rx="1" fill={c}/>
        </svg>
        <svg width="12" height="12" viewBox="0 0 12 12" fill={c}>
          <path d="M6 1.5C3 1.5 1 4.5 1 4.5L6 9.5L11 4.5C11 4.5 9 1.5 6 1.5Z" stroke={c} strokeWidth="1" strokeLinejoin="round" fill="none"/>
        </svg>
        <svg width="15" height="12" viewBox="0 0 15 12">
          <path d="M2 3C2 1.89543 2.89543 1 4 1H11C12.1046 1 13 1.89543 13 3V9C13 10.1046 12.1046 11 11 11H4C2.89543 11 2 10.1046 2 9V3Z" stroke={c} strokeWidth="1.2"/>
          <path d="M1 5.5H0.5C0.223858 5.5 0 5.72386 0 6V6.5C0 6.77614 0.223858 7 0.5 7H1" stroke={c} strokeWidth="1.2" strokeLinecap="round"/>
          <rect x="4" y="3" width="7" height="5" rx="0.5" fill={c}/>
        </svg>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Navbar
// ─────────────────────────────────────────────────────────────
function IOSNavBar({ title, rightNode, onBack }) {
  return (
    <div style={{
      height: 44, display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 16px', borderBottom: '0.5px solid rgba(60,60,60,0.28)',
      backgroundColor: 'rgba(255, 255, 255, 0.72)', backdropFilter: 'blur(20px)',
      position: 'relative', zIndex: 10,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, flex: 1 }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', color: '#007AFF', fontSize: 17, display: 'flex', alignItems: 'center', padding: 4, cursor: 'pointer' }}>
          <svg width="12" height="20" viewBox="0 0 12 20"><path d="M11.5 1.5L2 10l9.5 8.5" stroke="#007AFF" strokeWidth="2.5" fill="none"/></svg>
        </button>
        <span style={{ fontSize: 14, color: '#007AFF' }} onClick={onBack}>뒤로</span>
      </div>
      <div style={{ flex: 1, textAlign: 'center', fontWeight: 600, fontSize: 17, color: '#000' }}>
        {title}
      </div>
      <div style={{ flex: 1, display: 'flex', justifyContent: 'flex-end', fontSize: 17, color: '#007AFF' }}>
        {rightNode}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// iOS Device Frame
// ─────────────────────────────────────────────────────────────
function IOSDevice({ children, dark = false }) {
  return (
    <div style={{
      width: 390, height: 844, background: '#F2F1E8',
      borderRadius: 40, overflow: 'hidden',
      border: '1px solid rgba(0,0,0,0.2)', boxSizing: 'border-box',
      display: 'flex', flexDirection: 'column', position: 'relative',
      boxShadow: '0 10px 40px rgba(0,0,0,0.15)',
    }}>
      {/* Dynamic island / sensor notch */}
      <div style={{
        position: 'absolute', top: 12, left: '50%', transform: 'translateX(-50%)',
        width: 126, height: 28, background: '#000', borderRadius: 14, zIndex: 50,
      }}/>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', position: 'relative', zIndex: 1 }}>
        {children}
      </div>
    </div>
  );
}

Object.assign(window, { IOSDevice, IOSStatusBar, IOSNavBar });