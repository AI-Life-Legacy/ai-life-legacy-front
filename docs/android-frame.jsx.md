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
        <span style={{ fontSize: 14, fontWeight: 400, letterSpacing: -0.2, color: c }}>9:41</span>
        <svg width="14" height="14" viewBox="0 0 24 24" fill={c} style={{ opacity: 0.9 }}>
          <path d="M12 22C17.5228 22 22 17.5228 22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715 2 12C2 17.5228 6.47715 22 12 22ZM12 20C7.58172 20 4 16.4183 4 12C4 7.58172 7.58172 4 12 4C16.4183 4 20 7.58172 20 12C20 16.4183 16.4183 20 12 20Z"/>
        </svg>
      </div>

      {/* right icons */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
        <svg width="16" height="12" viewBox="0 0 16 12" fill={c}>
          <path d="M2 12h12V4a6 6 0 00-12 0v8z" fillOpacity="0.2"/>
          <path d="M4 10h8V4a4 4 0 018 0v6z"/>
        </svg>
        <svg width="16" height="12" viewBox="0 0 16 12" fill={c}>
          <path d="M1 3h14v7a2 2 0 01-2 2H3a2 2 0 01-2-2V3z"/>
        </svg>
        <svg width="24" height="12" viewBox="0 0 24 12" fill={c}>
          <rect x="2" y="2" width="16" height="8" rx="3" fillOpacity="0.2"/>
          <rect x="4" y="4" width="9" height="4" rx="1"/>
          <path d="M19 4h1a1 1 0 011 1v2a1 1 0 01-1 1h-1V4z"/>
        </svg>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Top app bar
// ─────────────────────────────────────────────────────────────
function AndroidTopBar({ title, onNav }) {
  return (
    <div style={{
      height: 64, display: 'flex', alignItems: 'center',
      justifyContent: 'space-between', padding: '0 16px',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={onNav} style={{ background: 'none', border: 'none', padding: 4, cursor: 'pointer' }}>
          <svg width="24" height="24" viewBox="0 0 24 24" fill={MD_C.onSurface}>
            <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/>
          </svg>
        </button>
        <span style={{ fontSize: 20, fontWeight: 500, color: MD_C.onSurface }}>{title}</span>
      </div>
      <div style={{ display: 'flex', gap: 16 }}>
        <svg width="24" height="24" viewBox="0 0 24 24" fill={MD_C.onSurfaceVar}><path d="M17 10.5V7c0-.55-.45-1-1-1H4c-.55 0-1 .45-1 1v10c0 .55.45 1 1 1h12c.55 0 1-.45 1-1v-3.5l4 4v-11l-4 4z"/></svg>
        <svg width="24" height="24" viewBox="0 0 24 24" fill={MD_C.onSurfaceVar}><path d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"/></svg>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Keyboard
// ─────────────────────────────────────────────────────────────
function AndroidKeyboard() {
  const key = (l, style = {}) => (
    <div style={{
      flex: 1, height: 44, borderRadius: 4,
      background: style.bg || '#fff', color: MD_C.onSurface,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontSize: 16, fontWeight: 400, border: `1px solid ${MD_C.frameBorder}`,
      boxShadow: '0 1px 2px rgba(0,0,0,0.05)', ...style.container,
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
          {key('?123', { bg: MD_C.secondaryContainer, r: 4 })}
          {key(',', { bg: MD_C.surfaceVariant })}
          {key('', { bg: '#000', flex: 6 })}
          {key('.', { bg: MD_C.surfaceVariant })}
          {key('→', { bg: MD_C.primaryFixedDim, color: MD_C.onPrimaryContainer, flex: 2 })}
        </div>
      </div>
      {/* gesture navigation pill */}
      <div style={{ display: 'flex', justifyContent: 'center', marginTop: 16 }}>
        <div style={{ width: 108, height: 4, borderRadius: 2, background: MD_C.onSurface, opacity: 0.4 }} />
      </div>
    </div>
  );
}

// ─── Android Device Component ──────────────────────────────
function AndroidDevice({ label, children, onNav, keyboard = false }) {
  return (
    <div style={{
      width: 412, height: 890, background: MD_C.surface,
      border: `1px solid ${MD_C.frameBorder}`, borderRadius: 40,
      display: 'flex', flexDirection: 'column',
      boxSizing: 'border-box', overflow: 'hidden',
      position: 'relative', margin: 20, boxShadow: '0 8px 32px rgba(0,0,0,0.12)',
    }}>
      <AndroidStatusBar />
      <AndroidTopBar title={label} onNav={onNav} />
      <div style={{ flex: 1, position: 'relative', overflow: 'auto', display: 'flex', flexDirection: 'column' }}>
        {children}
      </div>
      {keyboard && <AndroidKeyboard />}
    </div>
  );
}

Object.assign(window, { AndroidDevice, AndroidStatusBar });